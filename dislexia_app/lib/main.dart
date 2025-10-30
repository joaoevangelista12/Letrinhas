// arquivo: lib/main.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/activity_match_words.dart';

// Ponto de entrada da aplicação
void main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com suporte para Web
  if (kIsWeb) {
    // Configuração Firebase para Web
    // IMPORTANTE: Substitua os valores abaixo com suas credenciais do Firebase Console
    // Para obter estas credenciais:
    // 1. Acesse Firebase Console (https://console.firebase.google.com)
    // 2. Selecione seu projeto
    // 3. Vá em Project Settings > General
    // 4. Role até "Your apps" e clique no ícone Web (</>)
    // 5. Copie os valores do firebaseConfig
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY_HERE",
        authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_PROJECT_ID.firebasestorage.app",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
        measurementId: "YOUR_MEASUREMENT_ID", // opcional
      ),
    );
  } else {
    // Para Android/iOS, usa o arquivo google-services.json / GoogleService-Info.plist
    await Firebase.initializeApp();
  }

  runApp(
    // Provider para gerenciar estado do usuário globalmente
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const DislexiaApp(),
    ),
  );
}

/// Classe principal do aplicativo
class DislexiaApp extends StatelessWidget {
  const DislexiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dislexia App - MVP',
      debugShowCheckedModeBanner: false,

      // Tema com cores acessíveis e alto contraste
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // Tamanhos de fonte maiores para facilitar leitura
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),

        // Botões com cantos arredondados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        useMaterial3: true,
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
