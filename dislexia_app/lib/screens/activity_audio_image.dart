// arquivo: lib/screens/activity_audio_image.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../utils/tts_helper.dart';
import '../providers/accessibility_provider.dart';

/// Activity 5: Reforço com Áudio e Imagem
/// Usuário ouve palavra e escolhe a imagem correspondente
class ActivityAudioImage extends StatefulWidget {
  const ActivityAudioImage({super.key});

  @override
  State<ActivityAudioImage> createState() => _ActivityAudioImageState();
}

class _ActivityAudioImageState extends State<ActivityAudioImage> {
  late FlutterTts _flutterTts;
  final FirestoreService _firestoreService = FirestoreService();

  // Lista de palavras com emojis
  final List<Map<String, dynamic>> _words = [
    {
      'word': 'GATO',
      'emoji': '🐱',
      'options': ['🐱', '🐶', '🐭', '🐰'],
    },
    {
      'word': 'SOL',
      'emoji': '☀️',
      'options': ['☀️', '🌙', '⭐', '☁️'],
    },
    {
      'word': 'FLOR',
      'emoji': '🌸',
      'options': ['🌸', '🌳', '🌵', '🍀'],
    },
    {
      'word': 'MAÇÃ',
      'emoji': '🍎',
      'options': ['🍎', '🍌', '🍊', '🍇'],
    },
    {
      'word': 'CASA',
      'emoji': '🏠',
      'options': ['🏠', '🏫', '🏥', '🏪'],
    },
    {
      'word': 'LIVRO',
      'emoji': '📚',
      'options': ['📚', '📝', '📖', '📋'],
    },
  ];

  int _currentWordIndex = 0;
  String? _selectedEmoji;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _isCompleted = false;
  bool _hasPlayedAudio = false;

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
    await _speak('Ouça a palavra e escolha a imagem correta');
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

  Map<String, dynamic> get _currentWord => _words[_currentWordIndex];

  /// Toca o áudio da palavra
  void _playAudio() {
    setState(() => _hasPlayedAudio = true);
    _speak(_currentWord['word']);
  }

  /// Verifica resposta
  void _checkAnswer(String emoji) {
    if (_showFeedback) return;
    if (!_hasPlayedAudio) {
      _speak('Primeiro, ouça a palavra');
      return;
    }

    setState(() {
      _selectedEmoji = emoji;
      _showFeedback = true;
      _isCorrect = emoji == _currentWord['emoji'];
      _totalAttempts++;

      if (_isCorrect) {
        _correctCount++;
        _speak('Correto! ${_currentWord['word']}');
      } else {
        _speak('Ops! Tente novamente');
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_isCorrect) {
          if (_currentWordIndex < _words.length - 1) {
            setState(() {
              _currentWordIndex++;
              _selectedEmoji = null;
              _showFeedback = false;
              _isCorrect = false;
              _hasPlayedAudio = false;
            });
            _speak('Próxima palavra');
          } else {
            setState(() => _isCompleted = true);
            _speak('Parabéns! Você completou a atividade!');
            _showCompletionDialog();
          }
        } else {
          setState(() {
            _selectedEmoji = null;
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
          activityId: 'audio-image',
          activityName: 'Reforço Áudio e Imagem',
          points: 100,
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
        title: const Text('Áudio e Imagem'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, size: iconSize),
            tooltip: 'Ouvir instruções',
            onPressed: () => _speak('Ouça a palavra e escolha a imagem correta'),
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

              // Instrução
              Text(
                'Ouça com atenção:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Botão de reproduzir áudio
              _buildAudioButton(),
              const SizedBox(height: 40),

              // Instruções para escolher
              if (_hasPlayedAudio) ...[
                Text(
                  'Escolha a imagem correta:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Opções de imagens
                Expanded(
                  child: _buildImageOptions(),
                ),
              ] else ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pressione o botão para ouvir a palavra',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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

  Widget _buildAudioButton() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return GestureDetector(
      onTap: _playAudio,
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: accessibilityProvider.enableAnimations ? 300 : 0,
        ),
        width: 140 * accessibilityProvider.iconSize,
        height: 140 * accessibilityProvider.iconSize,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.volume_up,
          size: 70 * accessibilityProvider.iconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImageOptions() {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final List<String> options = _currentWord['options'];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final emoji = options[index];
        final isSelected = _selectedEmoji == emoji;
        final isCorrectAnswer = emoji == _currentWord['emoji'];

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
          onTap: _showFeedback ? null : () => _checkAnswer(emoji),
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: accessibilityProvider.enableAnimations ? 200 : 0,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 5 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: isSelected ? 15 : 8,
                  spreadRadius: isSelected ? 3 : 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: 60 * accessibilityProvider.fontSize),
              ),
            ),
          ),
        );
      },
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
