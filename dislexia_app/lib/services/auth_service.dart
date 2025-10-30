// arquivo: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

/// Serviço de Autenticação do Firebase
/// Centraliza todas as operações de autenticação
class AuthService {
  // Instância do FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      return AuthResult(
        success: true,
        user: credential.user,
        message: 'Login realizado com sucesso!',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Erro desconhecido: $e',
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
      // Cria usuário no Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Atualiza o nome de exibição do usuário
      await credential.user?.updateDisplayName(name);

      // Recarrega usuário para obter dados atualizados
      await credential.user?.reload();

      return AuthResult(
        success: true,
        user: _auth.currentUser,
        message: 'Cadastro realizado com sucesso!',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Erro desconhecido: $e',
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
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Erro ao enviar email: $e',
      );
    }
  }

  /// Faz logout do usuário
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Converte códigos de erro do Firebase para mensagens amigáveis em português
  String _getErrorMessage(String code) {
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
        return 'Operação não permitida. Contate o suporte.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique email e senha.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro: $code';
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
