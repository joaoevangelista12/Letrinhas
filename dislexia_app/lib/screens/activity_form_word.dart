// arquivo: lib/screens/activity_form_word.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Activity: Formar Palavra com Silabas
///Usuário toca nas sílabas na ordem correta para formar a palavra mostrada por um emoji
class ActivityFormWord extends StatefulWidget {
  const ActivityFormWord({super.key});

  @override
  State<ActivityFormWord> createState() => _ActivityFormWordState();
}

class _ActivityFormWordState extends State<ActivityFormWord> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

  // Lista de questões: emoji, palavra correta, sílabas embaralhadas
  final List<Map<String, dynamic>> _questions = [
    {
      'emoji': '\u{1F3E0}',
      'word': 'CASA',
      'syllables': ['CA', 'SA'],
      'available': ['SA', 'CA'],
    },
    {
      'emoji': '\u{1F431}',
      'word': 'GATO',
      'syllables': ['GA', 'TO'],
      'available': ['TO', 'GA'],
    },
    {
      'emoji': '\u26BD',
      'word': 'BOLA',
      'syllables': ['BO', 'LA'],
      'available': ['LA', 'BO'],
    },
    {
      'emoji': '\u{1F45E}',
      'word': 'SAPATO',
      'syllables': ['SA', 'PA', 'TO'],
      'available': ['TO', 'SA', 'PA'],
    },
    {
      'emoji': '\u{1F338}',
      'word': 'FLOR',
      'syllables': ['FLOR'],
      'available': ['FLOR'],
    },
  ];

  int _currentIndex = 0;
  List<String?> _slots = [];
  List<String> _availableSyllables = [];
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
    _initializeQuestion();
    _speakInstruction();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  /// Configura TTS em Português Brasileiro
  Future<void> _configureTts() async {
    await TtsHelper.configurePortugueseBrazilian(_flutterTts);
  }

  /// Inicializa a questão atual
  void _initializeQuestion() {
    final question = _currentQuestion;
    final syllableCount = (question['syllables'] as List<String>).length;
    _slots = List.filled(syllableCount, null);
    _availableSyllables = List<String>.from(question['available']);
  }

  /// Fala instruções
  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak('Toque nas sílabas para formar a palavra');
  }

  /// Fala texto usando TTS
  Future<void> _speak(String text) async {
    final accessibilityProvider = context.read<AccessibilityProvider>();
    if (!accessibilityProvider.enableSounds) return;

    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.speak(text);
      debugPrint('TTS: $text');
    } catch (e) {
      debugPrint('Erro TTS: $e');
    }
  }

  /// Obtém questão atual
  Map<String, dynamic> get _currentQuestion => _questions[_currentIndex];

  /// Encontra o próximo slot vazio
  int _nextEmptySlot() {
    for (int i = 0; i < _slots.length; i++) {
      if (_slots[i] == null) return i;
    }
    return -1;
  }

  /// Usuário toca em uma sílaba disponível
  void _onSyllableTap(String syllable) {
    if (_showFeedback) return;

    final slotIndex = _nextEmptySlot();
    if (slotIndex == -1) return;

    setState(() {
      _slots[slotIndex] = syllable;
      _availableSyllables.remove(syllable);
    });

    // Se todos os slots estão preenchidos, verifica automaticamente
    if (!_slots.contains(null)) {
      _checkAnswer();
    }
  }

  /// Usuário toca em um slot preenchido para removê-lo
  void _onSlotTap(int index) {
    if (_showFeedback) return;
    if (_slots[index] == null) return;

    setState(() {
      _availableSyllables.add(_slots[index]!);
      _slots[index] = null;
    });
  }

  /// Verifica se a resposta está correta
  void _checkAnswer() {
    final correctSyllables = _currentQuestion['syllables'] as List<String>;

    setState(() {
      _showFeedback = true;
      _totalAttempts++;

      _isCorrect = true;
      for (int i = 0; i < _slots.length; i++) {
        if (_slots[i] != correctSyllables[i]) {
          _isCorrect = false;
          break;
        }
      }

      if (_isCorrect) {
        _score += 20;
        _correctCount++;
        _speak('Correto! ${_currentQuestion['word']}');
      } else {
        _score = (_score - 10).clamp(0, double.maxFinite.toInt());
        _speak('Tente novamente');
      }
    });

    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _showFeedback = false;
            _isCorrect = false;
          });
          _initializeQuestion();
          _speak('Próxima palavra');
        } else {
          setState(() => _isCompleted = true);
          _speak('Parabéns! Você completou a atividade!');
          _showCompletionDialog();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _showFeedback = false;
        });
        _initializeQuestion();
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
          activityId: 'form-word',
          activityName: 'Formar Palavra com Sílabas',
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

        debugPrint('Progresso salvo: +$_score pontos');
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
                    _totalAttempts > 0
                        ? '${((_correctCount / _totalAttempts) * 100).toStringAsFixed(0)}%'
                        : '0%',
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
        title: const Text('Formar Palavra'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak('Toque nas sílabas para formar a palavra'),
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
              const SizedBox(height: 24),

              // Emoji
              Text(
                _currentQuestion['emoji'],
                style: TextStyle(fontSize: 80 * accessibilityProvider.fontSize),
              ),
              const SizedBox(height: 24),

              // Slots para sílabas
              _buildSlots(),
              const SizedBox(height: 32),

              // Instruções
              Text(
                'Toque nas sílabas na ordem correta:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Sílabas disponíveis
              _buildAvailableSyllables(),

              const Spacer(),

              // Feedback
              if (_showFeedback) _buildFeedback(),

              const SizedBox(height: 16),

              // Pontuação
              Text(
                'Pontos: $_score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
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
              'Palavra ${_currentIndex + 1} de ${_questions.length}',
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
          value: (_currentIndex + 1) / _questions.length,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildSlots() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _showFeedback
            ? (_isCorrect ? Colors.green.shade50 : Colors.red.shade50)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _showFeedback
              ? (_isCorrect ? Colors.green : Colors.red)
              : Theme.of(context).primaryColor,
          width: 3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _slots.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => _onSlotTap(index),
              child: Container(
                width: 80 * accessibilityProvider.iconSize,
                height: 80 * accessibilityProvider.iconSize,
                decoration: BoxDecoration(
                  color: _slots[index] != null ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _slots[index] != null
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: _slots[index] != null
                      ? Text(
                          _slots[index]!,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 28 * accessibilityProvider.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        )
                      : Icon(
                          Icons.add,
                          color: Colors.grey.shade400,
                          size: 32 * accessibilityProvider.iconSize,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSyllables() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: _availableSyllables.map((syllable) {
        return GestureDetector(
          onTap: () => _onSyllableTap(syllable),
          child: Container(
            width: 90 * accessibilityProvider.iconSize,
            height: 70 * accessibilityProvider.iconSize,
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
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                syllable,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 28 * accessibilityProvider.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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
