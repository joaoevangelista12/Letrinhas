// arquivo: lib/utils/completion_feedback.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'sound_helper.dart';

/// Dados de feedback baseados na pontuação obtida na atividade.
class _FeedbackData {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<Color> confettiColors;
  final bool showConfetti;

  const _FeedbackData({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.confettiColors,
    required this.showConfetti,
  });
}

/// Retorna dados de feedback baseados na pontuação.
_FeedbackData _getFeedback(int score) {
  if (score == 100) {
    // Caso 4 — Pontuação máxima
    return _FeedbackData(
      title: 'Pontuacao Maxima!',
      message: 'Uau!!! Voce fez $score pontos! Voce e incrivel!',
      icon: Icons.emoji_events,
      color: Colors.amber.shade800,
      bgColor: Colors.amber.shade50,
      confettiColors: [
        Colors.amber,
        Colors.yellow,
        Colors.orange,
        Colors.amber.shade300,
      ],
      showConfetti: true,
    );
  } else if (score > 50) {
    // Caso 3 — Mais da metade (> 50)
    return _FeedbackData(
      title: 'Incrivel!',
      message: 'Voce fez $score pontos! Esta mandando muito bem!',
      icon: Icons.star,
      color: Colors.green.shade700,
      bgColor: Colors.green.shade50,
      confettiColors: [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.amber,
        Colors.purple,
      ],
      showConfetti: true,
    );
  } else if (score > 0) {
    // Caso 1 — Pontuação positiva
    return _FeedbackData(
      title: 'Parabens!',
      message: 'Voce fez $score pontos! Continue assim!',
      icon: Icons.celebration,
      color: Colors.green,
      bgColor: Colors.green.shade50,
      confettiColors: [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.amber,
      ],
      showConfetti: true,
    );
  } else {
    // Caso 2 — Pontuação negativa ou zero
    return _FeedbackData(
      title: 'Continue tentando!',
      message: 'Voce fez $score pontos, mas tudo bem! Vamos tentar novamente e melhorar!',
      icon: Icons.favorite,
      color: Colors.orange.shade700,
      bgColor: Colors.orange.shade50,
      confettiColors: [],
      showConfetti: false,
    );
  }
}

/// Mostra o diálogo de conclusão com feedback visual/sonoro baseado na pontuação.
///
/// [context] — BuildContext da tela que chama.
/// [score] — Pontuação obtida na atividade.
/// [correctCount] — Quantidade de acertos.
/// [totalQuestions] — Total de questões.
/// [totalAttempts] — Total de tentativas.
void showCompletionFeedback({
  required BuildContext context,
  required int score,
  required int correctCount,
  required int totalQuestions,
  required int totalAttempts,
}) {
  final feedback = _getFeedback(score);

  // Toca som correspondente
  if (score == 100) {
    // Som de acerto repetido para efeito de celebração
    SoundHelper.playCorrect();
    Future.delayed(const Duration(milliseconds: 200), () => SoundHelper.playCorrect());
  } else if (score > 0) {
    SoundHelper.playCorrect();
  } else {
    // Som suave encorajador (reutiliza correct em volume baixo — não é erro)
    SoundHelper.playCorrect();
  }

  // Controlador de confetti criado dentro do dialog
  final confettiController = feedback.showConfetti
      ? ConfettiController(duration: Duration(milliseconds: score == 100 ? 2000 : 1000))
      : null;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      // Inicia confetti
      confettiController?.play();

      return Stack(
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: score == 100
                  ? BorderSide(color: Colors.amber.shade400, width: 3)
                  : BorderSide.none,
            ),
            backgroundColor: score == 100 ? Colors.amber.shade50 : null,
            title: Row(
              children: [
                Icon(feedback.icon, color: feedback.color, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feedback.title,
                    style: TextStyle(
                      color: feedback.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mensagem principal
                Text(
                  feedback.message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Card de pontuação
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: feedback.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: feedback.color, width: 2),
                    boxShadow: score == 100
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        score == 100 ? Icons.emoji_events : Icons.star,
                        color: score == 100 ? Colors.amber.shade700 : feedback.color,
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$score pontos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: feedback.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Estatísticas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Acertos', '$correctCount/$totalQuestions'),
                      _buildStatRow('Tentativas', '$totalAttempts'),
                      _buildStatRow(
                        'Precisao',
                        totalAttempts > 0
                            ? '${((correctCount / totalAttempts) * 100).toStringAsFixed(0)}%'
                            : '0%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  confettiController?.dispose();
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Voltar para Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: feedback.color,
                  ),
                ),
              ),
            ],
          ),

          // Confetti overlay
          if (confettiController != null)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirection: pi / 2,
                maxBlastForce: score == 100 ? 30 : 20,
                minBlastForce: 5,
                emissionFrequency: score == 100 ? 0.5 : 0.3,
                numberOfParticles: score == 100 ? 25 : 15,
                gravity: 0.2,
                colors: feedback.confettiColors,
              ),
            ),
        ],
      );
    },
  );
}

Widget _buildStatRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
