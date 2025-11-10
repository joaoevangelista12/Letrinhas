// arquivo: lib/screens/activity_order_syllables.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Activity 3: Ordenar Sílabas
/// Usuário arrasta sílabas para formar a palavra correta
class ActivityOrderSyllables extends StatefulWidget {
  const ActivityOrderSyllables({super.key});

  @override
  State<ActivityOrderSyllables> createState() => _ActivityOrderSyllablesState();
}

class _ActivityOrderSyllablesState extends State<ActivityOrderSyllables> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

  // Lista de palavras com sílabas
  final List<Map<String, dynamic>> _words = [
    {
      'word': 'GATO',
      'syllables': ['GA', 'TO'],
      'shuffled': ['TO', 'GA'],
      'emoji': '🐱',
    },
    {
      'word': 'CASA',
      'syllables': ['CA', 'SA'],
      'shuffled': ['SA', 'CA'],
      'emoji': '🏠',
    },
    {
      'word': 'BOLA',
      'syllables': ['BO', 'LA'],
      'shuffled': ['LA', 'BO'],
      'emoji': '⚽',
    },
    {
      'word': 'PATO',
      'syllables': ['PA', 'TO'],
      'shuffled': ['TO', 'PA'],
      'emoji': '🦆',
    },
    {
      'word': 'SAPATO',
      'syllables': ['SA', 'PA', 'TO'],
      'shuffled': ['TO', 'SA', 'PA'],
      'emoji': '👞',
    },
  ];

  int _currentWordIndex = 0;
  List<String?> _orderedSyllables = [];
  List<String> _availableSyllables = [];
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
    _initializeWord();
    _speakInstruction();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  /// Configura TTS
  Future<void> _configureTts() async {
    await TtsHelper.configurePortugueseBrazilian(_flutterTts);
  }

  /// Inicializa palavra atual
  void _initializeWord() {
    final word = _currentWord;
    _orderedSyllables = List.filled(word['syllables'].length, null);
    _availableSyllables = List.from(word['shuffled']);
  }

  /// Fala instruções
  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak('Arraste as sílabas para formar a palavra');
  }

  /// Fala texto
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

  /// Verifica se a ordem está correta
  void _checkAnswer() {
    // Verifica se todas as posições estão preenchidas
    if (_orderedSyllables.contains(null)) {
      _speak('Complete todas as sílabas');
      return;
    }

    setState(() {
      _showFeedback = true;
      _totalAttempts++;

      // Compara a ordem
      _isCorrect = true;
      for (int i = 0; i < _orderedSyllables.length; i++) {
        if (_orderedSyllables[i] != _currentWord['syllables'][i]) {
          _isCorrect = false;
          break;
        }
      }

      if (_isCorrect) {
        _correctCount++;
        _speak('Correto! ${_currentWord['word']}');
      } else {
        _speak('Ops! Tente novamente');
      }
    });

    // Avança ou permite nova tentativa
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_isCorrect) {
          if (_currentWordIndex < _words.length - 1) {
            setState(() {
              _currentWordIndex++;
              _showFeedback = false;
              _isCorrect = false;
            });
            _initializeWord();
            _speak('Próxima palavra');
          } else {
            setState(() => _isCompleted = true);
            _speak('Parabéns! Você completou a atividade!');
            _showCompletionDialog();
          }
        } else {
          // Resetar palavra para nova tentativa
          setState(() {
            _showFeedback = false;
          });
          _initializeWord();
        }
      }
    });
  }

  /// Salva progresso
  Future<void> _saveProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'order-syllables',
          activityName: 'Ordenar Sílabas',
          points: 50,
          attempts: _totalAttempts,
          accuracy: _correctCount / _words.length,
        );

        final userData = await _firestoreService.getUser(userProvider.uid!);
        if (userData != null && mounted) {
          userProvider.updateProgress(
            totalPoints: userData.totalPoints,
            activitiesCompleted: userData.activitiesCompleted,
          );
        }

        debugPrint('✅ Progresso salvo: +50 pontos');
      } catch (e) {
        debugPrint('❌ Erro ao salvar: $e');
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
        title: const Text('Ordenar Sílabas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak('Arraste as sílabas para formar a palavra'),
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

              // Emoji
              Text(
                _currentWord['emoji'],
                style: TextStyle(fontSize: 80 * accessibilityProvider.fontSize),
              ),
              const SizedBox(height: 24),

              // Área de ordenação (drop targets)
              _buildOrderArea(),
              const SizedBox(height: 40),

              // Instruções
              Text(
                'Arraste as sílabas na ordem correta:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Sílabas disponíveis (draggables)
              _buildAvailableSyllables(),

              const Spacer(),

              // Botão verificar
              if (!_orderedSyllables.contains(null) && !_showFeedback)
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Verificar',
                    style: TextStyle(fontSize: 20),
                  ),
                ),

              const SizedBox(height: 16),

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
        ),
      ],
    );
  }

  Widget _buildOrderArea() {
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
          _orderedSyllables.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DragTarget<String>(
              onWillAccept: (data) => !_showFeedback,
              onAccept: (syllable) {
                setState(() {
                  // Remove da posição antiga se já estava ordenada
                  final oldIndex = _orderedSyllables.indexOf(syllable);
                  if (oldIndex != -1) {
                    _orderedSyllables[oldIndex] = null;
                  }

                  // Adiciona na nova posição
                  _orderedSyllables[index] = syllable;

                  // Remove de disponíveis se estava lá
                  _availableSyllables.remove(syllable);
                });
              },
              builder: (context, candidateData, rejectedData) {
                final syllable = _orderedSyllables[index];

                return GestureDetector(
                  onTap: syllable != null && !_showFeedback
                      ? () {
                          setState(() {
                            _availableSyllables.add(syllable);
                            _orderedSyllables[index] = null;
                          });
                        }
                      : null,
                  child: syllable != null
                      ? Draggable<String>(
                          data: syllable,
                          feedback: _buildSyllableCard(
                            syllable,
                            isDragging: true,
                          ),
                          childWhenDragging: _buildSyllableCard(
                            '',
                            isEmpty: true,
                          ),
                          child: _buildSyllableCard(syllable),
                        )
                      : _buildSyllableCard('', isEmpty: true),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSyllables() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: _availableSyllables.map((syllable) {
        return Draggable<String>(
          data: syllable,
          feedback: _buildSyllableCard(syllable, isDragging: true),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildSyllableCard(syllable),
          ),
          child: _buildSyllableCard(syllable),
        );
      }).toList(),
    );
  }

  Widget _buildSyllableCard(
    String syllable, {
    bool isEmpty = false,
    bool isDragging = false,
  }) {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Container(
      width: 80 * accessibilityProvider.iconSize,
      height: 80 * accessibilityProvider.iconSize,
      decoration: BoxDecoration(
        color: isEmpty ? Colors.grey.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmpty
              ? Colors.grey.shade400
              : Theme.of(context).primaryColor,
          width: 3,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Center(
        child: isEmpty
            ? Icon(Icons.add, color: Colors.grey.shade400, size: 32)
            : Text(
                syllable,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 28 * accessibilityProvider.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
      ),
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
