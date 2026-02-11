// arquivo: lib/screens/activity_read_sentences.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Activity 4: Leitura de Frases Curtas
/// Usuário lê frases e responde perguntas de compreensão
class ActivityReadSentences extends StatefulWidget {
  const ActivityReadSentences({super.key});

  @override
  State<ActivityReadSentences> createState() => _ActivityReadSentencesState();
}

class _ActivityReadSentencesState extends State<ActivityReadSentences> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

  // Lista de frases com perguntas de compreensão
  final List<Map<String, dynamic>> _sentences = [
    {
      'sentence': 'O gato bebe leite.',
      'question': 'O que o gato bebe?',
      'options': ['Leite', 'Água', 'Suco'],
      'correct': 'Leite',
      'emoji': '🐱',
    },
    {
      'sentence': 'A bola é azul.',
      'question': 'De que cor é a bola?',
      'options': ['Azul', 'Vermelha', 'Verde'],
      'correct': 'Azul',
      'emoji': '⚽',
    },
    {
      'sentence': 'O sol brilha no céu.',
      'question': 'Onde o sol brilha?',
      'options': ['No céu', 'No mar', 'Na casa'],
      'correct': 'No céu',
      'emoji': '☀️',
    },
    {
      'sentence': 'A menina come uma maçã.',
      'question': 'O que a menina come?',
      'options': ['Uma maçã', 'Uma banana', 'Um pão'],
      'correct': 'Uma maçã',
      'emoji': '👧',
    },
    {
      'sentence': 'O pássaro canta na árvore.',
      'question': 'Onde o pássaro canta?',
      'options': ['Na árvore', 'No ninho', 'No chão'],
      'correct': 'Na árvore',
      'emoji': '🐦',
    },
  ];

  int _currentSentenceIndex = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _isCompleted = false;
  bool _hasReadSentence = false;

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
    await _speak('Leia a frase e responda a pergunta');
  }

  Future<void> _speak(String text) async {
    final accessibilityProvider = context.read<AccessibilityProvider>();
    if (!accessibilityProvider.enableSounds) return;

    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.speak(text);
      debugPrint('🔊 TTS: $text');
    } catch (e) {
      debugPrint('❌ Erro TTS: $e');
    }
  }

  Map<String, dynamic> get _currentSentence => _sentences[_currentSentenceIndex];

  /// Lê a frase em voz alta
  void _readSentence() {
    setState(() => _hasReadSentence = true);
    _speak(_currentSentence['sentence']);
  }

  /// Verifica resposta
  void _checkAnswer(String answer) {
    if (_showFeedback) return;

    setState(() {
      _selectedAnswer = answer;
      _showFeedback = true;
      _isCorrect = answer == _currentSentence['correct'];
      _totalAttempts++;

      if (_isCorrect) {
        _correctCount++;
        _speak('Correto!');
      } else {
        _speak('Ops! Tente novamente');
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_isCorrect) {
          if (_currentSentenceIndex < _sentences.length - 1) {
            setState(() {
              _currentSentenceIndex++;
              _selectedAnswer = null;
              _showFeedback = false;
              _isCorrect = false;
              _hasReadSentence = false;
            });
            _speak('Próxima frase');
          } else {
            setState(() => _isCompleted = true);
            _speak('Parabéns! Você completou a atividade!');
            _showCompletionDialog();
          }
        } else {
          setState(() {
            _selectedAnswer = null;
            _showFeedback = false;
          });
        }
      }
    });
  }

  Future<void> _saveProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'read-sentences',
          activityName: 'Leitura de Frases',
          points: 100,
          attempts: _totalAttempts,
          accuracy: _correctCount / _sentences.length,
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

        debugPrint('✅ Progresso salvo: +100 pontos');
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
              'Você completou a atividade com sucesso!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
                  const Text(
                    '+100 pontos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
                  _buildStatRow('Acertos', '$_correctCount/${_sentences.length}'),
                  _buildStatRow('Tentativas', '$_totalAttempts'),
                  _buildStatRow(
                    'Precisão',
                    '${((_correctCount / _totalAttempts) * 100).toStringAsFixed(0)}%',
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
        title: const Text('Leitura de Frases'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak('Leia a frase e responda a pergunta'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progresso
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Emoji
              Text(
                _currentSentence['emoji'],
                style: TextStyle(fontSize: 80 * accessibilityProvider.fontSize),
              ),
              const SizedBox(height: 24),

              // Frase para ler
              _buildSentenceCard(),
              const SizedBox(height: 16),

              // Botão de áudio
              ElevatedButton.icon(
                onPressed: _readSentence,
                icon: Icon(Icons.volume_up, size: iconSize),
                label: const Text('Ouvir Frase'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Pergunta
              if (_hasReadSentence) ...[
                Text(
                  _currentSentence['question'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Opções de resposta
                _buildAnswerOptions(),
              ],

              const SizedBox(height: 24),

              // Feedback
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
              'Frase ${_currentSentenceIndex + 1} de ${_sentences.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Acertos: $_correctCount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (_currentSentenceIndex + 1) / _sentences.length,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildSentenceCard() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        _currentSentence['sentence'],
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 28 * accessibilityProvider.fontSize,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnswerOptions() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final List<String> options = _currentSentence['options'];

    return Column(
      children: options.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrectAnswer = option == _currentSentence['correct'];

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

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: _showFeedback ? null : () => _checkAnswer(option),
            child: AnimatedContainer(
              duration: Duration(
                milliseconds: accessibilityProvider.enableAnimations ? 200 : 0,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Container(
                    width: 40 * accessibilityProvider.iconSize,
                    height: 40 * accessibilityProvider.iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                      color: isSelected ? borderColor : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: borderColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
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
            _isCorrect ? 'Correto!' : 'Tente novamente',
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
