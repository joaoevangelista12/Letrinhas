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
        points: 50,
      );

      expect(activity.id, 'test-activity');
      expect(activity.name, 'Test Activity');
      expect(activity.description, 'A test activity');
      expect(activity.requiredLevel, 2);
      expect(activity.route, '/test');
      expect(activity.points, 50);
    });

    group('canAccess', () {
      const activity = ActivityModel(
        id: 'test',
        name: 'Test',
        description: 'Test',
        requiredLevel: 2,
        route: '/test',
        points: 50,
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
    test('deve ter 3 atividades definidas', () {
      expect(Activities.all.length, 3);
    });

    test('deve ter IDs únicos para cada atividade', () {
      final ids = Activities.all.map((a) => a.id).toSet();
      expect(ids.length, Activities.all.length);
    });

    test('deve ter rotas únicas para cada atividade', () {
      final routes = Activities.all.map((a) => a.route).toSet();
      expect(routes.length, Activities.all.length);
    });

    test('níveis devem estar em ordem crescente', () {
      expect(Activities.all[0].requiredLevel, 1);
      expect(Activities.all[1].requiredLevel, 2);
      expect(Activities.all[2].requiredLevel, 3);
    });

    group('getById', () {
      test('deve retornar atividade quando ID existe', () {
        final activity = Activities.getById(Activities.matchWordsId);
        expect(activity, isNotNull);
        expect(activity!.id, Activities.matchWordsId);
        expect(activity.name, 'Associar Palavras');
      });

      test('deve retornar null quando ID não existe', () {
        final activity = Activities.getById('id-invalido');
        expect(activity, isNull);
      });
    });

    group('getByRoute', () {
      test('deve retornar atividade quando rota existe', () {
        final activity = Activities.getByRoute('/activity-match');
        expect(activity, isNotNull);
        expect(activity!.route, '/activity-match');
        expect(activity.id, Activities.matchWordsId);
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
        expect(accessible[0].id, Activities.matchWordsId);
      });

      test('nível 2 deve ter acesso às atividades 1 e 2', () {
        final accessible = Activities.getAccessibleActivities(2);
        expect(accessible.length, 2);
        expect(accessible[0].id, Activities.matchWordsId);
        expect(accessible[1].id, Activities.completeWordId);
      });

      test('nível 3 deve ter acesso a todas as atividades', () {
        final accessible = Activities.getAccessibleActivities(3);
        expect(accessible.length, 3);
      });

      test('nível 0 não deve ter acesso a nenhuma atividade', () {
        final accessible = Activities.getAccessibleActivities(0);
        expect(accessible.length, 0);
      });

      test('nível muito alto deve ter acesso a todas as atividades', () {
        final accessible = Activities.getAccessibleActivities(100);
        expect(accessible.length, 3);
      });
    });

    group('getLockedActivities', () {
      test('nível 1 deve ter 2 atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(1);
        expect(locked.length, 2);
        expect(locked[0].id, Activities.completeWordId);
        expect(locked[1].id, Activities.orderSyllablesId);
      });

      test('nível 2 deve ter 1 atividade bloqueada', () {
        final locked = Activities.getLockedActivities(2);
        expect(locked.length, 1);
        expect(locked[0].id, Activities.orderSyllablesId);
      });

      test('nível 3 não deve ter atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(3);
        expect(locked.length, 0);
      });

      test('nível 0 deve ter todas as atividades bloqueadas', () {
        final locked = Activities.getLockedActivities(0);
        expect(locked.length, 3);
      });
    });

    group('canAccessActivity', () {
      test('deve retornar true quando usuário tem nível suficiente', () {
        expect(
          Activities.canAccessActivity(Activities.matchWordsId, 1),
          true,
        );
        expect(
          Activities.canAccessActivity(Activities.completeWordId, 2),
          true,
        );
        expect(
          Activities.canAccessActivity(Activities.orderSyllablesId, 3),
          true,
        );
      });

      test('deve retornar false quando usuário não tem nível suficiente', () {
        expect(
          Activities.canAccessActivity(Activities.completeWordId, 1),
          false,
        );
        expect(
          Activities.canAccessActivity(Activities.orderSyllablesId, 1),
          false,
        );
        expect(
          Activities.canAccessActivity(Activities.orderSyllablesId, 2),
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
      });

      test('deve retornar null quando já está no nível máximo', () {
        expect(Activities.getNextRequiredLevel(3), isNull);
        expect(Activities.getNextRequiredLevel(100), isNull);
      });
    });

    group('Validação de dados das atividades', () {
      test('todas as atividades devem ter pontos positivos', () {
        for (final activity in Activities.all) {
          expect(activity.points, greaterThan(0));
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

    group('IDs constantes', () {
      test('matchWordsId deve corresponder à primeira atividade', () {
        expect(Activities.matchWordsId, 'match-words');
        expect(Activities.all[0].id, Activities.matchWordsId);
      });

      test('completeWordId deve corresponder à segunda atividade', () {
        expect(Activities.completeWordId, 'complete-word');
        expect(Activities.all[1].id, Activities.completeWordId);
      });

      test('orderSyllablesId deve corresponder à terceira atividade', () {
        expect(Activities.orderSyllablesId, 'order-syllables');
        expect(Activities.all[2].id, Activities.orderSyllablesId);
      });
    });
  });
}
