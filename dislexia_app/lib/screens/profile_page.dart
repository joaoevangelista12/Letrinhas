// arquivo: lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../providers/accessibility_provider.dart';

/// Tela de Perfil e Progresso
/// Exibe informações do usuário e progresso detalhado em cada atividade
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userData;
  List<ActivityProgress> _activityHistory = [];
  bool _isLoading = true;

  // IDs válidos das atividades atuais (fonte de verdade: activity_model.dart)
  static final Set<String> _validActivityIds = Activities.all.map((a) => a.id).toSet();

  // Lista de todas as atividades disponíveis no app
  final List<Map<String, dynamic>> _allActivities = [
    {
      'id': Activities.recognizeLettersId,
      'name': 'Reconhecendo Letras',
      'icon': Icons.abc,
      'color': Colors.teal,
      'maxPoints': 100,
    },
    {
      'id': Activities.syllabicId,
      'name': 'Atividade Silabica',
      'icon': Icons.text_fields,
      'color': Colors.blue,
      'maxPoints': 100,
    },
    {
      'id': Activities.formWordId,
      'name': 'Formar Palavra com Silabas',
      'icon': Icons.extension,
      'color': Colors.deepPurple,
      'maxPoints': 100,
    },
    {
      'id': Activities.matchImageId,
      'name': 'Relacionar Palavra com Imagem',
      'icon': Icons.image_outlined,
      'color': Colors.orange,
      'maxPoints': 100,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carrega dados do usuário e histórico de atividades
  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.uid != null) {
      try {
        // Busca dados do usuário
        final userData = await _firestoreService.getUser(userProvider.uid!);

        // Busca histórico de atividades
        final activityHistory = await _firestoreService.getUserActivities(userProvider.uid!);

        if (mounted) {
          // Filtra histórico para exibir apenas atividades que existem no app
          final filteredHistory = activityHistory
              .where((a) => _validActivityIds.contains(a.activityId))
              .toList();

          setState(() {
            _userData = userData;
            _activityHistory = filteredHistory;
            _isLoading = false;
          });

          // Atualiza provider com dados mais recentes
          if (userData != null) {
            userProvider.updateProgress(
              totalPoints: userData.totalPoints,
              activitiesCompleted: userData.activitiesCompleted,
              level: userData.level,
              progress: userData.progress,
            );
          }
        }
      } catch (e) {
        debugPrint('Erro ao carregar dados: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// Verifica se atividade foi completada
  ActivityProgress? _getActivityProgress(String activityId) {
    try {
      return _activityHistory.firstWhere(
        (activity) => activity.activityId == activityId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com informações do usuário
                      _buildUserHeader(userProvider),
                      const SizedBox(height: 32),

                      // Cards de estatísticas
                      _buildStatsCards(userProvider),
                      const SizedBox(height: 24),

                      // Barra de progresso de nível
                      _buildLevelProgress(userProvider),
                      const SizedBox(height: 32),

                      // Título: Progresso nas Atividades
                      _buildSectionTitle('Progresso nas Atividades', Icons.assignment_turned_in),
                      const SizedBox(height: 16),

                      // Lista de atividades com progresso
                      _buildActivitiesList(),
                      const SizedBox(height: 32),

                      // Histórico recente
                      if (_activityHistory.isNotEmpty) ...[
                        _buildSectionTitle('Histórico Recente', Icons.history),
                        const SizedBox(height: 16),
                        _buildActivityHistory(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Cabeçalho com avatar e informações do usuário
  Widget _buildUserHeader(UserProvider userProvider) {
    final userName = userProvider.userName ?? 'Usuário';
    final userEmail = userProvider.userEmail ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 20),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Nível ${userProvider.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Cards de estatísticas gerais
  Widget _buildStatsCards(UserProvider userProvider) {
    return Row(
      children: [
        // Total de Pontos
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            label: 'Pontos',
            value: userProvider.totalPoints.toString(),
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),

        // Atividades Completadas
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Completas',
            value: '${userProvider.activitiesCompleted}/${_allActivities.length}',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),

        // Taxa de Conclusão
        Expanded(
          child: _buildStatCard(
            icon: Icons.insights,
            label: 'Taxa',
            value: '${_calculateCompletionRate(userProvider)}%',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  /// Card de estatística individual
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Barra de progresso de nível
  Widget _buildLevelProgress(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${(userProvider.levelProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: userProvider.levelProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faltam ${100 - (userProvider.levelProgress * 100).toInt()} pontos para o nível ${userProvider.level + 1}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Título de seção
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// Lista de atividades com progresso
  Widget _buildActivitiesList() {
    return Column(
      children: _allActivities.map((activity) {
        final progress = _getActivityProgress(activity['id']);
        final isCompleted = progress != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildActivityCard(
            activity: activity,
            progress: progress,
            isCompleted: isCompleted,
          ),
        );
      }).toList(),
    );
  }

  /// Card de atividade individual
  Widget _buildActivityCard({
    required Map<String, dynamic> activity,
    required ActivityProgress? progress,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? activity['color'].withOpacity(0.5)
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              // Ícone
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Nome e status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          size: 16,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCompleted ? 'Completada' : 'Não completada',
                          style: TextStyle(
                            fontSize: 13,
                            color: isCompleted ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge de pontos
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${progress!.points}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Detalhes (se completada)
          if (isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Tentativas',
                      '${progress!.attempts}',
                      Icons.replay,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Precisão',
                      '${(progress.accuracy * 100).toInt()}%',
                      Icons.analytics,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Data',
                      _formatDate(progress.completedAt),
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Item de detalhe da atividade
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Histórico de atividades recentes
  Widget _buildActivityHistory() {
    // Ordena por data mais recente
    final sortedHistory = List<ActivityProgress>.from(_activityHistory)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    // Pega as 5 mais recentes
    final recentActivities = sortedHistory.take(5).toList();

    return Column(
      children: recentActivities.map((activity) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Row(
              children: [
                // Ícone de sucesso
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(activity.completedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pontos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${activity.points}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Calcula taxa de conclusão
  int _calculateCompletionRate(UserProvider userProvider) {
    if (_allActivities.isEmpty) return 0;
    return ((userProvider.activitiesCompleted / _allActivities.length) * 100).toInt();
  }

  /// Formata data (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  /// Formata data e hora completa
  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
