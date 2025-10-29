// arquivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/activity_match_words.dart';

// Ponto de entrada da aplicação
void main() {
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
/// (simulação de autenticação sem backend)
class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  // Getters
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// Simula login do usuário
  /// Em produção, aqui seria feita a chamada ao Firebase/API
  bool login(String email, String password) {
    // Validação simples para o MVP
    if (email.isNotEmpty && password.length >= 6) {
      _userEmail = email;
      _userName = email.split('@')[0]; // Extrai nome do email
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Simula registro de novo usuário
  bool register(String name, String email, String password) {
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _userName = name;
      _userEmail = email;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Faz logout do usuário
  void logout() {
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
