// arquivo: lib/services/time_tracking_service.dart

/// Serviço de contagem de tempo por sessão de atividade.
///
/// Totalmente invisível para a criança — não exibe nada na UI.
/// Registra apenas o início e o fim de cada sessão, retornando
/// a duração em segundos.
class TimeTrackingService {
  DateTime? _sessionStart;

  /// Inicia o cronômetro interno da sessão.
  /// Deve ser chamado no [initState] da atividade.
  void startSession() {
    _sessionStart = DateTime.now();
  }

  /// Para o cronômetro e retorna a duração da sessão em segundos.
  /// Retorna 0 se [startSession] não foi chamado.
  /// Deve ser chamado antes de salvar o progresso.
  int stopSession() {
    if (_sessionStart == null) return 0;
    final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
    _sessionStart = null;
    return elapsed;
  }

  /// Indica se uma sessão está em andamento.
  bool get isRunning => _sessionStart != null;
}
