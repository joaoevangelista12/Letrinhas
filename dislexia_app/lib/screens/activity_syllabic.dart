// arquivo: lib/screens/activity_syllabic.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Activity: Atividade Silábica
/// Usuário responde 5 perguntas sobre sílabas (contagem, identificação)
class ActivitySyllabic extends StatefulWidget {
  const ActivitySyllabic({super.key});

  @override
  State<ActivitySyllabic> createState() => _ActivitySyllabicState();
}

class _ActivitySyllabicState extends State<ActivitySyllabic> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

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
  bool _isCompleted = false;

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

  /// Configura TTS em português brasileiro
  Future<void> _configureTts() async {
    await TtsHelper.configurePortugueseBrazilian(_flutterTts);
  }

  /// Fala instruções iniciais
  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak('Responda as perguntas sobre sílabas');
  }

  /// Fala texto usando TTS
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

  /// Obtém pergunta atual
  Map<String, dynamic> get _currentQuestion => _questions[_currentQuestionIndex];

  /// Verifica se a opção selecionada está correta
  void _checkAnswer(dynamic option) {
    if (_showFeedback) return; // Evita múltiplos cliques

    setState(() {
      _selectedOption = option;
      _showFeedback = true;
      _isCorrect = option.toString() == _currentQuestion['correct'].toString();
      _totalAttempts++;

      if (_isCorrect) {
        _correctCount++;
        _score += 20;
        _speak('Correto! Muito bem!');
      } else {
        _score = (_score - 10).clamp(0, double.infinity).toInt();
        _speak('Ops! Resposta errada');
      }
    });

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
          _speak(_currentQuestion['question']);
        } else {
          // Completou todas as perguntas
          setState(() => _isCompleted = true);
          _speak('Parabéns! Você completou a atividade!');
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
                  Text(
                    '+$_score pontos',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildStatRow('Acertos', '$_correctCount/${_questions.length}'),
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

  /// Constrói linha de estatística
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
        title: const Text('Atividade Silábica'),
        centerTitle: true,
        actions: [
          // Botão de áudio para instruções
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak(
              'Responda as perguntas sobre sílabas',
            ),
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
              const SizedBox(height: 8),

              // Botão de áudio para pergunta
              ElevatedButton.icon(
                onPressed: () => _speak(_currentQuestion['question']),
                icon: Icon(Icons.volume_up, size: iconSize),
                label: const Text('Ouvir Pergunta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Opções de resposta
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
          if (_isCorrect) {
            borderColor = Colors.green;
            bgColor = Colors.green.shade50;
          } else {
            borderColor = Colors.red;
            bgColor = Colors.red.shade50;
          }
        }

        // Mostra a resposta correta quando errou
        if (_showFeedback && !_isCorrect && isCorrectAnswer) {
          borderColor = Colors.green;
          bgColor = Colors.green.shade50;
        }

        return GestureDetector(
          onTap: _showFeedback ? null : () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: accessibilityProvider.enableAnimations ? 200 : 0,
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
                option.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28 * accessibilityProvider.fontSize,
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

  /// Feedback visual
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
