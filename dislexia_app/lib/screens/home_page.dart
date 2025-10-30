// arquivo: lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_service.dart';

/// Tela principal (Home)
/// Exibe menu com atividades disponíveis e informações do usuário
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém dados do usuário logado
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userName ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Letrinhas'),
        elevation: 0,
        actions: [
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () {
              _showLogoutDialog(context, userProvider);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com saudação
              _buildHeader(userName),
              const SizedBox(height: 32),

              // Seção de atividades
              Text(
                'Atividades',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                    ),
              ),
              const SizedBox(height: 16),

              // Grade de cards de atividades
              _buildActivityCard(
                context,
                icon: Icons.image_outlined,
                title: 'Associar Palavras',
                description: 'Combine palavras com imagens correspondentes',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).pushNamed('/activity-match');
                },
              ),
              const SizedBox(height: 16),

              // Placeholder para futuras atividades
              _buildActivityCard(
                context,
                icon: Icons.spellcheck,
                title: 'Soletrar',
                description: 'Em breve...',
                color: Colors.green,
                isLocked: true,
                onTap: () {
                  _showComingSoonDialog(context);
                },
              ),
              const SizedBox(height: 16),

              _buildActivityCard(
                context,
                icon: Icons.record_voice_over,
                title: 'Leitura Guiada',
                description: 'Em breve...',
                color: Colors.orange,
                isLocked: true,
                onTap: () {
                  _showComingSoonDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o cabeçalho com saudação ao usuário
  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),

          // Saudação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Olá,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um card de atividade
  Widget _buildActivityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Ícone da atividade
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),

              // Título e descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Seta indicadora
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostra diálogo de confirmação de logout
  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Faz logout no Firebase
              final authService = AuthService();
              await authService.signOut();

              // Limpa estado do Provider
              userProvider.clearUser();

              // Fecha diálogo e volta para login
              if (context.mounted) {
                Navigator.of(context).pop(); // Fecha diálogo
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo "Em breve"
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em breve'),
        content: const Text('Esta atividade estará disponível em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
