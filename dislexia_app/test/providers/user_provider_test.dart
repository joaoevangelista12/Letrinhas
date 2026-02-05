// arquivo: test/providers/user_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dislexia_app/main.dart';

void main() {
  group('UserProvider', () {
    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider();
    });

    test('deve inicializar com valores padrão', () {
      expect(userProvider.uid, isNull);
      expect(userProvider.userName, isNull);
      expect(userProvider.userEmail, isNull);
      expect(userProvider.isLoggedIn, false);
      expect(userProvider.totalPoints, 0);
      expect(userProvider.activitiesCompleted, 0);
      expect(userProvider.level, 1);
      expect(userProvider.levelProgress, 0.0);
    });

    test('deve atualizar dados do usuário corretamente', () {
      userProvider.updateUser('uid123', 'test@email.com', 'João Silva');

      expect(userProvider.uid, 'uid123');
      expect(userProvider.userEmail, 'test@email.com');
      expect(userProvider.userName, 'João Silva');
      expect(userProvider.isLoggedIn, true);
    });

    test('deve usar email como nome se displayName for null', () {
      userProvider.updateUser('uid123', 'test@email.com', null);

      expect(userProvider.userName, 'test');
    });

    test('deve atualizar progresso com nível explícito', () {
      userProvider.updateProgress(
        totalPoints: 150,
        activitiesCompleted: 3,
        level: 2,
      );

      expect(userProvider.totalPoints, 150);
      expect(userProvider.activitiesCompleted, 3);
      expect(userProvider.level, 2); // Nível explícito
      expect(userProvider.levelProgress, 0.5); // 150 % 100 = 50, 50/100
    });

    test('deve manter nível anterior se level não for fornecido', () {
      // Define nível inicial
      userProvider.updateProgress(
        totalPoints: 50,
        activitiesCompleted: 1,
        level: 1,
      );
      expect(userProvider.level, 1);

      // Atualiza pontos sem fornecer nível
      userProvider.updateProgress(
        totalPoints: 150,
        activitiesCompleted: 3,
      );

      expect(userProvider.totalPoints, 150);
      expect(userProvider.level, 1); // Mantém nível anterior
    });

    test('deve atualizar nível quando fornecido', () {
      // Nível 1
      userProvider.updateProgress(
        totalPoints: 50,
        activitiesCompleted: 1,
        level: 1,
      );
      expect(userProvider.level, 1);

      // Nível 2
      userProvider.updateProgress(
        totalPoints: 100,
        activitiesCompleted: 2,
        level: 2,
      );
      expect(userProvider.level, 2);

      // Nível 3
      userProvider.updateProgress(
        totalPoints: 150,
        activitiesCompleted: 3,
        level: 3,
      );
      expect(userProvider.level, 3);
    });

    test('nível é independente de pontos', () {
      // Mesmo com muitos pontos, o nível é o que for passado
      userProvider.updateProgress(
        totalPoints: 500,
        activitiesCompleted: 10,
        level: 1,
      );

      expect(userProvider.totalPoints, 500);
      expect(userProvider.level, 1); // Nível explícito, não calculado
    });

    test('deve limpar dados do usuário', () {
      // Primeiro, define alguns dados
      userProvider.updateUser('uid123', 'test@email.com', 'João');
      userProvider.updateProgress(totalPoints: 150, activitiesCompleted: 3);

      // Limpa os dados
      userProvider.clearUser();

      // Verifica se tudo foi limpo
      expect(userProvider.uid, isNull);
      expect(userProvider.userName, isNull);
      expect(userProvider.userEmail, isNull);
      expect(userProvider.isLoggedIn, false);
      expect(userProvider.totalPoints, 0);
      expect(userProvider.activitiesCompleted, 0);
      expect(userProvider.level, 1);
      expect(userProvider.levelProgress, 0.0);
    });

    test('deve notificar listeners ao atualizar usuário', () {
      var notified = false;
      userProvider.addListener(() {
        notified = true;
      });

      userProvider.updateUser('uid123', 'test@email.com', 'João');

      expect(notified, true);
    });

    test('deve notificar listeners ao atualizar progresso', () {
      var notified = false;
      userProvider.addListener(() {
        notified = true;
      });

      userProvider.updateProgress(totalPoints: 100, activitiesCompleted: 2);

      expect(notified, true);
    });

    test('deve notificar listeners ao limpar dados', () {
      var notified = false;
      userProvider.addListener(() {
        notified = true;
      });

      userProvider.clearUser();

      expect(notified, true);
    });
  });
}
