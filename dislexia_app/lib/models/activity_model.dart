// arquivo: lib/models/activity_model.dart

/// Modelo de atividade educativa
/// Define as atividades disponíveis no app e seus requisitos de nível
class ActivityModel {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final String route;
  final int points;

  const ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.route,
    required this.points,
  });

  /// Verifica se o usuário pode acessar esta atividade
  bool canAccess(int userLevel) {
    return userLevel >= requiredLevel;
  }
}

/// Lista de todas as atividades disponíveis no app
/// IMPORTANTE: Esta é a fonte de verdade para atividades e níveis
class Activities {
  // IDs das atividades (imutáveis)
  static const String recognizeLettersId = 'recognize-letters';
  static const String syllabicId = 'syllabic';
  static const String formWordId = 'form-word';
  static const String matchImageId = 'match-image';

  /// Lista de todas as atividades
  static const List<ActivityModel> all = [
    ActivityModel(
      id: recognizeLettersId,
      name: 'Reconhecendo Letras',
      description: 'Identifique a primeira letra da palavra',
      requiredLevel: 1,
      route: '/activity-recognize-letters',
      points: 100,
    ),
    ActivityModel(
      id: syllabicId,
      name: 'Complete a Palavra',
      description: 'Complete a palavra com a letra que falta',
      requiredLevel: 2,
      route: '/activity-syllabic',
      points: 100,
    ),
    ActivityModel(
      id: formWordId,
      name: 'Formar Palavra com Sílabas',
      description: 'Junte as sílabas para formar a palavra da imagem',
      requiredLevel: 3,
      route: '/activity-form-word',
      points: 100,
    ),
    ActivityModel(
      id: matchImageId,
      name: 'Relacionar Palavra com Imagem',
      description: 'Escolha a palavra correta para a imagem mostrada',
      requiredLevel: 4,
      route: '/activity-match-image',
      points: 100,
    ),
  ];

  /// Busca atividade por ID
  static ActivityModel? getById(String id) {
    try {
      return all.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Busca atividade por rota
  static ActivityModel? getByRoute(String route) {
    try {
      return all.firstWhere((activity) => activity.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Retorna todas as atividades acessíveis para um determinado nível
  static List<ActivityModel> getAccessibleActivities(int userLevel) {
    return all.where((activity) => activity.canAccess(userLevel)).toList();
  }

  /// Retorna todas as atividades bloqueadas para um determinado nível
  static List<ActivityModel> getLockedActivities(int userLevel) {
    return all.where((activity) => !activity.canAccess(userLevel)).toList();
  }

  /// Verifica se o usuário pode acessar uma atividade específica
  static bool canAccessActivity(String activityId, int userLevel) {
    final activity = getById(activityId);
    if (activity == null) return false;
    return activity.canAccess(userLevel);
  }

  /// Retorna o nível necessário para desbloquear a próxima atividade
  static int? getNextRequiredLevel(int currentLevel) {
    final lockedActivities = getLockedActivities(currentLevel);
    if (lockedActivities.isEmpty) return null;

    return lockedActivities
        .map((a) => a.requiredLevel)
        .reduce((min, level) => level < min ? level : min);
  }
}
