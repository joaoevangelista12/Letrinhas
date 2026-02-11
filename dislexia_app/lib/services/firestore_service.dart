// arquivo: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';

/// Serviço para gerenciar operações do Firestore
/// Centraliza todas as operações de banco de dados
/// IMPORTANTE: Implementa validação de níveis para acesso às atividades
class FirestoreService {
  // Instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nome da coleção de usuários
  static const String usersCollection = 'users';
  static const String activitiesCollection = 'activities';

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

  /// Registra conclusão de atividade e adiciona pontos
  /// VALIDA SE O USUÁRIO TEM NÍVEL SUFICIENTE PARA ACESSAR A ATIVIDADE
  /// Implementa progressão de nível ao completar atividades
  Future<void> completeActivity({
    required String uid,
    required String activityId,
    required String activityName,
    required int points,
    int attempts = 1,
    double accuracy = 1.0,
  }) async {
    try {
      // 1. BUSCA DADOS DO USUÁRIO
      final userData = await getUser(uid);
      if (userData == null) {
        throw Exception('Usuário não encontrado');
      }

      // 2. VALIDA SE O USUÁRIO PODE ACESSAR ESTA ATIVIDADE
      final activity = Activities.getById(activityId);
      if (activity == null) {
        throw Exception('Atividade inválida: $activityId');
      }

      if (!activity.canAccess(userData.level)) {
        throw Exception(
          'Acesso negado: Você precisa estar no nível ${activity.requiredLevel} '
          'para acessar esta atividade. Seu nível atual: ${userData.level}',
        );
      }

      // 3. VERIFICA SE A ATIVIDADE JÁ FOI COMPLETADA
      final alreadyCompleted = await hasCompletedActivity(uid, activityId);
      if (alreadyCompleted) {
        return;
      }

      final userRef = _firestore.collection(usersCollection).doc(uid);

      // 4. PREPARA PROGRESSO DA ATIVIDADE
      final activityProgress = ActivityProgress(
        activityId: activityId,
        activityName: activityName,
        points: points,
        completedAt: DateTime.now(),
        attempts: attempts,
        accuracy: accuracy,
      );

      // 5. CALCULA PROGRESSO E LEVEL-UP
      const int progressPerActivity = 50;
      int newProgress = userData.progress + progressPerActivity;
      int newLevel = userData.level;

      while (newProgress >= 100) {
        newLevel++;
        newProgress -= 100;
      }

      // 6. ATUALIZA SUBCOLEÇÃO E DOCUMENTO DO USUÁRIO EM BATCH ATÔMICO
      final Map<String, dynamic> updateData = {
        'totalPoints': FieldValue.increment(points),
        'activitiesCompleted': FieldValue.increment(1),
        'completedActivities': FieldValue.arrayUnion([activityId]),
        'progress': newProgress,
      };

      if (newLevel > userData.level) {
        updateData['level'] = newLevel;
      }

      final batch = _firestore.batch();
      batch.set(
        userRef.collection(activitiesCollection).doc(activityId),
        activityProgress.toFirestore(),
      );
      batch.update(userRef, updateData);
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao registrar atividade: $e');
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
