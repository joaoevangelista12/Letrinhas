// arquivo: lib/screens/activity_recognize_letters.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Atividade: Reconhecendo Letras
/// 5 questões — mostra uma palavra e o usuário identifica a primeira letra.
/// Pontuação: +20 acerto, -10 erro, sem segunda chance.
class ActivityRecognizeLetters extends StatefulWidget {
  const ActivityRecognizeLetters({super.key});

  @override
  State<ActivityRecognizeLetters> createState() =>
      _ActivityRecognizeLettersState();
}

class _ActivityRecognizeLettersState extends State<ActivityRecognizeLetters> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, dynamic>> _questions = [
    {
      'word': 'BOLA',
      'emoji': '⚽',
      'correct': 'B',
      'options': ['B', 'L', 'M', 'C'],
    },
    {
      'word': 'CASA',
      'emoji': '🏠',
      'correct': 'C',
      'options': ['A', 'S', 'C', 'H'],
    },
    {
      'word': 'PATO',
      'emoji': '🦆',
      'correct': 'P',
      'options': ['T', 'P', 'D', 'B'],
    },
    {
      'word': 'MESA',
      'emoji': '🪑',
      'correct': 'M',
      'options': ['N', 'E', 'S', 'M'],
    },
    {
      'word': 'DADO',
      'emoji': '🎲',
      'correct': 'D',
      'options': ['B', 'G', 'D', 'A'],
    },
  ];

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
    _flutterTts = FlutterTts();
    _configureTts();
    _speakInstruction();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _configureTts() async {
    await TtsHelper.configurePortugueseBrazilian(_flutterTts);
  }

  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak('Qual é a primeira letra da palavra?');
  }

  Future<void> _speak(String text) async {
    final accessibilityProvider = context.read<AccessibilityProvider>();
    if (!accessibilityProvider.enableSounds) return;

    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Erro TTS: $e');
    }
  }

  Map<String, dynamic> get _currentQuestion =>
      _questions[_currentQuestionIndex];

  void _checkAnswer(String option) {
    if (_showFeedback) return;

    setState(() {
      _selectedOption = option;
      _showFeedback = true;
      _isCorrect = option == _currentQuestion['correct'];
      _totalAttempts++;

      if (_isCorrect) {
        _correctCount++;
        _score += 20;
        _speak('Correto! A letra é $option');
      } else {
        _score -= 10;
        _speak('Errado!');
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = null;
          _showFeedback = false;
          _isCorrect = false;
        });
        _speak('Qual é a primeira letra de ${_currentQuestion['word']}?');
      } else {
        _speak('Parabéns! Você completou a atividade!');
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
          activityId: 'recognize-letters',
          activityName: 'Reconhecendo Letras',
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

    showDialog(
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
              'Você completou a atividade!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _score >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _score >= 0 ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_score pontos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _score >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                      'Acertos', '$_correctCount/${_questions.length}'),
                  _buildStatRow('Tentativas', '$_totalAttempts'),
                  _buildStatRow(
                    'Precisão',
                    '${((_correctCount / _questions.length) * 100).toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Voltar para Home'),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final iconSize = 28.0 * accessibilityProvider.iconSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecendo Letras'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak('Qual é a primeira letra da palavra?'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progresso e pontuação
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Emoji
              Text(
                _currentQuestion['emoji'],
                style: TextStyle(
                    fontSize: 80 * accessibilityProvider.fontSize),
              ),
              const SizedBox(height: 16),

              // Palavra destacada
              Text(
                _currentQuestion['word'],
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 48 * accessibilityProvider.fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
              ),
              const SizedBox(height: 24),

              // Pergunta
              Text(
                'Qual é a primeira letra?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20 * accessibilityProvider.fontSize,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Botão de áudio
              ElevatedButton.icon(
                onPressed: () => _speak(
                    'Qual é a primeira letra de ${_currentQuestion['word']}?'),
                icon: Icon(Icons.volume_up, size: iconSize),
                label: const Text('Ouvir Pergunta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Opções
              _buildOptions(),

              const Spacer(),

              // Feedback visual
              if (_showFeedback) _buildFeedback(),
            ],
          ),
        ),
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
                border:
                    Border.all(color: Colors.amber.shade700, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.star,
                      color: Colors.amber.shade700, size: 20),
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
          if (_isCorrect) {
            borderColor = Colors.green;
            bgColor = Colors.green.shade50;
          } else {
            borderColor = Colors.red;
            bgColor = Colors.red.shade50;
          }
        }

        if (_showFeedback && !_isCorrect && isCorrectAnswer) {
          borderColor = Colors.green;
          bgColor = Colors.green.shade50;
        }

        return GestureDetector(
          onTap: _showFeedback ? null : () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: Duration(
              milliseconds:
                  accessibilityProvider.enableAnimations ? 200 : 0,
            ),
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
              child: Text(
                option,
                style:
                    Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 32 * accessibilityProvider.fontSize,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
    );
  }
}
