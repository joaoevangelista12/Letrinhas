// arquivo: lib/screens/register_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

/// Tela de Cadastro
/// Permite que novos usuários se registrem no app
/// Validações: nome não vazio, email válido, senha >= 6 caracteres
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Chave para validação do formulário
  final _formKey = GlobalKey<FormState>();

  // Controla visibilidade das senhas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Indicador de carregamento
  bool _isLoading = false;

  @override
  void dispose() {
    // Libera recursos dos controladores
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida nome (não pode ser vazio)
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu nome';
    }
    if (value.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  /// Valida email (deve conter @)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu email';
    }
    if (!value.contains('@')) {
      return 'Email inválido';
    }
    return null;
  }

  /// Valida senha (mínimo 6 caracteres)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite sua senha';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  /// Valida confirmação de senha
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  /// Realiza o cadastro usando Firebase Authentication
  void _handleRegister() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Tenta registrar usando Firebase
    final authService = AuthService();
    final result = await authService.registerWithEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success && result.user != null) {
      // Atualiza o Provider com dados do usuário
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateUser(
        result.user!.email!,
        result.user!.displayName,
      );

      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navega para home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Mostra erro do Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  'Criar conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),

                // Subtítulo
                Text(
                  'Preencha os dados abaixo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                // Campo de Nome
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nome completo',
                    hintText: 'Seu nome',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Campo de Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'seu@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validatePassword,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Campo de Confirmar Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha',
                    hintText: 'Digite a senha novamente',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 32),

                // Botão de Cadastrar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Cadastrar',
                        onPressed: _handleRegister,
                      ),
                const SizedBox(height: 16),

                // Link para login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
