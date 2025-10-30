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
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.totalPoints = 0,
    this.activitiesCompleted = 0,
    this.completedActivities = const [],
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
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Retorna nível do usuário baseado nos pontos
  int get level {
    // A cada 100 pontos = 1 nível
    return (totalPoints / 100).floor() + 1;
  }

  /// Retorna progresso atual do nível (0-100%)
  double get levelProgress {
    final pointsInCurrentLevel = totalPoints % 100;
    return pointsInCurrentLevel / 100;
  }

  /// Retorna pontos necessários para próximo nível
  int get pointsToNextLevel {
    return 100 - (totalPoints % 100);
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
