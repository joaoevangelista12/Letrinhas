// arquivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/accessibility_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/activity_vowels_consonants.dart';
import 'screens/activity_recognize_letters.dart';
import 'screens/activity_syllabic.dart';
import 'screens/activity_form_word.dart';
import 'screens/activity_match_image.dart';
import 'screens/settings_page.dart';
import 'screens/profile_page.dart';
import 'models/activity_model.dart';
import 'widgets/protected_activity.dart';

/// Ponto de entrada da aplicação Letrinhas.
///
/// Inicializa o Firebase e configura os providers globais:
/// - [UserProvider]: Gerencia autenticação e progresso do usuário
/// - [AccessibilityProvider]: Gerencia configurações de acessibilidade
///
/// O Firebase é configurado automaticamente para a plataforma atual
/// (Web, Android ou iOS) usando [DefaultFirebaseOptions].

Future<void> _validateCriticalAssets() async {
  const requiredAssets = [
    'assets/fonts/OpenDyslexic-Regular.ttf',
    'assets/fonts/OpenDyslexic-Bold.ttf',
  ];

  for (final assetPath in requiredAssets) {
    try {
      await rootBundle.load(assetPath);
    } catch (e) {
      throw FlutterError(
        'Asset obrigatório não encontrado: $assetPath. '
        'Sem esse arquivo o Flutter usa Roboto como fallback. Erro original: $e',
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard contra "duplicate-app" no hot-restart: o processo nativo Android
  // permanece vivo entre restarts, mas Firebase.apps se esvazia no lado Dart.
  // O google-services plugin foi removido do build e o FirebaseInitProvider
  // está desabilitado no AndroidManifest, portanto este guard é confiável.
  await _validateCriticalAssets();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
/// - Fonte OpenDyslexic fixa em toda a interface
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessibilityProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return MaterialApp(
      title: 'Letrinhas',
      debugShowCheckedModeBanner: false,

      theme: accessibilityProvider.highContrast
          ? AppTheme.getHighContrastTheme(
              fontSizeMultiplier: accessibilityProvider.fontSize,
              iconSizeMultiplier: accessibilityProvider.iconSize,
            )
          : AppTheme.getColorfulTheme(
              fontSizeMultiplier: accessibilityProvider.fontSize,
              iconSizeMultiplier: accessibilityProvider.iconSize,
            ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),

        // Atividades protegidas por nível
        '/activity-vowels-consonants': (context) => const ProtectedActivity(
              activityId: Activities.vowelsConsonantsId,
              child: ActivityVowelsConsonants(),
            ),
        '/activity-recognize-letters': (context) => const ProtectedActivity(
              activityId: Activities.recognizeLettersId,
              child: ActivityRecognizeLetters(),
            ),
        '/activity-syllabic': (context) => const ProtectedActivity(
              activityId: Activities.syllabicId,
              child: ActivitySyllabic(),
            ),
        '/activity-form-word': (context) => const ProtectedActivity(
              activityId: Activities.formWordId,
              child: ActivityFormWord(),
            ),
        '/activity-match-image': (context) => const ProtectedActivity(
              activityId: Activities.matchImageId,
              child: ActivityMatchImage(),
            ),

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
/// **Sistema de Gamificação e Progressão:**
/// - [level]: Nível explícito do usuário (gerenciado pelo backend)
/// - [levelProgress]: Progresso no nível atual (0.0 a 1.0)
/// - [totalPoints]: Total de pontos acumulados
/// - [activitiesCompleted]: Número de atividades completadas
///
/// **Sistema de Níveis:**
/// - Usuário começa no nível 1 ao criar conta
/// - Sobe de nível ao completar atividades específicas
/// - Cada nível desbloqueia novas atividades
///
/// **Exemplo de uso:**
/// ```dart
/// final userProvider = context.read<UserProvider>();
/// userProvider.updateProgress(
///   totalPoints: 150,
///   activitiesCompleted: 3,
///   level: 2,
/// );
/// ```
class UserProvider extends ChangeNotifier {
  String? _uid;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;
  int _totalPoints = 0;
  int _activitiesCompleted = 0;
  int _level = 1;
  int _progress = 0; // Progresso dentro do nível (0-100)

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
  /// Gerenciado explicitamente pelo backend ao completar atividades
  int get level => _level;

  /// Progresso dentro do nível atual (0-100)
  int get progress => _progress;

  /// Progresso no nível atual como porcentagem (0.0 a 1.0)
  double get levelProgress => _progress / 100.0;

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
  /// Sincroniza os dados do usuário com os valores do Firestore.
  ///
  /// [totalPoints]: Total de pontos acumulados
  /// [activitiesCompleted]: Número de atividades completadas
  /// [level]: Nível atual do usuário (gerenciado pelo backend)
  /// [progress]: Progresso dentro do nível atual (0-100)
  ///
  /// **Sistema de Progressão:**
  /// - O nível é gerenciado explicitamente pelo backend
  /// - Progresso é incrementado a cada atividade concluída
  /// - Ao atingir 100 de progresso, sobe de nível automaticamente
  ///
  /// **Exemplos:**
  /// ```dart
  /// // Usuário nível 1 com 50 de progresso
  /// updateProgress(totalPoints: 50, activitiesCompleted: 1, level: 1, progress: 50)
  /// // level = 1, progress = 50, levelProgress = 0.5
  ///
  /// // Usuário nível 2 com 0 de progresso (acabou de subir)
  /// updateProgress(totalPoints: 150, activitiesCompleted: 3, level: 2, progress: 0)
  /// // level = 2, progress = 0, levelProgress = 0.0
  /// ```
  void updateProgress({
    required int totalPoints,
    required int activitiesCompleted,
    int? level,
    int? progress,
  }) {
    _totalPoints = totalPoints;
    _activitiesCompleted = activitiesCompleted;

    // Usa o nível explícito do backend se fornecido
    if (level != null) {
      _level = level;
    }

    // Usa o progresso explícito do backend se fornecido
    if (progress != null) {
      _progress = progress;
    }

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
  /// - progress: 0
  void clearUser() {
    _uid = null;
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    _totalPoints = 0;
    _activitiesCompleted = 0;
    _level = 1;
    _progress = 0;
    notifyListeners();
  }
}
