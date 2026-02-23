// arquivo: lib/widgets/level_progress_bar.dart

import 'package:flutter/material.dart';

/// Widget visual de barra de progresso de nível para crianças.
///
/// Exibe o nível atual do usuário e uma barra de progresso animada
/// mostrando o avanço até o próximo nível.
///
/// **Características:**
/// - Visual amigável e colorido para crianças
/// - Animação suave ao atualizar progresso
/// - Ícones motivadores (estrelas, troféu)
/// - Cores vibrantes e alegres
///
/// **Uso:**
/// ```dart
/// LevelProgressBar(
///   level: 2,
///   progress: 75, // 75% até o próximo nível
/// )
/// ```
class LevelProgressBar extends StatelessWidget {
  /// Nível atual do usuário
  final int level;

  /// Progresso dentro do nível atual (0-100)
  final int progress;

  /// Altura da barra de progresso
  final double height;

  /// Se deve mostrar o texto de progresso (ex: "75/100")
  final bool showProgressText;

  const LevelProgressBar({
    super.key,
    required this.level,
    required this.progress,
    this.height = 24,
    this.showProgressText = true,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com nível atual
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nível atual com ícone de troféu
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: _getLevelColor(level),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nível $level',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(level),
                      ),
                ),
              ],
            ),

            // Progresso numérico
            if (showProgressText)
              Text(
                '$progress/100',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Barra de progresso
        Stack(
          children: [
            // Fundo da barra (cinza claro)
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),

            // Progresso preenchido (colorido com gradiente)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: height,
              width: MediaQuery.of(context).size.width * progressPercent,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getProgressGradient(level),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: progressPercent > 0
                    ? [
                        BoxShadow(
                          color: _getLevelColor(level).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
            ),

            // Estrelinhas decorativas ao longo da barra
            if (progressPercent > 0.2)
              Positioned(
                left: MediaQuery.of(context).size.width * progressPercent - 16,
                top: (height - 16) / 2,
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // Mensagem motivadora
        _buildMotivationalMessage(context, progressPercent),
      ],
    );
  }

  /// Retorna cor baseada no nível do usuário
  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.blue[600]!;
      case 2:
        return Colors.purple[600]!;
      case 3:
        return Colors.orange[600]!;
      default:
        return Colors.green[600]!;
    }
  }

  /// Retorna gradiente de cores para a barra de progresso
  List<Color> _getProgressGradient(int level) {
    switch (level) {
      case 1:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case 2:
        return [Colors.purple[400]!, Colors.purple[600]!];
      case 3:
        return [Colors.orange[400]!, Colors.orange[600]!];
      default:
        return [Colors.green[400]!, Colors.green[600]!];
    }
  }

  /// Mensagem motivadora baseada no progresso
  Widget _buildMotivationalMessage(BuildContext context, double progressPercent) {
    String message;
    IconData icon;
    Color color;

    if (progressPercent >= 0.9) {
      message = 'Quase lá! Você está quase no próximo nível! 🎉';
      icon = Icons.celebration;
      color = Colors.orange[700]!;
    } else if (progressPercent >= 0.7) {
      message = 'Ótimo trabalho! Continue assim! 💪';
      icon = Icons.thumb_up;
      color = Colors.green[700]!;
    } else if (progressPercent >= 0.4) {
      message = 'Você está indo muito bem! 🌟';
      icon = Icons.star_outline;
      color = Colors.blue[700]!;
    } else if (progressPercent > 0) {
      message = 'Bom começo! Continue praticando! 😊';
      icon = Icons.emoji_emotions_outlined;
      color = Colors.purple[700]!;
    } else {
      message = 'Complete atividades para subir de nível!';
      icon = Icons.play_arrow;
      color = Colors.grey[700]!;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

/// Widget compacto de progresso de nível (versão menor).
///
/// Usado em headers ou onde o espaço é limitado.
class CompactLevelProgress extends StatelessWidget {
  /// Nível atual do usuário
  final int level;

  /// Progresso dentro do nível atual (0-100)
  final int progress;

  const CompactLevelProgress({
    super.key,
    required this.level,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress / 100.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getLevelColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getLevelColor(level).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: _getLevelColor(level),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Nível $level',
            style: TextStyle(
              color: _getLevelColor(level),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          // Mini barra de progresso
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: _getLevelColor(level),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$progress%',
            style: TextStyle(
              color: _getLevelColor(level),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna cor baseada no nível do usuário
  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.blue[600]!;
      case 2:
        return Colors.purple[600]!;
      case 3:
        return Colors.orange[600]!;
      default:
        return Colors.green[600]!;
    }
  }
}
