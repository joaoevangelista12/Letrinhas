// arquivo: lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';

/// Widgets compartilhados reutilizáveis em todo o app
/// Reduz duplicação de código e facilita manutenção

/// Widget para exibir uma linha de estatística (label: valor)
/// Usado nas telas de conclusão de atividades
class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Helper para criar diálogo de conclusão de atividade
/// Padroniza o layout de todos os diálogos de sucesso
class ActivityCompletionDialog {
  /// Mostra diálogo de conclusão com estatísticas
  static Future<void> show({
    required BuildContext context,
    required int points,
    required int correctCount,
    required int totalItems,
    required int totalAttempts,
    required VoidCallback onDismiss,
  }) {
    final double accuracy = correctCount / totalAttempts;
    final int accuracyPercent = (accuracy * 100).toInt();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('Parabéns!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Você completou a atividade com sucesso!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Card de pontos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$points pontos',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  StatRow(label: 'Acertos', value: '$correctCount/$totalItems'),
                  StatRow(label: 'Tentativas', value: '$totalAttempts'),
                  StatRow(label: 'Precisão', value: '$accuracyPercent%'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss();
            },
            child: const Text('Voltar para Home'),
          ),
        ],
      ),
    );
  }
}

/// Card de configuração genérico para tela de settings
/// Reduz duplicação na SettingsPage
class SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget? bottom;

  const SettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}

/// Feedback visual para atividades (correto/incorreto)
class ActivityFeedback extends StatelessWidget {
  final bool isCorrect;

  const ActivityFeedback({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            isCorrect ? 'Correto!' : 'Tente novamente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de progresso para atividades
class ActivityProgressIndicator extends StatelessWidget {
  final int currentItem;
  final int totalItems;
  final int correctCount;

  const ActivityProgressIndicator({
    super.key,
    required this.currentItem,
    required this.totalItems,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item $currentItem de $totalItems',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Acertos: $correctCount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: currentItem / totalItems,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
