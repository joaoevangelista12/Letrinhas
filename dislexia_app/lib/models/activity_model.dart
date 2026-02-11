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
  static const String matchWordsId = 'match-words';
  static const String completeWordId = 'complete-word';
  static const String orderSyllablesId = 'order-syllables';
  static const String readSentencesId = 'read-sentences';
  static const String audioImageId = 'audio-image';

  /// Lista de todas as atividades (apenas 3 inicialmente)
  static const List<ActivityModel> all = [
    ActivityModel(
      id: matchWordsId,
      name: 'Associar Palavras',
      description: 'Combine palavras com imagens correspondentes',
      requiredLevel: 1, // Nível 1 → Atividade 1
      route: '/activity-match',
      points: 50,
    ),
    ActivityModel(
      id: completeWordId,
      name: 'Completar Palavras',
      description: 'Complete as palavras com letras faltando',
      requiredLevel: 2, // Nível 2 → Atividade 2
      route: '/activity-complete-word',
      points: 50,
    ),
    ActivityModel(
      id: orderSyllablesId,
      name: 'Ordenar Sílabas',
      description: 'Arraste as sílabas na ordem correta',
      requiredLevel: 3, // Nível 3 → Atividade 3
      route: '/activity-order-syllables',
      points: 50,
    ),
    ActivityModel(
      id: readSentencesId,
      name: 'Leitura de Frases',
      description: 'Leia e interprete frases curtas',
      requiredLevel: 1,
      route: '/activity-read-sentences',
      points: 50,
    ),
    ActivityModel(
      id: audioImageId,
      name: 'Reforço Áudio e Imagem',
      description: 'Associe sons a imagens correspondentes',
      requiredLevel: 1,
      route: '/activity-audio-image',
      points: 50,
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

    // Retorna o menor nível necessário entre as atividades bloqueadas
    return lockedActivities
        .map((a) => a.requiredLevel)
        .reduce((min, level) => level < min ? level : min);
  }
}
