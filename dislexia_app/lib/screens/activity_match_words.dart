// arquivo: lib/screens/activity_match_words.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../widgets/word_card.dart';
import '../services/firestore_service.dart';
import '../main.dart';
import '../utils/tts_helper.dart';

/// Atividade de Associação de Palavras com Imagens
/// O usuário deve associar 3 palavras com suas respectivas imagens
/// Funcionalidade: drag & drop ou tap para associar
class ActivityMatchWords extends StatefulWidget {
  const ActivityMatchWords({super.key});

  @override
  State<ActivityMatchWords> createState() => _ActivityMatchWordsState();
}

class _ActivityMatchWordsState extends State<ActivityMatchWords> {
  // TTS para feedback sonoro
  late FlutterTts _flutterTts;

  // Dados da atividade (em produção viriam de um banco de dados)
  final List<WordImagePair> _wordImagePairs = [
    WordImagePair(
      word: 'GATO',
      emoji: '🐱',
      color: Colors.orange,
    ),
    WordImagePair(
      word: 'SOL',
      emoji: '☀️',
      color: Colors.yellow,
    ),
    WordImagePair(
      word: 'CASA',
      emoji: '🏠',
      color: Colors.blue,
    ),
  ];

  // Lista de palavras embaralhadas
  late List<String> _shuffledWords;

  // Armazena as associações feitas (emoji -> palavra)
  final Map<String, String?> _associations = {};

  // Controla se a atividade foi completada
  bool _isCompleted = false;

  // Contador de acertos
  int _correctMatches = 0;

  @override
  void initState() {
    super.initState();

    // Inicializa TTS
    _flutterTts = FlutterTts();
    _configureTts();

    // Embaralha as palavras
    _shuffledWords = _wordImagePairs.map((e) => e.word).toList()..shuffle();

    // Inicializa mapa de associações
    for (var pair in _wordImagePairs) {
      _associations[pair.emoji] = null;
    }
  }

  /// Configura o Text-to-Speech em Português Brasileiro
  Future<void> _configureTts() async {
    // Usa o helper para configurar TTS com todas as tentativas possíveis
    final success = await TtsHelper.configurePortugueseBrazilian(_flutterTts);

    if (!success) {
      debugPrint('⚠️ AVISO: TTS pode não estar em português brasileiro!');
    }

    // Lista todas as vozes disponíveis para debug
    if (success) {
      await TtsHelper.testSpeak(_flutterTts);
    }
  }

  /// Fala uma palavra ou frase usando TTS em Português Brasileiro
  Future<void> _speak(String text) async {
    try {
      // Força idioma português antes de falar (importante para Web)
      await _flutterTts.setLanguage('pt-BR');

      // Fala o texto
      await _flutterTts.speak(text);

      debugPrint('🔊 TTS falando: $text');
    } catch (e) {
      debugPrint('❌ Erro ao falar "$text": $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  /// Verifica se a associação está correta
  bool _checkMatch(String emoji, String word) {
    return _wordImagePairs
        .any((pair) => pair.emoji == emoji && pair.word == word);
  }

  /// Processa a associação de uma palavra com uma imagem
  void _handleAssociation(String emoji, String word) {
    setState(() {
      // Se já havia uma palavra associada, remove
      _associations[emoji] = word;

      // Verifica se está correto
      if (_checkMatch(emoji, word)) {
        _correctMatches++;
        _speak('Correto! $word');

        // Verifica se completou a atividade
        if (_correctMatches == _wordImagePairs.length) {
          _isCompleted = true;
          _speak('Parabéns! Você completou a atividade!');
          _showCompletionDialog();
        }
      } else {
        _speak('Ops! Tente novamente');
      }
    });
  }

  /// Remove associação
  void _removeAssociation(String emoji) {
    setState(() {
      final word = _associations[emoji];
      if (word != null && _checkMatch(emoji, word)) {
        _correctMatches--;
      }
      _associations[emoji] = null;
    });
  }

  /// Mostra diálogo de conclusão e salva progresso
  void _showCompletionDialog() async {
    // Salva progresso no Firestore
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
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha diálogo
              _resetActivity();
            },
            child: const Text('Tentar Novamente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha diálogo
              Navigator.of(context).pop(); // Volta para home
            },
            child: const Text('Voltar ao Menu'),
          ),
        ],
      ),
    );
  }

  /// Salva progresso da atividade no Firestore
  Future<void> _saveProgress() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.uid != null) {
        final firestoreService = FirestoreService();

        // Salva no Firestore
        await firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'match-words',
          activityName: 'Associar Palavras',
          points: 50,
          attempts: 1,
          accuracy: 1.0,
        );

        // Re-lê do Firestore para garantir valores corretos
        final userData = await firestoreService.getUser(userProvider.uid!);
        if (userData != null && mounted) {
          userProvider.updateProgress(
            totalPoints: userData.totalPoints,
            activitiesCompleted: userData.activitiesCompleted,
            level: userData.level,
            progress: userData.progress,
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao salvar progresso: $e');
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

  /// Reseta a atividade
  void _resetActivity() {
    setState(() {
      _shuffledWords.shuffle();
      for (var key in _associations.keys) {
        _associations[key] = null;
      }
      _isCompleted = false;
      _correctMatches = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Associar Palavras'),
        actions: [
          // Botão de reset
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recomeçar',
            onPressed: _resetActivity,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instruções
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Arraste cada palavra para a imagem correspondente',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Área de imagens (drag targets)
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: _wordImagePairs.length,
                  itemBuilder: (context, index) {
                    final pair = _wordImagePairs[index];
                    final associatedWord = _associations[pair.emoji];
                    final isCorrect = associatedWord != null &&
                        _checkMatch(pair.emoji, associatedWord);

                    return _buildImageTarget(
                      pair.emoji,
                      pair.color,
                      associatedWord,
                      isCorrect,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Área de palavras (draggables)
              const Text(
                'Palavras:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _shuffledWords.map((word) {
                    // Verifica se a palavra já foi usada
                    final isUsed = _associations.values.contains(word);
                    return _buildWordDraggable(word, isUsed);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói uma área de imagem (DragTarget)
  Widget _buildImageTarget(
    String emoji,
    Color color,
    String? associatedWord,
    bool isCorrect,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          // Aceita qualquer palavra que não esteja já associada a esta imagem
          return _associations[emoji] != details.data;
        },
        onAcceptWithDetails: (details) {
          _handleAssociation(emoji, details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            decoration: BoxDecoration(
              color: isHovering
                  ? color.withOpacity(0.3)
                  : Colors.white,
              border: Border.all(
                color: isCorrect
                    ? Colors.green
                    : isHovering
                        ? color
                        : Colors.grey.shade300,
                width: isCorrect ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (isCorrect)
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Emoji/Imagem
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),

                // Palavra associada ou placeholder
                Expanded(
                  child: associatedWord != null
                      ? GestureDetector(
                          onTap: () => _removeAssociation(emoji),
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    associatedWord,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isCorrect
                                          ? Colors.green.shade900
                                          : Colors.red.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.close,
                                  color: isCorrect
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Arraste aqui',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Constrói um card de palavra arrastável (Draggable)
  Widget _buildWordDraggable(String word, bool isUsed) {
    return Opacity(
      opacity: isUsed ? 0.3 : 1.0,
      child: Draggable<String>(
        data: word,
        feedback: WordCard(
          word: word,
          isDragging: true,
        ),
        childWhenDragging: WordCard(
          word: word,
          isDragging: true,
        ),
        child: WordCard(
          word: word,
          onTap: isUsed
              ? null
              : () {
                  _speak(word);
                },
        ),
      ),
    );
  }
}

/// Classe auxiliar para armazenar pares palavra-imagem
class WordImagePair {
  final String word;
  final String emoji;
  final Color color;

  WordImagePair({
    required this.word,
    required this.emoji,
    required this.color,
  });
}
