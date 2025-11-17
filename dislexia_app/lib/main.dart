// arquivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/accessibility_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/activity_match_words.dart';
import 'screens/activity_complete_word.dart';
import 'screens/activity_order_syllables.dart';
import 'screens/activity_read_sentences.dart';
import 'screens/activity_audio_image.dart';
import 'screens/settings_page.dart';
import 'screens/profile_page.dart';

/// Ponto de entrada da aplicação Letrinhas.
///
/// Inicializa o Firebase e configura os providers globais:
/// - [UserProvider]: Gerencia autenticação e progresso do usuário
/// - [AccessibilityProvider]: Gerencia configurações de acessibilidade
///
/// O Firebase é configurado automaticamente para a plataforma atual
/// (Web, Android ou iOS) usando [DefaultFirebaseOptions].
void main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase usando firebase_options.dart
  // Detecta automaticamente a plataforma (Web, Android, iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // MultiProvider para gerenciar múltiplos estados globalmente
    MultiProvider(
      providers: [
        // Provider do usuário
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Provider de acessibilidade
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: const DislexiaApp(),
    ),
  );
}

/// Widget raiz da aplicação Letrinhas.
///
/// Gerencia o MaterialApp e aplica o tema dinâmico baseado nas
/// configurações de acessibilidade do usuário.
///
/// O app suporta dois temas:
/// - **Tema colorido**: Padrão, com cores vibrantes para engajamento
/// - **Tema alto contraste**: Preto e branco para melhor legibilidade
///
/// Ambos os temas respeitam:
/// - Tamanho de fonte configurável (0.8x a 1.4x)
/// - Fonte OpenDyslexic opcional
/// - Tamanho de ícones ajustável
class DislexiaApp extends StatefulWidget {
  const DislexiaApp({super.key});

  @override
  State<DislexiaApp> createState() => _DislexiaAppState();
}

class _DislexiaAppState extends State<DislexiaApp> {
  @override
  void initState() {
    super.initState();
    // Carrega configurações de acessibilidade salvas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessibilityProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observa mudanças nas configurações de acessibilidade
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return MaterialApp(
      title: 'Letrinhas',
      debugShowCheckedModeBanner: false,

      // Tema dinâmico baseado nas configurações de acessibilidade
      theme: accessibilityProvider.highContrast
          ? AppTheme.getHighContrastTheme(
              useDyslexicFont: accessibilityProvider.useDyslexicFont,
              fontSizeMultiplier: accessibilityProvider.fontSize,
            )
          : AppTheme.getColorfulTheme(
              useDyslexicFont: accessibilityProvider.useDyslexicFont,
              fontSizeMultiplier: accessibilityProvider.fontSize,
            ),

      // Tela inicial do app
      initialRoute: '/',

      // Definição de rotas nomeadas para navegação
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/activity-match': (context) => const ActivityMatchWords(),
        '/activity-complete-word': (context) => const ActivityCompleteWord(),
        '/activity-order-syllables': (context) => const ActivityOrderSyllables(),
        '/activity-read-sentences': (context) => const ActivityReadSentences(),
        '/activity-audio-image': (context) => const ActivityAudioImage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

/// Provider para gerenciar estado de autenticação e progresso do usuário.
///
/// Integra com Firebase Authentication e Firestore para sincronizar
/// dados do usuário em tempo real.
///
/// **Sistema de Gamificação:**
/// - Cada 100 pontos = 1 nível
/// - [level]: Nível atual do usuário (calculado automaticamente)
/// - [levelProgress]: Progresso no nível atual (0.0 a 1.0)
/// - [totalPoints]: Total de pontos acumulados
/// - [activitiesCompleted]: Número de atividades completadas
///
/// **Exemplo de uso:**
/// ```dart
/// final userProvider = context.read<UserProvider>();
/// userProvider.updateProgress(totalPoints: 250, activitiesCompleted: 5);
/// // Resultado: level = 3, levelProgress = 0.5 (50 de 100 pontos)
/// ```
class UserProvider extends ChangeNotifier {
  String? _uid;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;
  int _totalPoints = 0;
  int _activitiesCompleted = 0;
  int _level = 1;
  double _levelProgress = 0.0;

  // Getters públicos para acesso aos dados do usuário

  /// UID do usuário no Firebase Authentication
  String? get uid => _uid;

  /// Nome de exibição do usuário (usa email se displayName não disponível)
  String? get userName => _userName;

  /// Email do usuário
  String? get userEmail => _userEmail;

  /// Indica se usuário está autenticado
  bool get isLoggedIn => _isLoggedIn;

  /// Total de pontos acumulados pelo usuário
  int get totalPoints => _totalPoints;

  /// Número total de atividades completadas
  int get activitiesCompleted => _activitiesCompleted;

  /// Nível atual do usuário (1, 2, 3, etc.)
  /// Calculado como: (totalPoints / 100) + 1
  int get level => _level;

  /// Progresso no nível atual (0.0 a 1.0)
  /// Calculado como: (totalPoints % 100) / 100
  double get levelProgress => _levelProgress;

  /// Atualiza informações básicas do usuário após autenticação.
  ///
  /// Chamado após login ou registro bem-sucedido no Firebase Authentication.
  ///
  /// [uid]: UID único do usuário no Firebase
  /// [email]: Email do usuário
  /// [displayName]: Nome de exibição (opcional). Se null, usa parte do email antes do @
  ///
  /// **Exemplo:**
  /// ```dart
  /// userProvider.updateUser('abc123', 'joao@email.com', 'João Silva');
  /// // userName será 'João Silva'
  ///
  /// userProvider.updateUser('abc123', 'maria@email.com', null);
  /// // userName será 'maria' (extraído do email)
  /// ```
  void updateUser(String uid, String email, String? displayName) {
    _uid = uid;
    _userEmail = email;
    _userName = displayName ?? email.split('@')[0];
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Atualiza progresso e gamificação do usuário.
  ///
  /// Recalcula automaticamente [level] e [levelProgress] baseado nos pontos.
  ///
  /// [totalPoints]: Total de pontos acumulados
  /// [activitiesCompleted]: Número de atividades completadas
  ///
  /// **Cálculos:**
  /// - Nível = (totalPoints / 100) + 1
  /// - Progresso = (totalPoints % 100) / 100
  ///
  /// **Exemplos:**
  /// ```dart
  /// updateProgress(totalPoints: 0, activitiesCompleted: 0)
  /// // level = 1, levelProgress = 0.0
  ///
  /// updateProgress(totalPoints: 150, activitiesCompleted: 3)
  /// // level = 2, levelProgress = 0.5 (50 de 100 pontos)
  ///
  /// updateProgress(totalPoints: 250, activitiesCompleted: 5)
  /// // level = 3, levelProgress = 0.5 (50 de 100 pontos)
  /// ```
  void updateProgress({
    required int totalPoints,
    required int activitiesCompleted,
  }) {
    _totalPoints = totalPoints;
    _activitiesCompleted = activitiesCompleted;
    _level = (totalPoints / 100).floor() + 1;
    _levelProgress = (totalPoints % 100) / 100;
    notifyListeners();
  }

  /// Limpa todos os dados do usuário (logout).
  ///
  /// Reseta todos os campos para seus valores padrão e notifica listeners.
  /// Deve ser chamado quando o usuário faz logout.
  ///
  /// **Valores após clear:**
  /// - uid, userName, userEmail: null
  /// - isLoggedIn: false
  /// - totalPoints, activitiesCompleted: 0
  /// - level: 1
  /// - levelProgress: 0.0
  void clearUser() {
    _uid = null;
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    _totalPoints = 0;
    _activitiesCompleted = 0;
    _level = 1;
    _levelProgress = 0.0;
    notifyListeners();
  }
}
