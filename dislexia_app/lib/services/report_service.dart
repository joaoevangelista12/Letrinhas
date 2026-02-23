// arquivo: lib/services/report_service.dart

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/user_model.dart';
import '../models/time_stats_model.dart';

/// Serviço para geração do relatório de desempenho em PDF.
/// Totalmente transparente para a criança — acessado apenas por pais/profissionais.
class ReportService {
  // Paleta de cores do relatório
  static final _primary = PdfColor.fromInt(0xFF1565C0);
  static final _primaryLight = PdfColor.fromInt(0xFFE3F2FD);
  static final _headerBg = PdfColor.fromInt(0xFF1976D2);
  static final _textDark = PdfColor.fromInt(0xFF212121);
  static final _textMid = PdfColor.fromInt(0xFF757575);
  static final _divider = PdfColor.fromInt(0xFFE0E0E0);
  static final _bgGrey = PdfColor.fromInt(0xFFF5F5F5);
  static final _green = PdfColor.fromInt(0xFF2E7D32);
  static final _orange = PdfColor.fromInt(0xFFE65100);

  // Definição das 5 atividades na ordem correta
  static const List<Map<String, String>> _activityDefs = [
    {'id': 'vowels-consonants', 'name': 'Vogais e Consoantes'},
    {'id': 'recognize-letters', 'name': 'Reconhecendo Letras'},
    {'id': 'syllabic', 'name': 'Complete a Palavra'},
    {'id': 'form-word', 'name': 'Formar Palavra com Silabas'},
    {'id': 'match-image', 'name': 'Relacionar Palavra com Imagem'},
  ];

  // ─── Utilitários ──────────────────────────────────────────────────────────

  /// Converte segundos para formato mm:ss.
  static String formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Precisão média de uma atividade em um período. Retorna "Sem dados" se vazio.
  static String _accuracy(
    List<ActivityProgress> history,
    String activityId,
    DateTime cutoff,
  ) {
    final sessions = history
        .where((a) => a.activityId == activityId && a.completedAt.isAfter(cutoff))
        .toList();
    if (sessions.isEmpty) return 'Sem dados';
    final avg = sessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
        sessions.length;
    return '${(avg * 100).toStringAsFixed(0)}%';
  }

  /// Sessões de uma atividade num período. [activityId] null = todas.
  static int _sessionCount(
    List<ActivityProgress> history,
    String? activityId,
    DateTime cutoff,
  ) {
    return history
        .where((a) =>
            (activityId == null || a.activityId == activityId) &&
            a.completedAt.isAfter(cutoff))
        .length;
  }

  // ─── Geração do PDF ───────────────────────────────────────────────────────

  /// Gera o relatório completo e retorna os bytes do PDF.
  static Future<Uint8List> generateReport({
    required UserModel user,
    required List<ActivityProgress> activityHistory,
    required List<TimeStatsModel> timeStats,
  }) async {
    final now = DateTime.now();
    final cutoff24h = now.subtract(const Duration(hours: 24));
    final cutoff7d = now.subtract(const Duration(days: 7));

    final statsMap = {for (final s in timeStats) s.activityId: s};

    // Dados do resumo geral
    final sessionsWeek = _sessionCount(activityHistory, null, cutoff7d);
    final totalTimeWeek =
        timeStats.fold(0, (sum, s) => sum + s.lastWeekAccumulated);
    final weekHistory =
        activityHistory.where((a) => a.completedAt.isAfter(cutoff7d)).toList();
    final avgAccuracy = weekHistory.isEmpty
        ? 'Sem dados'
        : '${(weekHistory.map((a) => a.accuracy).reduce((a, b) => a + b) / weekHistory.length * 100).toStringAsFixed(0)}%';
    final totalSessions = activityHistory.length;

    final pdf = pw.Document(
      title: 'Relatorio de Desempenho - ${user.name}',
      author: 'Letrinhas',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
        header: (ctx) => _buildHeader(user.name, now),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          // ── Seção 1: Identificação
          _sectionTitle('1. Identificacao'),
          pw.SizedBox(height: 8),
          _buildIdentificationTable(user, now),
          pw.SizedBox(height: 24),

          // ── Seção 2: Desempenho por Atividade
          _sectionTitle('2. Desempenho por Atividade'),
          pw.SizedBox(height: 8),
          ..._buildAllActivityCards(
            activityHistory,
            statsMap,
            cutoff24h,
            cutoff7d,
          ),

          // ── Seção 3: Resumo Geral
          pw.SizedBox(height: 20),
          _sectionTitle('3. Resumo Geral'),
          pw.SizedBox(height: 8),
          _buildSummaryTable(
            sessionsWeek: sessionsWeek,
            totalTimeWeek: totalTimeWeek,
            avgAccuracy: avgAccuracy,
            totalSessions: totalSessions,
          ),
          pw.SizedBox(height: 20),
          _buildDisclaimer(),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Widgets do cabeçalho e rodapé ────────────────────────────────────────

  static pw.Widget _buildHeader(String userName, DateTime now) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: pw.BoxDecoration(
            color: _headerBg,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LETRINHAS',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Relatorio de Desempenho',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    userName,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 14),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _divider, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Letrinhas - Relatorio de Desempenho',
            style: pw.TextStyle(fontSize: 8, color: _textMid),
          ),
          pw.Text(
            'Pagina ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _textMid),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Tabela de identificação ───────────────────────────────────────────────

  static pw.Widget _buildIdentificationTable(UserModel user, DateTime now) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1.6),
        1: const pw.FlexColumnWidth(3.0),
      },
      border: pw.TableBorder.all(color: _divider, width: 0.5),
      children: [
        _tableRow('Nome do Aluno', user.name),
        _tableRow('Data de Geracao', DateFormat('dd/MM/yyyy HH:mm').format(now)),
        _tableRow('Periodo Analisado', 'Ultimas 24 horas  |  Ultimos 7 dias'),
        _tableRow('Nivel Atual', 'Nivel ${user.level}'),
        _tableRow('Pontuacao Total', '${user.totalPoints} pontos'),
      ],
    );
  }

  // ─── Cards de atividades ──────────────────────────────────────────────────

  static List<pw.Widget> _buildAllActivityCards(
    List<ActivityProgress> history,
    Map<String, TimeStatsModel> statsMap,
    DateTime cutoff24h,
    DateTime cutoff7d,
  ) {
    final widgets = <pw.Widget>[];
    for (int i = 0; i < _activityDefs.length; i++) {
      final def = _activityDefs[i];
      final id = def['id']!;
      final name = def['name']!;
      final stats = statsMap[id];

      widgets.add(pw.SizedBox(height: 10));
      widgets.add(_buildActivityCard(
        index: i + 1,
        name: name,
        accuracy24h: _accuracy(history, id, cutoff24h),
        accuracy7d: _accuracy(history, id, cutoff7d),
        sessions24h: _sessionCount(history, id, cutoff24h),
        sessions7d: _sessionCount(history, id, cutoff7d),
        lastSession: stats != null && stats.lastSessionDuration > 0
            ? formatDuration(stats.lastSessionDuration)
            : 'Sem dados',
        avgWeek: stats != null && stats.avgLast7Days > 0
            ? formatDuration(stats.avgLast7Days)
            : 'Sem dados',
        totalWeek: stats != null && stats.lastWeekAccumulated > 0
            ? formatDuration(stats.lastWeekAccumulated)
            : 'Sem dados',
        total24h: stats != null && stats.last24hAccumulated > 0
            ? formatDuration(stats.last24hAccumulated)
            : 'Sem dados',
      ));
    }
    return widgets;
  }

  static pw.Widget _buildActivityCard({
    required int index,
    required String name,
    required String accuracy24h,
    required String accuracy7d,
    required int sessions24h,
    required int sessions7d,
    required String lastSession,
    required String avgWeek,
    required String totalWeek,
    required String total24h,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divider, width: 0.8),
        borderRadius: pw.BorderRadius.circular(5),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título da atividade
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: _primaryLight,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Atividade $index: $name',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _primary,
              ),
            ),
          ),
          pw.SizedBox(height: 8),

          // Colunas: Taxa de Acerto | Tempo
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─ Taxa de Acerto
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _colHeader('TAXA DE ACERTO'),
                    pw.SizedBox(height: 5),
                    _metricRow(
                      'Ultimas 24h:',
                      accuracy24h,
                      sub: sessions24h > 0
                          ? '($sessions24h ${sessions24h == 1 ? 'sessao' : 'sessoes'})'
                          : null,
                    ),
                    pw.SizedBox(height: 3),
                    _metricRow(
                      'Ultima semana:',
                      accuracy7d,
                      sub: sessions7d > 0
                          ? '($sessions7d ${sessions7d == 1 ? 'sessao' : 'sessoes'})'
                          : null,
                    ),
                  ],
                ),
              ),

              // Divisória vertical
              pw.Container(
                width: 0.6,
                height: 60,
                margin: const pw.EdgeInsets.symmetric(horizontal: 12),
                color: _divider,
              ),

              // ─ Tempo
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _colHeader('TEMPO (mm:ss)'),
                    pw.SizedBox(height: 5),
                    _metricRow('Ultima sessao:', lastSession),
                    pw.SizedBox(height: 3),
                    _metricRow('Media/sessao (semana):', avgWeek),
                    pw.SizedBox(height: 3),
                    _metricRow('Total semana:', totalWeek),
                    pw.SizedBox(height: 3),
                    _metricRow('Total 24h:', total24h),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _colHeader(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
        color: _textMid,
        letterSpacing: 0.4,
      ),
    );
  }

  static pw.Widget _metricRow(String label, String value, {String? sub}) {
    final noData = value == 'Sem dados';
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 8, color: _textMid),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: noData ? _textMid : _textDark,
          ),
        ),
        if (sub != null) ...[
          pw.SizedBox(width: 3),
          pw.Text(
            sub,
            style: pw.TextStyle(fontSize: 7, color: _textMid),
          ),
        ],
      ],
    );
  }

  // ─── Tabela de resumo geral ────────────────────────────────────────────────

  static pw.Widget _buildSummaryTable({
    required int sessionsWeek,
    required int totalTimeWeek,
    required String avgAccuracy,
    required int totalSessions,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2.2),
        1: const pw.FlexColumnWidth(1.5),
      },
      border: pw.TableBorder.all(color: _divider, width: 0.5),
      children: [
        _tableRow(
          'Total de sessoes na semana',
          '$sessionsWeek ${sessionsWeek == 1 ? 'sessao' : 'sessoes'}',
        ),
        _tableRow(
          'Tempo total de uso na semana',
          formatDuration(totalTimeWeek),
        ),
        _tableRow(
          'Media geral de acertos (semana)',
          avgAccuracy,
        ),
        _tableRow(
          'Total de sessoes no historico',
          '$totalSessions ${totalSessions == 1 ? 'sessao' : 'sessoes'}',
        ),
      ],
    );
  }

  static pw.TableRow _tableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: _bgGrey,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textMid,
            ),
          ),
        ),
        pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: PdfColors.white,
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Aviso final ──────────────────────────────────────────────────────────

  static pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _bgGrey,
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: _divider, width: 0.5),
      ),
      child: pw.Text(
        'Este relatorio foi gerado automaticamente pelo aplicativo Letrinhas. '
        'Os dados refletem as sessoes realizadas pela crianca e sao '
        'destinados ao acompanhamento pedagogico. '
        '"Sem dados" indica que nao ha sessoes registradas no periodo analisado.',
        style: pw.TextStyle(
          fontSize: 7.5,
          color: _textMid,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }
}
