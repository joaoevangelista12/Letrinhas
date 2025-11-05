// arquivo: lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

/// Tela principal (Home)
/// Exibe menu com atividades disponíveis e informações do usuário
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carrega dados do usuário do Firestore
  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        final userData = await _firestoreService.getUser(userProvider.uid!);

        if (userData != null && mounted) {
          userProvider.updateProgress(
            totalPoints: userData.totalPoints,
            activitiesCompleted: userData.activitiesCompleted,
          );
        }
      } catch (e) {
        debugPrint('Erro ao carregar dados: $e');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

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
          // Botão de configurações
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
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
              const SizedBox(height: 24),

              // Cards de Progresso
              if (!_isLoading) ...[
                _buildProgressCards(userProvider),
                const SizedBox(height: 32),
              ],

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

  /// Constrói cards de progresso do usuário
  Widget _buildProgressCards(UserProvider userProvider) {
    return Column(
      children: [
        // Título da seção
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Seu Progresso',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grade de cards
        Row(
          children: [
            // Card de Pontos
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                label: 'Pontos',
                value: userProvider.totalPoints.toString(),
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),

            // Card de Nível
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                label: 'Nível',
                value: userProvider.level.toString(),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),

            // Card de Atividades
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Completas',
                value: userProvider.activitiesCompleted.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Barra de progresso de nível
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso do Nível ${userProvider.level}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(userProvider.levelProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: userProvider.levelProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Faltam ${(100 - userProvider.levelProgress * 100).toInt()} pontos para o nível ${userProvider.level + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói card de estatística individual
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
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
