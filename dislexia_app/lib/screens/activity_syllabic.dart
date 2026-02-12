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

/// Activity: Atividade Silábica
/// Usuário responde 5 perguntas sobre sílabas (contagem, identificação)
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

  // Lista de perguntas sobre sílabas
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quantas sílabas tem a palavra GATO?',
      'word': 'GATO',
      'emoji': '🐱',
      'options': [1, 2, 3, 4],
      'correct': 2,
    },
    {
      'question': 'Qual é a primeira sílaba de CASA?',
      'word': 'CASA',
      'emoji': '🏠',
      'options': ['CA', 'SA', 'AS', 'AC'],
      'correct': 'CA',
    },
    {
      'question': 'Quantas sílabas tem BORBOLETA?',
      'word': 'BORBOLETA',
      'emoji': '🦋',
      'options': [2, 3, 4, 5],
      'correct': 4,
    },
    {
      'question': 'Qual é a última sílaba de SAPATO?',
      'word': 'SAPATO',
      'emoji': '👞',
      'options': ['SA', 'PA', 'TO', 'AP'],
      'correct': 'TO',
    },
    {
      'question': 'Quantas sílabas tem SOL?',
      'word': 'SOL',
      'emoji': '☀️',
      'options': [1, 2, 3, 4],
      'correct': 1,
    },
  ];

  int _currentQuestionIndex = 0;
  dynamic _selectedOption;
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
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Obtém pergunta atual
  Map<String, dynamic> get _currentQuestion => _questions[_currentQuestionIndex];

  /// Verifica se a opção selecionada está correta
  void _checkAnswer(dynamic option) {
    if (_showFeedback) return;

    final correct =
        option.toString() == _currentQuestion['correct'].toString();

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

    // Avança para próxima pergunta após feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
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
      }
    });
  }

  /// Salva progresso no Firestore
  Future<void> _saveProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'syllabic',
          activityName: 'Atividade Silábica',
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

        debugPrint('✅ Progresso salvo: +$_score pontos');
      } catch (e) {
        debugPrint('❌ Erro ao salvar: $e');
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

  /// Mostra diálogo de conclusão
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
        title: const Text('Atividade Silábica'),
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
                  const SizedBox(height: 32),

                  // Emoji da palavra
                  Text(
                    _currentQuestion['emoji'],
                    style: TextStyle(fontSize: 80 * accessibilityProvider.fontSize),
                  ),
                  const SizedBox(height: 16),

                  // Palavra destacada
                  Text(
                    _currentQuestion['word'],
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 40 * accessibilityProvider.fontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Pergunta
                  Text(
                    _currentQuestion['question'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20 * accessibilityProvider.fontSize,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Opções de resposta com shake animation
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

  /// Indicador de progresso com pontuação
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  /// Opções de resposta
  Widget _buildOptions() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final List<dynamic> options = _currentQuestion['options'];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = _selectedOption != null &&
            _selectedOption.toString() == option.toString();
        final isCorrectAnswer =
            option.toString() == _currentQuestion['correct'].toString();

        Color borderColor = Theme.of(context).primaryColor;
        Color bgColor = Colors.white;

        if (_showFeedback && isSelected) {
          borderColor = _isCorrect ? Colors.green : Colors.red;
          bgColor = _isCorrect ? Colors.green.shade50 : Colors.red.shade50;
        }

        // Mostra a resposta correta quando errou
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
                scale: _showFeedback && isSelected && _isCorrect ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  option.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28 * accessibilityProvider.fontSize,
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

  /// Feedback visual
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
