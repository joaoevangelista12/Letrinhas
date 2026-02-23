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
      expect(user.level, 1); // Nível padrão
    });

    test('deve usar nível explícito fornecido', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 250,
        level: 3,
        createdAt: DateTime.now(),
      );

      // Nível explícito = 3 (não calculado de pontos)
      expect(user.level, 3);
      expect(user.totalPoints, 250);
    });

    test('deve criar cópia com valores atualizados incluindo nível', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 100,
        level: 1,
        createdAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        totalPoints: 200,
        activitiesCompleted: 5,
        level: 2,
      );

      expect(updatedUser.uid, 'test123');
      expect(updatedUser.totalPoints, 200);
      expect(updatedUser.activitiesCompleted, 5);
      expect(updatedUser.level, 2);
    });

    test('usuário novo deve começar no nível 1', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 0,
        createdAt: DateTime.now(),
      );

      expect(user.level, 1);
      expect(user.totalPoints, 0);
    });

    test('nível não depende de pontos (é explícito)', () {
      // Mesmo com muitos pontos, o nível é o que foi definido
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 500,
        level: 1, // Ainda nível 1, mesmo com 500 pontos
        createdAt: DateTime.now(),
      );

      expect(user.level, 1);
      expect(user.totalPoints, 500);
    });

    test('deve suportar níveis altos', () {
      final user = UserModel(
        uid: 'test123',
        name: 'João',
        email: 'joao@test.com',
        totalPoints: 1000,
        level: 10,
        createdAt: DateTime.now(),
      );

      expect(user.level, 10);
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
