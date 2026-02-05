// arquivo: lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de dados do usuário
/// Representa os dados salvos no Firestore
class UserModel {
  final String uid;
  final String name;
  final String email;
  final int totalPoints;
  final int activitiesCompleted;
  final List<String> completedActivities;
  final int level; // Nível explícito do usuário (1, 2, 3...)
  final int progress; // Progresso dentro do nível (0-100)
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.totalPoints = 0,
    this.activitiesCompleted = 0,
    this.completedActivities = const [],
    this.level = 1, // Todo usuário novo inicia no nível 1
    this.progress = 0, // Todo usuário novo inicia com 0 de progresso
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Cria UserModel a partir de um documento do Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      totalPoints: data['totalPoints'] ?? 0,
      activitiesCompleted: data['activitiesCompleted'] ?? 0,
      completedActivities: List<String>.from(data['completedActivities'] ?? []),
      level: data['level'] ?? 1, // Garante nível 1 se não existir
      progress: data['progress'] ?? 0, // Garante progresso 0 se não existir
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converte UserModel para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'totalPoints': totalPoints,
      'activitiesCompleted': activitiesCompleted,
      'completedActivities': completedActivities,
      'level': level, // Salva nível explicitamente
      'progress': progress, // Salva progresso explicitamente (0-100)
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  /// Cria uma cópia do UserModel com campos atualizados
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? totalPoints,
    int? activitiesCompleted,
    List<String>? completedActivities,
    int? level,
    int? progress,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      totalPoints: totalPoints ?? this.totalPoints,
      activitiesCompleted: activitiesCompleted ?? this.activitiesCompleted,
      completedActivities: completedActivities ?? this.completedActivities,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Retorna progresso atual do nível como porcentagem (0.0 a 1.0)
  double get levelProgress {
    return progress / 100.0;
  }

  /// Retorna pontos de progresso necessários para próximo nível
  int get progressToNextLevel {
    return 100 - progress;
  }
}

/// Modelo de progresso de atividade
class ActivityProgress {
  final String activityId;
  final String activityName;
  final int points;
  final DateTime completedAt;
  final int attempts;
  final double accuracy; // 0.0 a 1.0

  ActivityProgress({
    required this.activityId,
    required this.activityName,
    required this.points,
    required this.completedAt,
    this.attempts = 1,
    this.accuracy = 1.0,
  });

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'activityId': activityId,
      'activityName': activityName,
      'points': points,
      'completedAt': Timestamp.fromDate(completedAt),
      'attempts': attempts,
      'accuracy': accuracy,
    };
  }

  /// Cria ActivityProgress a partir de Map do Firestore
  factory ActivityProgress.fromFirestore(Map<String, dynamic> data) {
    return ActivityProgress(
      activityId: data['activityId'] ?? '',
      activityName: data['activityName'] ?? '',
      points: data['points'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attempts: data['attempts'] ?? 1,
      accuracy: (data['accuracy'] ?? 1.0).toDouble(),
    );
  }
}
