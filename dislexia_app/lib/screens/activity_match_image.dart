// arquivo: lib/screens/activity_match_image.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/sound_helper.dart';
import '../providers/accessibility_provider.dart';

/// Atividade: Relacionar Palavra com Imagem
/// Mostra um emoji e 4 opções de palavras. O usuário deve escolher a palavra correta.
/// 5 questões, +20 pontos por acerto, -10 por erro.
class ActivityMatchImage extends StatefulWidget {
  const ActivityMatchImage({super.key});

  @override
  State<ActivityMatchImage> createState() => _ActivityMatchImageState();
}

class _ActivityMatchImageState extends State<ActivityMatchImage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Questões da atividade
  final List<_Question> _questions = [
    _Question(
      emoji: '\u{1F436}',
      correct: 'CACHORRO',
      options: ['CACHORRO', 'CAVALO', 'COELHO', 'CAMELO'],
    ),
    _Question(
      emoji: '\u{1F319}',
      correct: 'LUA',
      options: ['LUA', 'SOL', 'CÉU', 'MAR'],
    ),
    _Question(
      emoji: '\u{1F34E}',
      correct: 'MAÇÃ',
      options: ['MAÇÃ', 'BANANA', 'UVA', 'PERA'],
    ),
    _Question(
      emoji: '\u2708\uFE0F',
      correct: 'AVIÃO',
      options: ['AVIÃO', 'CARRO', 'BARCO', 'TREM'],
    ),
    _Question(
      emoji: '\u{1F333}',
      correct: 'ÁRVORE',
      options: ['ÁRVORE', 'FLOR', 'FOLHA', 'GRAMA'],
    ),
  ];

  // Estado da atividade
  int _currentQuestion = 0;
  int _score = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;

  // Feedback visual
  String? _selectedOption;
  bool? _lastAnswerCorrect;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 800));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Processa a resposta do usuário (sem segunda chance — avança direto)
  void _handleAnswer(String option) {
    if (_isProcessing) return;

    final question = _questions[_currentQuestion];
    final isCorrect = option == question.correct;

    setState(() {
      _isProcessing = true;
      _selectedOption = option;
      _totalAttempts++;
      _lastAnswerCorrect = isCorrect;

      if (isCorrect) {
        _score += 20;
        _correctCount++;
      } else {
        _score -= 10;
      }
    });

    if (isCorrect) {
      SoundHelper.playCorrect();
      _confettiController.play();
    } else {
      SoundHelper.playWrong();
      _shakeController.forward(from: 0);
    }

    // Sempre avança para próxima questão (sem segunda chance)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedOption = null;
          _lastAnswerCorrect = null;
          _isProcessing = false;
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  /// Salva progresso da atividade no Firestore
  Future<void> _saveProgress() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.uid != null) {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'match-image',
          activityName: 'Relacionar Palavra com Imagem',
          points: _score,
          attempts: _totalAttempts,
          accuracy: _correctCount / 5,
        );

        // Re-lê do Firestore para garantir valores corretos
        final userData = await _firestoreService.getUser(userProvider.uid!);
        if (userData != null && mounted) {
          userProvider.updateProgress(
            totalPoints: userData.totalPoints,
            activitiesCompleted: userData.activitiesCompleted,
            level: userData.level,
            progress: userData.progress,
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao salvar progresso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar progresso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Salva progresso no Firestore e mostra diálogo de conclusão
  void _showCompletionDialog() async {
    await _saveProgress();

    if (!mounted) return;

    final accessibility = Provider.of<AccessibilityProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32 * accessibility.iconSize),
            const SizedBox(width: 8),
            Text(
              'Parabéns!',
              style: TextStyle(fontSize: 22 * accessibility.fontSize),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Você completou a atividade!',
              style: TextStyle(fontSize: 16 * accessibility.fontSize),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _score >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _score >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 28 * accessibility.iconSize),
                  const SizedBox(width: 8),
                  Text(
                    '$_score pontos',
                    style: TextStyle(
                      fontSize: 20 * accessibility.fontSize,
                      fontWeight: FontWeight.bold,
                      color: _score >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Acertos:',
                        style: TextStyle(fontSize: 14 * accessibility.fontSize),
                      ),
                      Text(
                        '$_correctCount / 5',
                        style: TextStyle(
                          fontSize: 14 * accessibility.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tentativas:',
                        style: TextStyle(fontSize: 14 * accessibility.fontSize),
                      ),
                      Text(
                        '$_totalAttempts',
                        style: TextStyle(
                          fontSize: 14 * accessibility.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Precisão:',
                        style: TextStyle(fontSize: 14 * accessibility.fontSize),
                      ),
                      Text(
                        '${(_correctCount / 5 * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14 * accessibility.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha diálogo
              Navigator.of(context).pop(); // Volta para home
            },
            child: Text(
              'Voltar para Home',
              style: TextStyle(fontSize: 14 * accessibility.fontSize),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = Provider.of<AccessibilityProvider>(context);
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relacionar Palavra com Imagem',
          style: TextStyle(fontSize: 18 * accessibility.fontSize),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra de progresso e pontuação
                  _buildProgressBar(accessibility),
                  const SizedBox(height: 16),

                  // Instrução
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 24 * accessibility.iconSize,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Qual é a palavra que representa esta imagem?',
                              style: TextStyle(
                                fontSize: 16 * accessibility.fontSize,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emoji grande centralizado
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          question.emoji,
                          style: TextStyle(fontSize: 100 * accessibility.iconSize),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Opções de palavras (4 botões em grid 2x2) com shake
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                            _isProcessing && _lastAnswerCorrect == false
                                ? _shakeAnimation.value
                                : 0,
                            0),
                        child: child,
                      ),
                      child: _buildOptions(question, accessibility),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti centralizado no topo
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.3,
              numberOfParticles: 15,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a barra de progresso e pontuação
  Widget _buildProgressBar(AccessibilityProvider accessibility) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indicador de questão
        Text(
          'Questão ${_currentQuestion + 1} de 5',
          style: TextStyle(
            fontSize: 16 * accessibility.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        // Pontuação
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: 20 * accessibility.iconSize,
              ),
              const SizedBox(width: 4),
              Text(
                '$_score pts',
                style: TextStyle(
                  fontSize: 16 * accessibility.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói o grid de opções
  Widget _buildOptions(_Question question, AccessibilityProvider accessibility) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: question.options.map((option) {
        return _buildOptionButton(option, question, accessibility);
      }).toList(),
    );
  }

  /// Constrói um botão de opção
  Widget _buildOptionButton(
    String option,
    _Question question,
    AccessibilityProvider accessibility,
  ) {
    final isSelected = _selectedOption == option;
    final bool isCorrectOption = option == question.correct;

    // Determina a cor do botão baseado no estado
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isSelected && _lastAnswerCorrect == true && isCorrectOption) {
      // Resposta correta selecionada
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
    } else if (isSelected && _lastAnswerCorrect == false && !isCorrectOption) {
      // Resposta errada selecionada
      backgroundColor = Colors.red.shade100;
      borderColor = Colors.red;
      textColor = Colors.red.shade900;
    } else {
      // Estado padrão
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade900;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isProcessing ? null : () => _handleAnswer(option),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3 : 2,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected && _lastAnswerCorrect == true && isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedScale(
                      scale: 1.2,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24 * accessibility.iconSize,
                      ),
                    ),
                  ),
                if (isSelected && _lastAnswerCorrect == false && !isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 24 * accessibility.iconSize,
                    ),
                  ),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 18 * accessibility.fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modelo de dados para cada questão
class _Question {
  final String emoji;
  final String correct;
  final List<String> options;

  _Question({
    required this.emoji,
    required this.correct,
    required this.options,
  });
}
