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

// Ponto de entrada da aplicação
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

/// Classe principal do aplicativo
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

/// Provider para gerenciar estado do usuário
/// Agora usando Firebase Authentication e Firestore
class UserProvider extends ChangeNotifier {
  String? _uid;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;
  int _totalPoints = 0;
  int _activitiesCompleted = 0;
  int _level = 1;
  double _levelProgress = 0.0;

  // Getters
  String? get uid => _uid;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  int get totalPoints => _totalPoints;
  int get activitiesCompleted => _activitiesCompleted;
  int get level => _level;
  double get levelProgress => _levelProgress;

  /// Atualiza estado do usuário com dados do Firebase
  void updateUser(String uid, String email, String? displayName) {
    _uid = uid;
    _userEmail = email;
    _userName = displayName ?? email.split('@')[0];
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Atualiza progresso do usuário com dados do Firestore
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

  /// Limpa estado do usuário
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
