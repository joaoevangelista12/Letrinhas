// arquivo: test/models/activity_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dislexia_app/models/activity_model.dart';

void main() {
  group('ActivityModel', () {
    test('deve criar ActivityModel corretamente', () {
      const activity = ActivityModel(
        id: 'test-activity',
        name: 'Test Activity',
        description: 'A test activity',
        requiredLevel: 2,
        route: '/test',
        points: 100,
      );

      expect(activity.id, 'test-activity');
      expect(activity.name, 'Test Activity');
      expect(activity.description, 'A test activity');
      expect(activity.requiredLevel, 2);
      expect(activity.route, '/test');
      expect(activity.points, 100);
    });

    group('canAccess', () {
      const activity = ActivityModel(
        id: 'test',
        name: 'Test',
        description: 'Test',
        requiredLevel: 2,
        route: '/test',
        points: 100,
      );

      test('deve retornar true quando userLevel >= requiredLevel', () {
        expect(activity.canAccess(2), true); // Igual
        expect(activity.canAccess(3), true); // Maior
        expect(activity.canAccess(10), true); // Muito maior
      });

      test('deve retornar false quando userLevel < requiredLevel', () {
        expect(activity.canAccess(1), false);
        expect(activity.canAccess(0), false);
      });
    });
  });

  group('Activities', () {
    test('deve ter 4 atividades definidas', () {
      expect(Activities.all.length, 4);
    });

    test('deve ter IDs únicos para cada atividade', () {
      final ids = Activities.all.map((a) => a.id).toSet();
      expect(ids.length, Activities.all.length);
    });

    test('deve ter rotas únicas para cada atividade', () {
      final routes = Activities.all.map((a) => a.route).toSet();
      expect(routes.length, Activities.all.length);
    });

    test('níveis devem estar em ordem crescente (1, 2, 3, 4)', () {
      expect(Activities.all[0].requiredLevel, 1);
      expect(Activities.all[1].requiredLevel, 2);
      expect(Activities.all[2].requiredLevel, 3);
      expect(Activities.all[3].requiredLevel, 4);
    });

    group('IDs constantes', () {
      test('recognizeLettersId deve corresponder à primeira atividade', () {
        expect(Activities.recognizeLettersId, 'recognize-letters');
        expect(Activities.all[0].id, Activities.recognizeLettersId);
      });

      test('syllabicId deve corresponder à segunda atividade', () {
        expect(Activities.syllabicId, 'syllabic');
        expect(Activities.all[1].id, Activities.syllabicId);
      });

      test('formWordId deve corresponder à terceira atividade', () {
        expect(Activities.formWordId, 'form-word');
        expect(Activities.all[2].id, Activities.formWordId);
      });

      test('matchImageId deve corresponder à quarta atividade', () {
        expect(Activities.matchImageId, 'match-image');
        expect(Activities.all[3].id, Activities.matchImageId);
      });
    });

    group('getById', () {
      test('deve retornar atividade quando ID existe', () {
        final activity = Activities.getById(Activities.recognizeLettersId);
        expect(activity, isNotNull);
        expect(activity!.id, Activities.recognizeLettersId);
        expect(activity.name, 'Reconhecendo Letras');
      });

      test('deve retornar null quando ID não existe', () {
        final activity = Activities.getById('id-invalido');
        expect(activity, isNull);
      });
    });

    group('getByRoute', () {
      test('deve retornar atividade quando rota existe', () {
        final activity = Activities.getByRoute('/activity-recognize-letters');
        expect(activity, isNotNull);
        expect(activity!.route, '/activity-recognize-letters');
        expect(activity.id, Activities.recognizeLettersId);
      });

      test('deve retornar null quando rota não existe', () {
        final activity = Activities.getByRoute('/rota-invalida');
        expect(activity, isNull);
      });
    });

    group('getAccessibleActivities', () {
      test('nível 1 deve ter acesso apenas à atividade 1', () {
        final accessible = Activities.getAccessibleActivities(1);
        expect(accessible.length, 1);
        expect(accessible[0].id, Activities.recognizeLettersId);
      });

      test('nível 2 deve ter acesso às atividades 1 e 2', () {
        final accessible = Activities.getAccessibleActivities(2);
        expect(accessible.length, 2);
        expect(accessible[0].id, Activities.recognizeLettersId);
        expect(accessible[1].id, Activities.syllabicId);
      });

      test('nível 3 deve ter acesso às atividades 1, 2 e 3', () {
        final accessible = Activities.getAccessibleActivities(3);
        expect(accessible.length, 3);
      });

      test('nível 4 deve ter acesso a todas as atividades', () {
        final accessible = Activities.getAccessibleActivities(4);
        expect(accessible.length, 4);
      });

      test('nível 0 não deve ter acesso a nenhuma atividade', () {
        final accessible = Activities.getAccessibleActivities(0);
        expect(accessible.length, 0);
      });

      test('nível muito alto deve ter acesso a todas as atividades', () {
        final accessible = Activities.getAccessibleActivities(100);
        expect(accessible.length, 4);
      });
    });

    group('getLockedActivities', () {
      test('nível 1 deve ter 3 atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(1);
        expect(locked.length, 3);
        expect(locked[0].id, Activities.syllabicId);
        expect(locked[1].id, Activities.formWordId);
        expect(locked[2].id, Activities.matchImageId);
      });

      test('nível 2 deve ter 2 atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(2);
        expect(locked.length, 2);
        expect(locked[0].id, Activities.formWordId);
        expect(locked[1].id, Activities.matchImageId);
      });

      test('nível 3 deve ter 1 atividade bloqueada', () {
        final locked = Activities.getLockedActivities(3);
        expect(locked.length, 1);
        expect(locked[0].id, Activities.matchImageId);
      });

      test('nível 4 não deve ter atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(4);
        expect(locked.length, 0);
      });

      test('nível 0 deve ter todas as atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(0);
        expect(locked.length, 4);
      });
    });

    group('canAccessActivity', () {
      test('deve retornar true quando usuário tem nível suficiente', () {
        expect(
          Activities.canAccessActivity(Activities.recognizeLettersId, 1),
          true,
        );
        expect(
          Activities.canAccessActivity(Activities.syllabicId, 2),
          true,
        );
        expect(
          Activities.canAccessActivity(Activities.formWordId, 3),
          true,
        );
        expect(
          Activities.canAccessActivity(Activities.matchImageId, 4),
          true,
        );
      });

      test('deve retornar false quando usuário não tem nível suficiente', () {
        expect(
          Activities.canAccessActivity(Activities.syllabicId, 1),
          false,
        );
        expect(
          Activities.canAccessActivity(Activities.formWordId, 2),
          false,
        );
        expect(
          Activities.canAccessActivity(Activities.matchImageId, 3),
          false,
        );
      });

      test('deve retornar false quando atividade não existe', () {
        expect(
          Activities.canAccessActivity('id-invalido', 10),
          false,
        );
      });
    });

    group('getNextRequiredLevel', () {
      test('deve retornar próximo nível necessário para atividade bloqueada', () {
        expect(Activities.getNextRequiredLevel(1), 2);
        expect(Activities.getNextRequiredLevel(2), 3);
        expect(Activities.getNextRequiredLevel(3), 4);
      });

      test('deve retornar null quando já está no nível máximo', () {
        expect(Activities.getNextRequiredLevel(4), isNull);
        expect(Activities.getNextRequiredLevel(100), isNull);
      });
    });

    group('Validação de dados das atividades', () {
      test('todas as atividades devem ter pontos = 100', () {
        for (final activity in Activities.all) {
          expect(activity.points, 100);
        }
      });

      test('todas as atividades devem ter nomes não vazios', () {
        for (final activity in Activities.all) {
          expect(activity.name, isNotEmpty);
        }
      });

      test('todas as atividades devem ter descrições não vazias', () {
        for (final activity in Activities.all) {
          expect(activity.description, isNotEmpty);
        }
      });

      test('todas as atividades devem ter IDs não vazios', () {
        for (final activity in Activities.all) {
          expect(activity.id, isNotEmpty);
        }
      });

      test('todas as atividades devem ter rotas válidas', () {
        for (final activity in Activities.all) {
          expect(activity.route, startsWith('/'));
          expect(activity.route, isNotEmpty);
        }
      });

      test('todas as atividades devem ter níveis válidos (>= 1)', () {
        for (final activity in Activities.all) {
          expect(activity.requiredLevel, greaterThanOrEqualTo(1));
        }
      });
    });
  });
}
