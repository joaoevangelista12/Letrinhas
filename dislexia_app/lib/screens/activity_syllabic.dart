// arquivo: lib/screens/activity_syllabic.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/sound_helper.dart';
import '../utils/completion_feedback.dart';
import '../providers/accessibility_provider.dart';

/// Atividade 2: Complete a palavra com a letra que falta
/// 5 questões sorteadas de um banco de 30 — palavra com lacuna + 4 opções embaralhadas
class ActivitySyllabic extends StatefulWidget {
  const ActivitySyllabic({super.key});

  @override
  State<ActivitySyllabic> createState() => _ActivitySyllabicState();
}

class _ActivitySyllabicState extends State<ActivitySyllabic>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Banco com 30 questões: emoji, palavra completa, índice da letra faltando, opções
  static const List<Map<String, dynamic>> _questionBank = [
    {
      'emoji': '🌸',
      'word': 'FLOR',
      'missingIndex': 2,
      'correct': 'O',
      'options': ['O', 'A', 'E', 'U'],
    },
    {
      'emoji': '🐱',
      'word': 'GATO',
      'missingIndex': 1,
      'correct': 'A',
      'options': ['A', 'O', 'E', 'I'],
    },
    {
      'emoji': '🏠',
      'word': 'CASA',
      'missingIndex': 2,
      'correct': 'S',
      'options': ['S', 'Z', 'R', 'L'],
    },
    {
      'emoji': '⚽',
      'word': 'BOLA',
      'missingIndex': 0,
      'correct': 'B',
      'options': ['B', 'D', 'P', 'V'],
    },
    {
      'emoji': '🦆',
      'word': 'PATO',
      'missingIndex': 3,
      'correct': 'O',
      'options': ['O', 'A', 'U', 'E'],
    },
    {
      'emoji': '🪑',
      'word': 'MESA',
      'missingIndex': 0,
      'correct': 'M',
      'options': ['M', 'N', 'T', 'L'],
    },
    {
      'emoji': '🔥',
      'word': 'FOGO',
      'missingIndex': 1,
      'correct': 'O',
      'options': ['O', 'A', 'E', 'U'],
    },
    {
      'emoji': '🐺',
      'word': 'LOBO',
      'missingIndex': 2,
      'correct': 'B',
      'options': ['B', 'D', 'P', 'V'],
    },
    {
      'emoji': '🏞️',
      'word': 'LAGO',
      'missingIndex': 3,
      'correct': 'O',
      'options': ['O', 'A', 'U', 'E'],
    },
    {
      'emoji': '🕯️',
      'word': 'VELA',
      'missingIndex': 1,
      'correct': 'E',
      'options': ['E', 'A', 'I', 'O'],
    },
    {
      'emoji': '🔔',
      'word': 'SINO',
      'missingIndex': 0,
      'correct': 'S',
      'options': ['S', 'Z', 'C', 'N'],
    },
    {
      'emoji': '🎂',
      'word': 'BOLO',
      'missingIndex': 2,
      'correct': 'L',
      'options': ['L', 'R', 'N', 'M'],
    },
    {
      'emoji': '🎲',
      'word': 'DADO',
      'missingIndex': 1,
      'correct': 'A',
      'options': ['A', 'E', 'I', 'O'],
    },
    {
      'emoji': '🐭',
      'word': 'RATO',
      'missingIndex': 0,
      'correct': 'R',
      'options': ['R', 'T', 'N', 'L'],
    },
    {
      'emoji': '🍇',
      'word': 'UVAS',
      'missingIndex': 1,
      'correct': 'V',
      'options': ['V', 'B', 'D', 'F'],
    },
    {
      'emoji': '📺',
      'word': 'TELA',
      'missingIndex': 3,
      'correct': 'A',
      'options': ['A', 'E', 'O', 'U'],
    },
    {
      'emoji': '❄️',
      'word': 'NEVE',
      'missingIndex': 0,
      'correct': 'N',
      'options': ['N', 'M', 'L', 'R'],
    },
    {
      'emoji': '🥤',
      'word': 'COPO',
      'missingIndex': 3,
      'correct': 'O',
      'options': ['O', 'A', 'E', 'U'],
    },
    {
      'emoji': '👜',
      'word': 'MALA',
      'missingIndex': 1,
      'correct': 'A',
      'options': ['A', 'E', 'I', 'O'],
    },
    {
      'emoji': '🔪',
      'word': 'FACA',
      'missingIndex': 2,
      'correct': 'C',
      'options': ['C', 'S', 'Z', 'T'],
    },
    {
      'emoji': '🍋',
      'word': 'LIMA',
      'missingIndex': 0,
      'correct': 'L',
      'options': ['L', 'N', 'M', 'T'],
    },
    {
      'emoji': '☕',
      'word': 'BULE',
      'missingIndex': 3,
      'correct': 'E',
      'options': ['E', 'A', 'I', 'O'],
    },
    {
      'emoji': '🐢',
      'word': 'TOCA',
      'missingIndex': 2,
      'correct': 'C',
      'options': ['C', 'S', 'Z', 'T'],
    },
    {
      'emoji': '🚀',
      'word': 'NAVE',
      'missingIndex': 1,
      'correct': 'A',
      'options': ['A', 'E', 'I', 'O'],
    },
    {
      'emoji': '🎳',
      'word': 'ROLE',
      'missingIndex': 0,
      'correct': 'R',
      'options': ['R', 'T', 'N', 'L'],
    },
    {
      'emoji': '🦁',
      'word': 'PELE',
      'missingIndex': 1,
      'correct': 'E',
      'options': ['E', 'A', 'I', 'O'],
    },
    {
      'emoji': '🐦',
      'word': 'BICO',
      'missingIndex': 2,
      'correct': 'C',
      'options': ['C', 'S', 'Z', 'T'],
    },
    {
      'emoji': '😨',
      'word': 'MEDO',
      'missingIndex': 0,
      'correct': 'M',
      'options': ['M', 'N', 'L', 'T'],
    },
    {
      'emoji': '🌿',
      'word': 'VIDA',
      'missingIndex': 3,
      'correct': 'A',
      'options': ['A', 'E', 'O', 'U'],
    },
    {
      'emoji': '👆',
      'word': 'DEDO',
      'missingIndex': 2,
      'correct': 'D',
      'options': ['D', 'T', 'B', 'G'],
    },
  ];

  late List<Map<String, dynamic>> _questions;

  int _currentQuestionIndex = 0;
  String? _selectedOption;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _score = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;

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

    // Embaralha o banco e seleciona 5 questões; embaralha as alternativas de cada uma
    final shuffled = List<Map<String, dynamic>>.from(_questionBank)..shuffle();
    _questions = shuffled.take(5).map((q) {
      final opts = List<String>.from(q['options'])..shuffle();
      return {...q, 'options': opts};
    }).toList();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentQuestion => _questions[_currentQuestionIndex];

  /// Monta a palavra com a lacuna (ex: "FL_R")
  String get _wordWithGap {
    final word = _currentQuestion['word'] as String;
    final idx = _currentQuestion['missingIndex'] as int;
    return '${word.substring(0, idx)}_${word.substring(idx + 1)}';
  }

  void _checkAnswer(String option) {
    if (_showFeedback) return;

    final correct = option == _currentQuestion['correct'];

    setState(() {
      _selectedOption = option;
      _showFeedback = true;
      _isCorrect = correct;
      _totalAttempts++;

      if (correct) {
        _correctCount++;
        _score += 20;
      } else {
        _score -= 10;
      }
    });

    if (correct) {
      SoundHelper.playCorrect();
      _confettiController.play();
    } else {
      SoundHelper.playWrong();
      _shakeController.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = null;
          _showFeedback = false;
          _isCorrect = false;
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  Future<void> _saveProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'syllabic',
          activityName: 'Complete a Palavra',
          points: _score,
          attempts: _totalAttempts,
          accuracy: _correctCount / 5,
        );

        final userData = await _firestoreService.getUser(userProvider.uid!);
        if (userData != null && mounted) {
          userProvider.updateProgress(
            totalPoints: userData.totalPoints,
            activitiesCompleted: userData.activitiesCompleted,
            level: userData.level,
            progress: userData.progress,
          );
        }
      } catch (e) {
        debugPrint('Erro ao salvar: $e');
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
  }

  void _showCompletionDialog() async {
    await _saveProgress();
    if (!mounted) return;

    showCompletionFeedback(
      context: context,
      score: _score,
      correctCount: _correctCount,
      totalQuestions: _questions.length,
      totalAttempts: _totalAttempts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete a Palavra'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Progresso e pontuação
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),

                  // Emoji da imagem
                  Text(
                    _currentQuestion['emoji'],
                    style: TextStyle(
                        fontSize: 80 * accessibilityProvider.fontSize),
                  ),
                  const SizedBox(height: 20),

                  // Palavra com lacuna
                  Text(
                    _wordWithGap,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 48 * accessibilityProvider.fontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Instrução
                  Text(
                    'Qual letra completa a palavra?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20 * accessibilityProvider.fontSize,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Opções com shake
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                          _showFeedback && !_isCorrect
                              ? _shakeAnimation.value
                              : 0,
                          0),
                      child: child,
                    ),
                    child: _buildOptions(),
                  ),

                  const Spacer(),

                  // Feedback visual
                  if (_showFeedback) _buildFeedback(),
                ],
              ),
            ),
          ),
          // Confetti
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

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade700, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$_score pts',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final List<String> options =
        List<String>.from(_currentQuestion['options']);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = _selectedOption == option;
        final isCorrectAnswer = option == _currentQuestion['correct'];

        Color borderColor = Theme.of(context).primaryColor;
        Color bgColor = Colors.white;

        if (_showFeedback && isSelected) {
          borderColor = _isCorrect ? Colors.green : Colors.red;
          bgColor =
              _isCorrect ? Colors.green.shade50 : Colors.red.shade50;
        }
        if (_showFeedback && !_isCorrect && isCorrectAnswer) {
          borderColor = Colors.green;
          bgColor = Colors.green.shade50;
        }

        return GestureDetector(
          onTap: _showFeedback ? null : () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80 * accessibilityProvider.iconSize,
            height: 80 * accessibilityProvider.iconSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: isSelected ? 10 : 5,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: AnimatedScale(
                scale:
                    _showFeedback && isSelected && _isCorrect ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  option,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontSize: 32 * accessibilityProvider.fontSize,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback() {
    return AnimatedOpacity(
      opacity: _showFeedback ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isCorrect ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _isCorrect ? 'Correto! +20 pontos' : 'Errado! -10 pontos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
