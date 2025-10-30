// arquivo: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Serviço para gerenciar operações do Firestore
/// Centraliza todas as operações de banco de dados
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
        // Cria novo documento
        final user = UserModel(
          uid: uid,
          name: name,
          email: email,
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
  Future<void> completeActivity({
    required String uid,
    required String activityId,
    required String activityName,
    required int points,
    int attempts = 1,
    double accuracy = 1.0,
  }) async {
    try {
      final userRef = _firestore.collection(usersCollection).doc(uid);

      // Cria documento de progresso da atividade
      final activityProgress = ActivityProgress(
        activityId: activityId,
        activityName: activityName,
        points: points,
        completedAt: DateTime.now(),
        attempts: attempts,
        accuracy: accuracy,
      );

      // Salva na subcoleção de atividades do usuário
      await userRef
          .collection(activitiesCollection)
          .doc(activityId)
          .set(activityProgress.toFirestore());

      // Atualiza totais do usuário
      await userRef.update({
        'totalPoints': FieldValue.increment(points),
        'activitiesCompleted': FieldValue.increment(1),
        'completedActivities': FieldValue.arrayUnion([activityId]),
      });
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
