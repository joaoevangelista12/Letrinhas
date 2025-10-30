// arquivo: lib/main.dart

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

  // Inicializa o Firebase
  await Firebase.initializeApp();

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
/// Agora usando Firebase Authentication
class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  // Getters
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// Atualiza estado do usuário com dados do Firebase
  void updateUser(String email, String? displayName) {
    _userEmail = email;
    _userName = displayName ?? email.split('@')[0];
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Limpa estado do usuário
  void clearUser() {
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
