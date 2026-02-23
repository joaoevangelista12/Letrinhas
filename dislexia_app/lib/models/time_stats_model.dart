// arquivo: lib/models/time_stats_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Registro de uma única sessão de atividade com duração.
class SessionRecord {
  final DateTime date;
  final int durationSeconds;
  final int score;

  const SessionRecord({
    required this.date,
    required this.durationSeconds,
    required this.score,
  });

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'durationSeconds': durationSeconds,
        'score': score,
      };

  factory SessionRecord.fromMap(Map<String, dynamic> data) {
    return SessionRecord(
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      score: (data['score'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Estatísticas de tempo para uma atividade específica.
///
/// Todos os tempos são armazenados em segundos.
/// A conversão para mm:ss deve ocorrer apenas na camada de exibição.
class TimeStatsModel {
  final String activityId;

  /// Duração da última sessão completada (segundos).
  final int lastSessionDuration;

  /// Tempo total acumulado de todas as sessões (segundos).
  final int totalAccumulatedTime;

  /// Número total de sessões completadas.
  final int sessionCount;

  /// Data/hora da última sessão.
  final DateTime? lastSessionAt;

  /// Tempo médio por sessão considerando apenas os últimos 7 dias (segundos).
  final int avgLast7Days;

  /// Tempo acumulado nas últimas 24 horas (segundos).
  final int last24hAccumulated;

  /// Tempo acumulado na última semana / últimos 7 dias (segundos).
  final int lastWeekAccumulated;

  /// Histórico das sessões dos últimos 7 dias.
  final List<SessionRecord> sessionHistory;

  const TimeStatsModel({
    required this.activityId,
    required this.lastSessionDuration,
    required this.totalAccumulatedTime,
    required this.sessionCount,
    this.lastSessionAt,
    required this.avgLast7Days,
    required this.last24hAccumulated,
    required this.lastWeekAccumulated,
    required this.sessionHistory,
  });

  /// Cria um TimeStatsModel a partir de um documento do Firestore.
  /// As métricas derivadas (avg, 24h, semana) são calculadas aqui
  /// a partir do array [recentSessions].
  factory TimeStatsModel.fromFirestore(Map<String, dynamic> data) {
    final activityId = data['activityId'] as String? ?? '';
    final lastSessionDuration =
        (data['lastSessionDuration'] as num?)?.toInt() ?? 0;
    final totalAccumulatedTime =
        (data['totalAccumulatedTime'] as num?)?.toInt() ?? 0;
    final sessionCount = (data['sessionCount'] as num?)?.toInt() ?? 0;
    final lastSessionAt =
        (data['lastSessionAt'] as Timestamp?)?.toDate();

    final rawSessions = (data['recentSessions'] as List<dynamic>?) ?? [];
    final sessions = rawSessions
        .map((s) => SessionRecord.fromMap(s as Map<String, dynamic>))
        .toList();

    final now = DateTime.now();
    final cutoff24h = now.subtract(const Duration(hours: 24));
    final cutoff7d = now.subtract(const Duration(days: 7));

    final sessions24h =
        sessions.where((s) => s.date.isAfter(cutoff24h)).toList();
    final sessions7d =
        sessions.where((s) => s.date.isAfter(cutoff7d)).toList();

    final last24hAccumulated =
        sessions24h.fold(0, (sum, s) => sum + s.durationSeconds);
    final lastWeekAccumulated =
        sessions7d.fold(0, (sum, s) => sum + s.durationSeconds);

    final avgLast7Days = sessions7d.isEmpty
        ? 0
        : (lastWeekAccumulated / sessions7d.length).round();

    return TimeStatsModel(
      activityId: activityId,
      lastSessionDuration: lastSessionDuration,
      totalAccumulatedTime: totalAccumulatedTime,
      sessionCount: sessionCount,
      lastSessionAt: lastSessionAt,
      avgLast7Days: avgLast7Days,
      last24hAccumulated: last24hAccumulated,
      lastWeekAccumulated: lastWeekAccumulated,
      sessionHistory: sessions,
    );
  }
}
