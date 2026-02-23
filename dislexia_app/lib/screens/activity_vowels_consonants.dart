// arquivo: lib/screens/activity_vowels_consonants.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/sound_helper.dart';
import '../utils/completion_feedback.dart';
import '../providers/accessibility_provider.dart';

/// Atividade 1: Vogais e Consoantes
/// 5 questões sorteadas de um banco de 30.
/// Pergunta: "Marque uma vogal" ou "Marque uma consoante" — 4 opções, 1 correta.
class ActivityVowelsConsonants extends StatefulWidget {
  const ActivityVowelsConsonants({super.key});

  @override
  State<ActivityVowelsConsonants> createState() =>
      _ActivityVowelsConsonantsState();
}

class _ActivityVowelsConsonantsState extends State<ActivityVowelsConsonants>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Banco com 30 questões: 15 "Marque uma vogal" + 15 "Marque uma consoante"
  static const List<Map<String, dynamic>> _questionBank = [
    // --- Marque uma VOGAL (15 questões) ---
    {
      'question': 'Marque uma vogal',
      'correct': 'A',
      'options': ['A', 'B', 'C', 'D'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'E',
      'options': ['E', 'F', 'G', 'H'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'I',
      'options': ['I', 'J', 'K', 'L'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'O',
      'options': ['O', 'M', 'N', 'P'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'U',
      'options': ['U', 'Q', 'R', 'S'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'A',
      'options': ['A', 'T', 'V', 'X'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'E',
      'options': ['E', 'Z', 'B', 'D'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'I',
      'options': ['I', 'F', 'G', 'H'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'O',
      'options': ['O', 'J', 'K', 'L'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'U',
      'options': ['U', 'M', 'N', 'P'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'A',
      'options': ['A', 'Q', 'R', 'S'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'E',
      'options': ['E', 'T', 'V', 'X'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'I',
      'options': ['I', 'Z', 'B', 'C'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'O',
      'options': ['O', 'D', 'F', 'G'],
    },
    {
      'question': 'Marque uma vogal',
      'correct': 'U',
      'options': ['U', 'H', 'J', 'K'],
    },
    // --- Marque uma CONSOANTE (15 questões) ---
    {
      'question': 'Marque uma consoante',
      'correct': 'B',
      'options': ['B', 'A', 'E', 'I'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'C',
      'options': ['C', 'O', 'U', 'A'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'D',
      'options': ['D', 'E', 'I', 'O'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'F',
      'options': ['F', 'U', 'A', 'E'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'G',
      'options': ['G', 'I', 'O', 'U'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'H',
      'options': ['H', 'A', 'E', 'I'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'J',
      'options': ['J', 'O', 'U', 'A'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'L',
      'options': ['L', 'E', 'I', 'O'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'M',
      'options': ['M', 'U', 'A', 'E'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'N',
      'options': ['N', 'I', 'O', 'U'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'P',
      'options': ['P', 'A', 'E', 'I'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'R',
      'options': ['R', 'O', 'U', 'A'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'S',
      'options': ['S', 'E', 'I', 'O'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'T',
      'options': ['T', 'U', 'A', 'E'],
    },
    {
      'question': 'Marque uma consoante',
      'correct': 'V',
      'options': ['V', 'I', 'O', 'U'],
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

  Map<String, dynamic> get _currentQuestion =>
      _questions[_currentQuestionIndex];

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
          activityId: 'vowels-consonants',
          activityName: 'Vogais e Consoantes',
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
        title: const Text('Vogais e Consoantes'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 48),

                  // Pergunta em destaque
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            Theme.of(context).primaryColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _currentQuestion['question'],
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 26 * accessibilityProvider.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Alternativas com shake
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
                  if (_showFeedback) _buildFeedback(),
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
          bgColor = _isCorrect ? Colors.green.shade50 : Colors.red.shade50;
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
