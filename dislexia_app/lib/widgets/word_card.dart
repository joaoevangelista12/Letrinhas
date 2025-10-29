// arquivo: lib/widgets/word_card.dart

import 'package:flutter/material.dart';

/// Widget de card de palavra
/// Usado na atividade de associação
/// Pode ser arrastável (Draggable) ou apenas exibir a palavra
class WordCard extends StatelessWidget {
  final String word;
  final bool isDragging;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const WordCard({
    super.key,
    required this.word,
    this.isDragging = false,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material necessário para efeitos visuais
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDragging ? Colors.blue : Colors.grey.shade300,
              width: isDragging ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDragging
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isDragging ? 15 : 8,
                offset: isDragging ? const Offset(0, 8) : const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texto da palavra
              Text(
                word,
                style: TextStyle(
                  fontSize: isDragging ? 22 : 20,
                  fontWeight: FontWeight.bold,
                  color: isDragging ? Colors.blue.shade900 : Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),

              // Ícone de som (se tiver onTap)
              if (onTap != null && !isDragging) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.volume_up,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante do WordCard especificamente para feedback
/// Mostra se a associação está correta ou incorreta
class WordCardFeedback extends StatelessWidget {
  final String word;
  final bool isCorrect;
  final VoidCallback? onRemove;

  const WordCardFeedback({
    super.key,
    required this.word,
    required this.isCorrect,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.red;
    final bgColor = isCorrect ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone de feedback
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Palavra
          Text(
            word,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.1,
            ),
          ),

          // Botão de remover (se fornecido)
          if (onRemove != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                color: color,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder para quando não há palavra associada
class WordCardPlaceholder extends StatelessWidget {
  const WordCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            'Arraste aqui',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
