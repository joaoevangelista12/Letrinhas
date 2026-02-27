// arquivo: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../models/time_stats_model.dart';

/// Serviço para gerenciar operações do Firestore
/// Centraliza todas as operações de banco de dados
/// IMPORTANTE: Implementa validação de níveis para acesso às atividades
class FirestoreService {
  // Instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nome da coleção de usuários
  static const String usersCollection = 'users';
  static const String activitiesCollection = 'activities';
  static const String timeStatsCollection = 'time_stats';

  /// Cria ou atualiza documento do usuário no Firestore
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final userDoc = _firestore.collection(usersCollection).doc(uid);

      // Verifica se o usuário já existe
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Atualiza apenas o último login
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Cria novo documento com nível inicial 1
        final user = UserModel(
          uid: uid,
          name: name,
          email: email,
          level: 1, // TODO USUÁRIO NOVO INICIA NO NÍVEL 1
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await userDoc.set(user.toFirestore());
      }
    } catch (e) {
      throw Exception('Erro ao criar usuário no Firestore: $e');
    }
  }

  /// Busca dados do usuário no Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  /// Stream de dados do usuário (atualização em tempo real)
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Atualiza nome do usuário
  Future<void> updateUserName(String uid, String name) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).update({
        'name': name,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar nome: $e');
    }
  }

  /// Registra conclusão de atividade e adiciona/subtrai pontos
  /// Pontuação da atividade pode ser negativa, mas totalPoints nunca fica < 0
  /// Nível é bidirecional: level = (totalPoints ~/ 100) + 1
  Future<void> completeActivity({
    required String uid,
    required String activityId,
    required String activityName,
    required int points,
    int attempts = 1,
    double accuracy = 1.0,
    int durationSeconds = 0,
  }) async {
    try {
      // 1. BUSCA DADOS DO USUÁRIO
      final userData = await getUser(uid);
      if (userData == null) {
        throw Exception('Usuário não encontrado');
      }

      // 2. REGRA: só a atividade correspondente ao nível atual altera pontos.
      // Atividades de níveis anteriores ou posteriores ficam em modo prática.
      final activityModel = Activities.getById(activityId);
      final bool isCurrentLevelActivity =
          activityModel != null && activityModel.requiredLevel == userData.level;
      final int effectivePoints = isCurrentLevelActivity ? points : 0;

      // 3. CALCULA NOVO TOTAL DE PONTOS (nunca negativo)
      int newTotalPoints = userData.totalPoints + effectivePoints;
      if (newTotalPoints < 0) {
        newTotalPoints = 0;
      }

      // 4. CALCULA NÍVEL BASEADO NO TOTAL DE PONTOS (bidirecional)
      // Level 1: 0-99, Level 2: 100-199, Level 3: 200-299, Level 4: 300-399, Level 5: 400+
      // Nível máximo = 5 (temos 5 atividades)
      int newLevel = (newTotalPoints ~/ 100) + 1;
      if (newLevel > 5) newLevel = 5;

      // 5. CALCULA PROGRESSO DENTRO DO NÍVEL (0-99)
      final int newProgress = newTotalPoints % 100;

      final userRef = _firestore.collection(usersCollection).doc(uid);

      // 6. PREPARA REGISTRO DA ATIVIDADE (ID único por conclusão)
      // effectivePoints = 0 quando atividade está em modo prática (fora do nível atual)
      final now = DateTime.now();
      final docId = '$activityId-${now.millisecondsSinceEpoch}';
      final activityProgress = ActivityProgress(
        activityId: activityId,
        activityName: activityName,
        points: effectivePoints,
        completedAt: now,
        attempts: attempts,
        accuracy: accuracy,
        durationSeconds: durationSeconds,
      );

      // 7. ATUALIZA SUBCOLEÇÃO E DOCUMENTO DO USUÁRIO EM BATCH ATÔMICO
      final Map<String, dynamic> updateData = {
        'totalPoints': newTotalPoints,
        'activitiesCompleted': FieldValue.increment(1),
        'completedActivities': FieldValue.arrayUnion([activityId]),
        'level': newLevel,
        'progress': newProgress,
      };

      final batch = _firestore.batch();
      batch.set(
        userRef.collection(activitiesCollection).doc(docId),
        activityProgress.toFirestore(),
      );
      batch.update(userRef, updateData);
      await batch.commit();

      // 8. ATUALIZA ESTATÍSTICAS DE TEMPO (operação separada, não bloqueia pontuação)
      await _updateTimeStats(
        uid: uid,
        activityId: activityId,
        durationSeconds: durationSeconds,
        score: points,
        sessionDate: now,
      );
    } catch (e) {
      throw Exception('Erro ao registrar atividade: $e');
    }
  }

  /// Atualiza as estatísticas de tempo para uma atividade.
  /// Opera na subcoleção [time_stats] do usuário.
  /// Mantém o histórico das sessões dos últimos 7 dias.
  Future<void> _updateTimeStats({
    required String uid,
    required String activityId,
    required int durationSeconds,
    required int score,
    required DateTime sessionDate,
  }) async {
    try {
      final statsRef = _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(timeStatsCollection)
          .doc(activityId);

      final newSessionEntry = {
        'date': Timestamp.fromDate(sessionDate),
        'durationSeconds': durationSeconds,
        'score': score,
      };

      final statsDoc = await statsRef.get();

      if (statsDoc.exists) {
        final data = statsDoc.data()!;
        final rawSessions =
            (data['recentSessions'] as List<dynamic>?) ?? [];

        // Mantém apenas sessões dos últimos 7 dias + adiciona a nova
        final cutoff = sessionDate.subtract(const Duration(days: 7));
        final updatedSessions = [
          ...rawSessions
              .cast<Map<String, dynamic>>()
              .where((s) =>
                  (s['date'] as Timestamp).toDate().isAfter(cutoff)),
          newSessionEntry,
        ];

        await statsRef.update({
          'lastSessionDuration': durationSeconds,
          'totalAccumulatedTime': FieldValue.increment(durationSeconds),
          'sessionCount': FieldValue.increment(1),
          'lastSessionAt': Timestamp.fromDate(sessionDate),
          'recentSessions': updatedSessions,
        });
      } else {
        await statsRef.set({
          'activityId': activityId,
          'lastSessionDuration': durationSeconds,
          'totalAccumulatedTime': durationSeconds,
          'sessionCount': 1,
          'lastSessionAt': Timestamp.fromDate(sessionDate),
          'recentSessions': [newSessionEntry],
        });
      }
    } catch (_) {
      // Erro nas estatísticas de tempo não deve interromper o fluxo principal
    }
  }

  /// Busca estatísticas de tempo de uma atividade específica para um usuário.
  Future<TimeStatsModel?> getActivityTimeStats(
      String uid, String activityId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(timeStatsCollection)
          .doc(activityId)
          .get();

      if (!doc.exists) return null;
      return TimeStatsModel.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas de tempo: $e');
    }
  }

  /// Busca estatísticas de tempo de todas as atividades de um usuário.
  Future<List<TimeStatsModel>> getAllTimeStats(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(timeStatsCollection)
          .get();

      return snapshot.docs
          .map((doc) => TimeStatsModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas de tempo: $e');
    }
  }

  /// Busca histórico de atividades do usuário
  Future<List<ActivityProgress>> getUserActivities(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(activitiesCollection)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivityProgress.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar atividades: $e');
    }
  }

  /// Verifica se uma atividade já foi completada
  Future<bool> hasCompletedActivity(String uid, String activityId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(activitiesCollection)
          .doc(activityId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Busca ranking de usuários (top 10)
  Future<List<UserModel>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ranking: $e');
    }
  }

  /// Reseta progresso do usuário (útil para testes)
  Future<void> resetUserProgress(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).update({
        'totalPoints': 0,
        'activitiesCompleted': 0,
        'completedActivities': [],
        'level': 1, // Reseta para nível 1
        'progress': 0, // Reseta progresso para 0
      });

      // Deleta todas as atividades
      final activities = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(activitiesCollection)
          .get();

      for (var doc in activities.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Erro ao resetar progresso: $e');
    }
  }
}
