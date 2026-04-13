// arquivo: lib/screens/activity_match_image.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/accessibility_scaler.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../services/time_tracking_service.dart';
import '../utils/sound_helper.dart';
import '../utils/completion_feedback.dart';
import '../providers/accessibility_provider.dart';

/// Atividade: Relacionar Palavra com Imagem
/// 5 questões sorteadas de um banco de 30 — alternativas embaralhadas a cada sessão.
class ActivityMatchImage extends StatefulWidget {
  const ActivityMatchImage({super.key});

  @override
  State<ActivityMatchImage> createState() => _ActivityMatchImageState();
}

class _ActivityMatchImageState extends State<ActivityMatchImage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TimeTrackingService _timeTracker = TimeTrackingService();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Banco com 30 questões
  static const List<_QuestionData> _questionBank = [
    _QuestionData(
      emoji: '\u{1F436}',
      correct: 'CACHORRO',
      options: ['CACHORRO', 'CAVALO', 'COELHO', 'CAMELO'],
    ),
    _QuestionData(
      emoji: '\u{1F319}',
      correct: 'LUA',
      options: ['LUA', 'SOL', 'CÉU', 'MAR'],
    ),
    _QuestionData(
      emoji: '\u{1F34E}',
      correct: 'MAÇÃ',
      options: ['MAÇÃ', 'BANANA', 'UVA', 'PERA'],
    ),
    _QuestionData(
      emoji: '\u2708\uFE0F',
      correct: 'AVIÃO',
      options: ['AVIÃO', 'CARRO', 'BARCO', 'TREM'],
    ),
    _QuestionData(
      emoji: '\u{1F333}',
      correct: 'ÁRVORE',
      options: ['ÁRVORE', 'FLOR', 'FOLHA', 'GRAMA'],
    ),
    _QuestionData(
      emoji: '\u{1F431}',
      correct: 'GATO',
      options: ['GATO', 'LOBO', 'RAPOSA', 'LEÃO'],
    ),
    _QuestionData(
      emoji: '\u{1F3E0}',
      correct: 'CASA',
      options: ['CASA', 'PRÉDIO', 'LOJA', 'ESCOLA'],
    ),
    _QuestionData(
      emoji: '\u26BD',
      correct: 'BOLA',
      options: ['BOLA', 'RAQUETE', 'BASTÃO', 'LUVA'],
    ),
    _QuestionData(
      emoji: '\u{1F34C}',
      correct: 'BANANA',
      options: ['BANANA', 'LARANJA', 'MANGA', 'ABACAXI'],
    ),
    _QuestionData(
      emoji: '\u{1F697}',
      correct: 'CARRO',
      options: ['CARRO', 'MOTO', 'CAMINHÃO', 'ÔNIBUS'],
    ),
    _QuestionData(
      emoji: '\u{1F338}',
      correct: 'FLOR',
      options: ['FLOR', 'FOLHA', 'GALHO', 'RAIZ'],
    ),
    _QuestionData(
      emoji: '\u{1F981}',
      correct: 'LEÃO',
      options: ['LEÃO', 'TIGRE', 'LEOPARDO', 'JAGUAR'],
    ),
    _QuestionData(
      emoji: '\u{1F41F}',
      correct: 'PEIXE',
      options: ['PEIXE', 'TUBARÃO', 'GOLFINHO', 'POLVO'],
    ),
    _QuestionData(
      emoji: '\u{1F355}',
      correct: 'PIZZA',
      options: ['PIZZA', 'HAMBÚRGUER', 'SANDUÍCHE', 'TACOS'],
    ),
    _QuestionData(
      emoji: '\u{1F4DA}',
      correct: 'LIVRO',
      options: ['LIVRO', 'CADERNO', 'REVISTA', 'JORNAL'],
    ),
    _QuestionData(
      emoji: '\u{1F3B8}',
      correct: 'VIOLÃO',
      options: ['VIOLÃO', 'GUITARRA', 'TECLADO', 'BATERIA'],
    ),
    _QuestionData(
      emoji: '\u{1F98B}',
      correct: 'BORBOLETA',
      options: ['BORBOLETA', 'ABELHA', 'MOSCA', 'VESPA'],
    ),
    _QuestionData(
      emoji: '\u{1F366}',
      correct: 'SORVETE',
      options: ['SORVETE', 'BOLO', 'TORTA', 'PUDIM'],
    ),
    _QuestionData(
      emoji: '\u{1F680}',
      correct: 'FOGUETE',
      options: ['FOGUETE', 'AVIÃO', 'HELICÓPTERO', 'BALÃO'],
    ),
    _QuestionData(
      emoji: '\u{1F995}',
      correct: 'DINOSSAURO',
      options: ['DINOSSAURO', 'CROCODILO', 'IGUANA', 'LAGARTO'],
    ),
    _QuestionData(
      emoji: '\u{1F383}',
      correct: 'ABÓBORA',
      options: ['ABÓBORA', 'CENOURA', 'TOMATE', 'BETERRABA'],
    ),
    _QuestionData(
      emoji: '\u{1F418}',
      correct: 'ELEFANTE',
      options: ['ELEFANTE', 'RINOCERONTE', 'HIPOPÓTAMO', 'GIRAFA'],
    ),
    _QuestionData(
      emoji: '\u{1F3D6}\uFE0F',
      correct: 'PRAIA',
      options: ['PRAIA', 'FLORESTA', 'DESERTO', 'MONTANHA'],
    ),
    _QuestionData(
      emoji: '\u{1F308}',
      correct: 'ARCO-ÍRIS',
      options: ['ARCO-ÍRIS', 'NUVEM', 'CHUVA', 'TROVÃO'],
    ),
    _QuestionData(
      emoji: '\u{1F370}',
      correct: 'BOLO',
      options: ['BOLO', 'TORTA', 'SORVETE', 'DONUT'],
    ),
    _QuestionData(
      emoji: '\u{1F986}',
      correct: 'PATO',
      options: ['PATO', 'GANSO', 'CISNE', 'PELICANO'],
    ),
    _QuestionData(
      emoji: '\u{1F422}',
      correct: 'TARTARUGA',
      options: ['TARTARUGA', 'JABUTI', 'LAGARTO', 'CAMALEÃO'],
    ),
    _QuestionData(
      emoji: '\u{1F33B}',
      correct: 'GIRASSOL',
      options: ['GIRASSOL', 'ROSA', 'TULIPA', 'ORQUÍDEA'],
    ),
    _QuestionData(
      emoji: '\u{1F347}',
      correct: 'UVA',
      options: ['UVA', 'AMORA', 'FRAMBOESA', 'MORANGO'],
    ),
    _QuestionData(
      emoji: '\u{1F511}',
      correct: 'CHAVE',
      options: ['CHAVE', 'CADEADO', 'PORTA', 'FECHADURA'],
    ),
  ];

  // Questões da sessão (5 sorteadas e com alternativas embaralhadas)
  late List<_Question> _questions;

  static const List<String> _comfortMessages = [
    'Quase! Vamos tentar de novo 😊',
    'Você consegue! Tente outra vez 💪',
    'Não desista! Mais uma tentativa 🌟',
    'Continue tentando! Vai conseguir 🎯',
  ];

  // Estado da atividade
  int _currentQuestion = 0;
  int _score = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;

  // Feedback visual
  String? _selectedOption;
  bool? _lastAnswerCorrect;
  bool _isProcessing = false;
  bool _showFeedback = false;
  Timer? _advanceTimer;
  int _wrongAttempts = 0;

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

    // Embaralha o banco, seleciona 5, embaralha alternativas de cada uma
    final shuffled = List<_QuestionData>.from(_questionBank)..shuffle();
    _questions = shuffled.take(5).map((data) {
      final opts = List<String>.from(data.options)..shuffle();
      return _Question(emoji: data.emoji, correct: data.correct, options: opts);
    }).toList();

    // Inicia contagem de tempo da sessão (invisível para a criança)
    _timeTracker.startSession();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Processa a resposta do usuário com sistema de duas tentativas
  void _handleAnswer(String option) {
    if (_isProcessing) return;

    final question = _questions[_currentQuestion];
    final isCorrect = option == question.correct;
    final newWrongAttempts = isCorrect ? _wrongAttempts : _wrongAttempts + 1;
    final applyPenalty = !isCorrect && newWrongAttempts >= 2;

    setState(() {
      _isProcessing = true;
      _showFeedback = true;
      _selectedOption = option;
      _totalAttempts++;
      _lastAnswerCorrect = isCorrect;
      if (!isCorrect) _wrongAttempts = newWrongAttempts;
      if (isCorrect) {
        _score += 20;
        _correctCount++;
      } else if (applyPenalty) {
        _score -= 10;
      }
    });

    if (isCorrect) {
      SoundHelper.playCorrect();
      _confettiController.play();
      _advanceTimer = Timer(const Duration(milliseconds: 1500), _goToNext);
    } else {
      SoundHelper.playWrong();
      _shakeController.forward(from: 0);
      if (applyPenalty) {
        _advanceTimer = Timer(const Duration(milliseconds: 1500), _goToNext);
      } else {
        _advanceTimer = Timer(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() {
            _isProcessing = false;
            _showFeedback = false;
            _selectedOption = null;
            _lastAnswerCorrect = null;
          });
        });
      }
    }
  }

  void _goToNext() {
    if (!mounted) return;
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
        _lastAnswerCorrect = null;
        _isProcessing = false;
        _showFeedback = false;
        _wrongAttempts = 0;
      });
    } else {
      _showCompletionDialog();
    }
  }

  /// Salva progresso da atividade no Firestore
  Future<void> _saveProgress() async {
    // Para o cronômetro e obtém a duração da sessão em segundos
    final sessionDuration = _timeTracker.stopSession();
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.uid != null) {
        await _firestoreService.completeActivity(
          uid: userProvider.uid!,
          activityId: 'match-image',
          activityName: 'Relacionar Palavra com Imagem',
          points: _score,
          attempts: _totalAttempts,
          accuracy: _correctCount / 5,
          durationSeconds: sessionDuration,
        );

        // Re-lê do Firestore para garantir valores corretos
        final userData = await _firestoreService.getUser(userProvider.uid!);
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

  /// Salva progresso no Firestore e mostra diálogo de conclusão
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
    final accessibility = Provider.of<AccessibilityProvider>(context);
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relacionar Palavra com Imagem',
          style: TextStyle(fontSize: 18 * accessibility.fontSize),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra de progresso e pontuação
                  _buildProgressBar(accessibility),
                  const SizedBox(height: 16),

                  // Instrução
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 24 * accessibility.iconSize,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Qual é a palavra que representa esta imagem?',
                              style: TextStyle(
                                fontSize: 16 * accessibility.fontSize,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emoji grande centralizado
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          question.emoji,
                          style: TextStyle(fontSize: 100 * accessibility.iconSize),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Opções de palavras (4 botões em grid 2x2) com shake
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                            _isProcessing && _lastAnswerCorrect == false
                                ? _shakeAnimation.value
                                : 0,
                            0),
                        child: child,
                      ),
                      child: _buildOptions(question, accessibility),
                    ),
                  ),

                  // Feedback de conforto / erro / acerto
                  if (_showFeedback) ...[
                    const SizedBox(height: 12),
                    _buildFeedback(),
                  ],
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

  /// Constrói a barra de progresso e pontuação
  Widget _buildProgressBar(AccessibilityProvider accessibility) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indicador de questão
        Text(
          'Questão ${_currentQuestion + 1} de ${_questions.length}',
          style: TextStyle(
            fontSize: 16 * accessibility.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        // Pontuação
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: 20 * accessibility.iconSize,
              ),
              const SizedBox(width: 4),
              Text(
                '$_score pts',
                style: TextStyle(
                  fontSize: 16 * accessibility.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói o grid de opções
  Widget _buildOptions(_Question question, AccessibilityProvider accessibility) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: question.options.map((option) {
        return _buildOptionButton(option, question, accessibility);
      }).toList(),
    );
  }

  /// Constrói um botão de opção
  Widget _buildOptionButton(
    String option,
    _Question question,
    AccessibilityProvider accessibility,
  ) {
    final isSelected = _selectedOption == option;
    final bool isCorrectOption = option == question.correct;

    // Determina a cor do botão baseado no estado
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isSelected && _lastAnswerCorrect == true && isCorrectOption) {
      // Resposta correta selecionada
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
    } else if (isSelected && _lastAnswerCorrect == false && !isCorrectOption) {
      // Resposta errada selecionada
      backgroundColor = Colors.red.shade100;
      borderColor = Colors.red;
      textColor = Colors.red.shade900;
    } else if (_isProcessing && _lastAnswerCorrect == false && _wrongAttempts >= 2 && isCorrectOption) {
      // Revela a resposta correta na segunda tentativa errada
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
    } else {
      // Estado padrão
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade900;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isProcessing ? null : () => _handleAnswer(option),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3 : 2,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected && _lastAnswerCorrect == true && isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedScale(
                      scale: 1.2,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24 * accessibility.iconSize,
                      ),
                    ),
                  ),
                if (isSelected && _lastAnswerCorrect == false && !isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 24 * accessibility.iconSize,
                    ),
                  ),
                if (!isSelected && _isProcessing && _lastAnswerCorrect == false && _wrongAttempts >= 2 && isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24 * accessibility.iconSize,
                    ),
                  ),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 18 * accessibility.fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final Color color;
    final IconData icon;
    final String message;
    if (_lastAnswerCorrect == true) {
      color = Colors.green;
      icon = Icons.check_circle;
      message = 'Correto! +20 pontos';
    } else if (_wrongAttempts == 1) {
      color = Colors.orange;
      icon = Icons.emoji_emotions_outlined;
      message = _comfortMessages[_currentQuestion % _comfortMessages.length];
    } else {
      color = Colors.red;
      icon = Icons.cancel;
      message = 'Errado! -10 pontos';
    }
    return AnimatedOpacity(
      opacity: _showFeedback ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: context.scaleIcon(28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.scaleFont(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dados imutáveis do banco de questões
class _QuestionData {
  final String emoji;
  final String correct;
  final List<String> options;

  const _QuestionData({
    required this.emoji,
    required this.correct,
    required this.options,
  });
}

/// Modelo de dados para cada questão da sessão (alternativas já embaralhadas)
class _Question {
  final String emoji;
  final String correct;
  final List<String> options;

  _Question({
    required this.emoji,
    required this.correct,
    required this.options,
  });
}
