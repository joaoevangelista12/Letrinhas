// arquivo: lib/screens/activity_form_word.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/sound_helper.dart';
import '../utils/completion_feedback.dart';
import '../providers/accessibility_provider.dart';

/// Activity: Formar Palavra com Silabas
/// Usuário toca nas sílabas na ordem correta para formar a palavra mostrada por um emoji
class ActivityFormWord extends StatefulWidget {
  const ActivityFormWord({super.key});

  @override
  State<ActivityFormWord> createState() => _ActivityFormWordState();
}

class _ActivityFormWordState extends State<ActivityFormWord>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

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
    _initializeQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Inicializa a questão atual
  void _initializeQuestion() {
    final question = _currentQuestion;
    final syllableCount = (question['syllables'] as List<String>).length;
    _slots = List.filled(syllableCount, null);
    _availableSyllables = List<String>.from(question['available']);
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

  /// Verifica se a resposta está correta e avança direto (sem segunda chance)
  void _checkAnswer() {
    final correctSyllables = _currentQuestion['syllables'] as List<String>;

    bool correct = true;
    for (int i = 0; i < _slots.length; i++) {
      if (_slots[i] != correctSyllables[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      _showFeedback = true;
      _totalAttempts++;
      _isCorrect = correct;

      if (correct) {
        _score += 20;
        _correctCount++;
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

    // Sempre avança para próxima questão (sem segunda chance)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _showFeedback = false;
          _isCorrect = false;
        });
        _initializeQuestion();
      } else {
        _showCompletionDialog();
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
        title: const Text('Formar Palavra'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
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

                  // Slots para sílabas com shake animation
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
                    child: _buildSlots(),
                  ),
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
