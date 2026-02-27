// arquivo: lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../widgets/level_progress_bar.dart';

/// Tela principal (Home)
/// Exibe menu com atividades disponíveis e informações do usuário
/// IMPLEMENTA SISTEMA DE NÍVEIS: Mostra atividades bloqueadas/desbloqueadas
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  UserModel? _userData;

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
          setState(() {
            _userData = userData;
          });

          userProvider.updateProgress(
            totalPoints: userData.totalPoints,
            activitiesCompleted: userData.activitiesCompleted,
            level: userData.level, // Atualiza nível no provider
            progress: userData.progress, // Atualiza progresso no provider
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
    final userLevel = _userData?.level ?? 1;

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
              _buildHeader(userName, userLevel),
              const SizedBox(height: 24),

              // Cards de Progresso
              if (!_isLoading && _userData != null) ...[
                _buildProgressCards(_userData!),
                const SizedBox(height: 32),
              ],

              // Seção de atividades
              Text(
                'Atividades',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete atividades para desbloquear novos níveis!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),

              // Lista dinâmica de atividades baseada no nível
              ...Activities.all.map((activity) {
                final isLocked = !activity.canAccess(userLevel);
                final isCompleted = _userData?.completedActivities.contains(activity.id) ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildActivityCard(
                    context,
                    activity: activity,
                    isLocked: isLocked,
                    isCompleted: isCompleted,
                    userLevel: userLevel,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói cards de progresso do usuário
  Widget _buildProgressCards(UserModel userData) {
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
            // Card de Nível (DESTAQUE)
            Expanded(
              flex: 2,
              child: _buildStatCard(
                icon: Icons.emoji_events,
                label: 'Nível',
                value: userData.level.toString(),
                color: Colors.purple,
                highlight: true,
              ),
            ),
            const SizedBox(width: 12),

            // Card de Pontos
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                label: 'Pontos',
                value: userData.totalPoints.toString(),
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),

            // Card de Atividades
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Completas',
                value: userData.activitiesCompleted.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Barra de progresso visual animada
        LevelProgressBar(
          level: userData.level,
          progress: userData.progress,
        ),
        const SizedBox(height: 16),

        // Info sobre próximo nível
        _buildNextLevelInfo(userData),
      ],
    );
  }

  /// Card de estatística individual
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool highlight = false,
  }) {
    return Container(
      padding: EdgeInsets.all(highlight ? 20 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(highlight ? 0.5 : 0.3),
          width: highlight ? 2.5 : 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: highlight ? 32 : 28),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: highlight ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Info sobre próximo nível
  Widget _buildNextLevelInfo(UserModel userData) {
    final nextLevel = Activities.getNextRequiredLevel(userData.level);

    if (nextLevel == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parabéns! 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Você completou todas as atividades disponíveis!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final lockedActivities = Activities.getLockedActivities(userData.level);
    final nextActivity = lockedActivities.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.blue.shade700, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo Desafio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chegue ao nível $nextLevel para desbloquear:\n${nextActivity.name}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o cabeçalho com saudação ao usuário (clicável → perfil)
  Widget _buildHeader(String userName, int userLevel) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/profile'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
        children: [
          // Avatar com badge de nível
          Stack(
            children: [
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$userLevel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
                const SizedBox(height: 4),
                Text(
                  'Nível $userLevel',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ), // Row
      ), // Padding
    ),   // Ink
  ),     // InkWell
    );   // Material
  }

  /// Constrói um card de atividade com sistema de bloqueio
  Widget _buildActivityCard(
    BuildContext context, {
    required ActivityModel activity,
    required bool isLocked,
    required bool isCompleted,
    required int userLevel,
  }) {
    // Define ícones e cores baseado no tipo de atividade
    final IconData icon;
    final Color color;

    switch (activity.id) {
      case Activities.vowelsConsonantsId:
        icon = Icons.spellcheck;
        color = Colors.teal;
        break;
      case Activities.recognizeLettersId:
        icon = Icons.font_download;
        color = Colors.purple;
        break;
      case Activities.syllabicId:
        icon = Icons.abc;
        color = Colors.blue;
        break;
      case Activities.formWordId:
        icon = Icons.extension;
        color = Colors.green;
        break;
      case Activities.matchImageId:
        icon = Icons.image_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.assignment;
        color = Colors.grey;
    }

    return Card(
      elevation: isLocked ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: Colors.green.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isLocked
            ? () => _showLockedDialog(context, activity)
            : () async {
                await Navigator.of(context).pushNamed(activity.route);
                _loadUserData(); // Recarrega dados ao voltar da atividade
              },
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Ícone da atividade com badge de status
                Stack(
                  children: [
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
                        color: isLocked ? Colors.grey : color,
                      ),
                    ),
                    if (isCompleted)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Título e descrição
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLocked ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                          if (isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Nível ${activity.requiredLevel}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked
                            ? 'Complete atividades anteriores para desbloquear'
                            : activity.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!isLocked && !isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '+${activity.points} pontos',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '✓ Completada',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Seta indicadora
                Icon(
                  isLocked ? Icons.lock : Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostra diálogo informando que a atividade está bloqueada
  void _showLockedDialog(BuildContext context, ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Atividade Bloqueada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você precisa estar no nível ${activity.requiredLevel} para acessar esta atividade.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Dica:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Complete as atividades anteriores para subir de nível e desbloquear novas atividades!',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
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
}
