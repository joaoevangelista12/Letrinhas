// arquivo: lib/screens/activity_complete_word.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Activity 2: Completar Palavras
/// Usuário vê palavra com letra faltando e escolhe a letra correta
class ActivityCompleteWord extends StatefulWidget {
  const ActivityCompleteWord({super.key});

  @override
  State<ActivityCompleteWord> createState() => _ActivityCompleteWordState();
}

class _ActivityCompleteWordState extends State<ActivityCompleteWord> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

  // Lista de palavras com letra faltando
  final List<Map<String, dynamic>> _words = [
    {
      'word': 'GATO',
      'display': 'G_TO',
      'missing': 'A',
      'position': 1,
      'options': ['A', 'O', 'E', 'I'],
      'emoji': '🐱',
    },
    {
      'word': 'CASA',
      'display': 'C_SA',
      'missing': 'A',
      'position': 1,
      'options': ['A', 'O', 'E', 'U'],
      'emoji': '🏠',
    },
    {
      'word': 'BOLA',
      'display': 'BO_A',
      'missing': 'L',
      'position': 2,
      'options': ['L', 'R', 'N', 'M'],
      'emoji': '⚽',
    },
    {
      'word': 'PATO',
      'display': 'PA_O',
      'missing': 'T',
      'position': 2,
      'options': ['T', 'D', 'R', 'L'],
      'emoji': '🦆',
    },
    {
      'word': 'FLOR',
      'display': 'FL_R',
      'missing': 'O',
      'position': 2,
      'options': ['O', 'A', 'E', 'U'],
      'emoji': '🌸',
    },
  ];

  int _currentWordIndex = 0;
  String? _selectedLetter;
  bool _showFeedback = false;
  bool _isCorrect = false;
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
    await _speak('Complete a palavra escolhendo a letra que falta');
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

  /// Obtém palavra atual
  Map<String, dynamic> get _currentWord => _words[_currentWordIndex];

  /// Verifica se letra selecionada está correta
  void _checkAnswer(String letter) {
    if (_showFeedback) return; // Evita múltiplos cliques

    setState(() {
      _selectedLetter = letter;
      _showFeedback = true;
      _isCorrect = letter == _currentWord['missing'];
      _totalAttempts++;

      if (_isCorrect) {
        _correctCount++;
        _speak('Correto! ${_currentWord['word']}');
      } else {
        _speak('Ops! Tente novamente');
      }
    });

    // Avança para próxima palavra após feedback
    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          if (_currentWordIndex < _words.length - 1) {
            setState(() {
              _currentWordIndex++;
              _selectedLetter = null;
              _showFeedback = false;
              _isCorrect = false;
            });
            _speak('Próxima palavra');
          } else {
            // Completou todas as palavras
            setState(() => _isCompleted = true);
            _speak('Parabéns! Você completou a atividade!');
            _showCompletionDialog();
          }
        }
      });
    } else {
      // Remove feedback de erro após 1 segundo
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _selectedLetter = null;
            _showFeedback = false;
          });
        }
      });
    }
  }

  /// Salva progresso no Firestore
  Future<void> _saveProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'complete-word',
          activityName: 'Completar Palavras',
          points: 50,
          attempts: _totalAttempts,
          accuracy: _correctCount / _words.length,
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

        debugPrint('✅ Progresso salvo: +50 pontos');
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
                  const Text(
                    '+50 pontos',
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
                  _buildStatRow('Acertos', '$_correctCount/${_words.length}'),
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
        title: const Text('Completar Palavras'),
        centerTitle: true,
        actions: [
          // Botão de áudio para instruções
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak(
              'Complete a palavra escolhendo a letra que falta',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progresso
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Emoji da palavra
              Text(
                _currentWord['emoji'],
                style: TextStyle(fontSize: 80 * accessibilityProvider.fontSize),
              ),
              const SizedBox(height: 24),

              // Palavra com letra faltando
              _buildWordDisplay(),
              const SizedBox(height: 16),

              // Botão de áudio para palavra
              ElevatedButton.icon(
                onPressed: () => _speak(_currentWord['word']),
                icon: Icon(Icons.volume_up, size: iconSize),
                label: const Text('Ouvir Palavra'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Instruções
              Text(
                'Escolha a letra que falta:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Opções de letras
              _buildLetterOptions(),

              const Spacer(),

              // Feedback visual
              if (_showFeedback) _buildFeedback(),
            ],
          ),
        ),
      ),
    );
  }

  /// Indicador de progresso
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Palavra ${_currentWordIndex + 1} de ${_words.length}',
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
          value: (_currentWordIndex + 1) / _words.length,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  /// Display da palavra com letra faltando
  Widget _buildWordDisplay() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _showFeedback
            ? (_isCorrect ? Colors.green.shade50 : Colors.red.shade50)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _showFeedback
              ? (_isCorrect ? Colors.green : Colors.red)
              : Theme.of(context).primaryColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _showFeedback
                ? (_isCorrect
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3))
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        _showFeedback && _isCorrect
            ? _currentWord['word']
            : _currentWord['display'],
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 48 * accessibilityProvider.fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
      ),
    );
  }

  /// Opções de letras
  Widget _buildLetterOptions() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final List<String> options = _currentWord['options'];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: options.map((letter) {
        final isSelected = _selectedLetter == letter;
        final isCorrectAnswer = letter == _currentWord['missing'];

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

        return GestureDetector(
          onTap: _showFeedback ? null : () => _checkAnswer(letter),
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
                letter,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36 * accessibilityProvider.fontSize,
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
