// arquivo: lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

/// Serviço de Autenticação do Firebase
/// Centraliza todas as operações de autenticação
class AuthService {
  // Instância do FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instância do FirestoreService
  final FirestoreService _firestoreService = FirestoreService();

  // Stream do estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  /// Faz login com email e senha
  /// Retorna o User se sucesso, null se erro
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Atualiza último login no Firestore.
      // Erro aqui NÃO falha o login — o usuário já está autenticado.
      if (credential.user != null) {
        try {
          await _firestoreService.createUser(
            uid: credential.user!.uid,
            name: credential.user!.displayName ?? email.split('@')[0],
            email: credential.user!.email!,
          );
        } catch (firestoreError) {
          debugPrint('[AuthService] Aviso: falha ao atualizar Firestore após login (não crítico): $firestoreError');
        }
      }

      return AuthResult(
        success: true,
        user: credential.user,
        message: 'Login realizado com sucesso!',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException no login → code=${e.code} | message=${e.message} | plugin=${e.plugin}');
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code, e.message),
      );
    } catch (e, stackTrace) {
      debugPrint('[AuthService] Erro genérico no login: $e');
      debugPrint('[AuthService] StackTrace: $stackTrace');
      return AuthResult(
        success: false,
        message: 'Erro inesperado. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Registra novo usuário com email e senha
  Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Cria usuário no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Atualiza o nome de exibição do usuário
      await credential.user?.updateDisplayName(name);

      // Recarrega usuário para obter dados atualizados
      await credential.user?.reload();

      // Cria documento do usuário no Firestore.
      // Erro aqui NÃO falha o cadastro — o usuário já está autenticado.
      if (credential.user != null) {
        try {
          await _firestoreService.createUser(
            uid: credential.user!.uid,
            name: name,
            email: email.trim(),
          );
        } catch (firestoreError) {
          debugPrint('[AuthService] Aviso: falha ao criar usuário no Firestore após cadastro (não crítico): $firestoreError');
        }
      }

      return AuthResult(
        success: true,
        user: _auth.currentUser,
        message: 'Cadastro realizado com sucesso!',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException no cadastro → code=${e.code} | message=${e.message} | plugin=${e.plugin}');
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code, e.message),
      );
    } catch (e, stackTrace) {
      debugPrint('[AuthService] Erro genérico no cadastro: $e');
      debugPrint('[AuthService] StackTrace: $stackTrace');
      return AuthResult(
        success: false,
        message: 'Erro inesperado. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Envia email de redefinição de senha
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Email de redefinição enviado! Verifique sua caixa de entrada.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException no reset de senha → code=${e.code} | message=${e.message}');
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code, e.message),
      );
    } catch (e, stackTrace) {
      debugPrint('[AuthService] Erro genérico no reset de senha: $e');
      debugPrint('[AuthService] StackTrace: $stackTrace');
      return AuthResult(
        success: false,
        message: 'Erro ao enviar email. Tente novamente.',
      );
    }
  }

  /// Faz logout do usuário
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Converte códigos de erro do Firebase para mensagens amigáveis em português.
  /// Recebe o [code] do FirebaseAuthException e opcionalmente o [message] detalhado.
  String _getErrorMessage(String code, [String? message]) {
    debugPrint('[AuthService] _getErrorMessage → code=$code | message=$message');
    switch (code) {
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Este usuário foi desabilitado.';
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o email.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este email já está cadastrado. Faça login.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Login com email/senha não está ativado. Contate o suporte.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique email e senha.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'channel-error':
        // Ocorre quando o plugin não consegue comunicar com o SDK nativo
        return 'Erro de comunicação. Verifique sua conexão e tente novamente.';
      case 'unknown':
        // FirebaseAuthException com code "unknown" — analisa o message para
        // dar uma resposta mais específica ao usuário.
        final msg = (message ?? '').toLowerCase();
        if (msg.contains('network') ||
            msg.contains('unable to resolve') ||
            msg.contains('timeout') ||
            msg.contains('connection')) {
          return 'Erro de conexão. Verifique sua internet.';
        }
        if (msg.contains('blocked') || msg.contains('disabled temporarily')) {
          return 'Acesso temporariamente bloqueado. Tente novamente mais tarde.';
        }
        if (msg.contains('password')) {
          return 'Senha inválida. Verifique e tente novamente.';
        }
        if (msg.contains('email')) {
          return 'Email inválido. Verifique e tente novamente.';
        }
        // Fallback: informa o usuário para tentar novamente
        return 'Erro ao autenticar. Verifique sua conexão e tente novamente.';
      default:
        return 'Erro de autenticação ($code). Tente novamente.';
    }
  }
}

/// Classe para retornar resultado de operações de autenticação
class AuthResult {
  final bool success;
  final User? user;
  final String message;

  AuthResult({
    required this.success,
    this.user,
    required this.message,
  });
}
