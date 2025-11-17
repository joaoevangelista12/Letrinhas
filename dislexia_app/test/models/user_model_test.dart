// arquivo: test/models/user_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dislexia_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('deve criar UserModel com valores padrão', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João Silva',
        email: 'joao@test.com',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(user.uid, 'test123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@test.com');
      expect(user.totalPoints, 0);
      expect(user.activitiesCompleted, 0);
      expect(user.completedActivities, isEmpty);
    });

    test('deve calcular nível corretamente', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 250,
        createdAt: DateTime.now(),
      );

      // 250 / 100 = 2, +1 = 3
      expect(user.level, 3);
    });

    test('deve calcular progresso de nível corretamente', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 150,
        createdAt: DateTime.now(),
      );

      // 150 % 100 = 50, 50/100 = 0.5
      expect(user.levelProgress, 0.5);
    });

    test('deve calcular pontos para próximo nível', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 75,
        createdAt: DateTime.now(),
      );

      // 100 - 75 = 25
      expect(user.pointsToNextLevel, 25);
    });

    test('deve criar cópia com valores atualizados', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 100,
        createdAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        totalPoints: 200,
        activitiesCompleted: 5,
      );

      expect(updatedUser.uid, 'test123');
      expect(updatedUser.totalPoints, 200);
      expect(updatedUser.activitiesCompleted, 5);
    });

    test('nível 1 com 0 pontos', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 0,
        createdAt: DateTime.now(),
      );

      expect(user.level, 1);
      expect(user.levelProgress, 0.0);
      expect(user.pointsToNextLevel, 100);
    });

    test('nível 2 com 100 pontos', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 100,
        createdAt: DateTime.now(),
      );

      expect(user.level, 2);
      expect(user.levelProgress, 0.0);
      expect(user.pointsToNextLevel, 100);
    });

    test('nível 5 com 450 pontos', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 450,
        createdAt: DateTime.now(),
      );

      expect(user.level, 5);
      expect(user.levelProgress, 0.5);
      expect(user.pointsToNextLevel, 50);
    });
  });

  group('ActivityProgress', () {
    test('deve criar ActivityProgress corretamente', () {
      final now = DateTime.now();
      final activity = ActivityProgress(
        activityId: 'test-activity',
        activityName: 'Test Activity',
        points: 50,
        completedAt: now,
        attempts: 5,
        accuracy: 0.8,
      );

      expect(activity.activityId, 'test-activity');
      expect(activity.activityName, 'Test Activity');
      expect(activity.points, 50);
      expect(activity.completedAt, now);
      expect(activity.attempts, 5);
      expect(activity.accuracy, 0.8);
    });

    test('deve ter valores padrão corretos', () {
      final activity = ActivityProgress(
        activityId: 'test',
        activityName: 'Test',
        points: 50,
        completedAt: DateTime.now(),
      );

      expect(activity.attempts, 1);
      expect(activity.accuracy, 1.0);
    });

    test('deve converter para Firestore corretamente', () {
      final now = DateTime.now();
      final activity = ActivityProgress(
        activityId: 'test',
        activityName: 'Test',
        points: 50,
        completedAt: now,
        attempts: 3,
        accuracy: 0.9,
      );

      final map = activity.toFirestore();

      expect(map['activityId'], 'test');
      expect(map['activityName'], 'Test');
      expect(map['points'], 50);
      expect(map['attempts'], 3);
      expect(map['accuracy'], 0.9);
      expect(map['completedAt'], isA<Timestamp>());
    });
  });
}
