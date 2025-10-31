// arquivo: test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dislexia_app/main.dart';

/// Testes básicos do aplicativo
///
/// IMPORTANTE: Para testar com Firebase, você precisaria configurar
/// o Firebase Test Lab ou mockar os serviços do Firebase.
/// Por enquanto, mantemos testes simples que não dependem do Firebase.
void main() {
  group('UserProvider Tests', () {
    test('UserProvider deve inicializar com valores padrão', () {
      final userProvider = UserProvider();

      expect(userProvider.isLoggedIn, false);
      expect(userProvider.userName, null);
      expect(userProvider.userEmail, null);
      expect(userProvider.totalPoints, 0);
      expect(userProvider.activitiesCompleted, 0);
      expect(userProvider.level, 1);
      expect(userProvider.levelProgress, 0.0);
    });

    test('updateUser deve atualizar dados do usuário', () {
      final userProvider = UserProvider();

      userProvider.updateUser('uid123', 'teste@email.com', 'João Silva');

      expect(userProvider.uid, 'uid123');
      expect(userProvider.userEmail, 'teste@email.com');
      expect(userProvider.userName, 'João Silva');
      expect(userProvider.isLoggedIn, true);
    });

    test('updateUser sem displayName deve usar parte do email', () {
      final userProvider = UserProvider();

      userProvider.updateUser('uid456', 'maria@email.com', null);

      expect(userProvider.userName, 'maria');
      expect(userProvider.isLoggedIn, true);
    });

    test('updateProgress deve calcular nível corretamente', () {
      final userProvider = UserProvider();

      userProvider.updateProgress(totalPoints: 250, activitiesCompleted: 5);

      expect(userProvider.totalPoints, 250);
      expect(userProvider.activitiesCompleted, 5);
      expect(userProvider.level, 3); // 250 / 100 = 2, + 1 = 3
      expect(userProvider.levelProgress, 0.5); // 250 % 100 = 50, 50/100 = 0.5
    });

    test('clearUser deve limpar todos os dados', () {
      final userProvider = UserProvider();

      // Configura um usuário
      userProvider.updateUser('uid789', 'pedro@email.com', 'Pedro');
      userProvider.updateProgress(totalPoints: 150, activitiesCompleted: 3);

      // Limpa
      userProvider.clearUser();

      // Verifica se tudo foi limpo
      expect(userProvider.isLoggedIn, false);
      expect(userProvider.uid, null);
      expect(userProvider.userName, null);
      expect(userProvider.userEmail, null);
      expect(userProvider.totalPoints, 0);
      expect(userProvider.activitiesCompleted, 0);
      expect(userProvider.level, 1);
      expect(userProvider.levelProgress, 0.0);
    });
  });

  group('Widget Tests', () {
    testWidgets('DislexiaApp deve ter configuração correta', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const DislexiaApp(),
        ),
      );

      // Verifica se o MaterialApp foi criado
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verifica configurações do MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Dislexia App - MVP');
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('DislexiaApp deve ter todas as rotas configuradas', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const DislexiaApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verifica se as rotas estão configuradas
      expect(materialApp.routes?.containsKey('/'), true);
      expect(materialApp.routes?.containsKey('/login'), true);
      expect(materialApp.routes?.containsKey('/register'), true);
      expect(materialApp.routes?.containsKey('/home'), true);
      expect(materialApp.routes?.containsKey('/activity-match'), true);
    });
  });

  group('Theme Tests', () {
    testWidgets('DislexiaApp deve ter tema configurado corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const DislexiaApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme!;

      // Verifica cores
      expect(theme.primaryColor, const Color(0xFF2196F3));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F5F5));

      // Verifica Material 3
      expect(theme.useMaterial3, true);

      // Verifica tamanhos de fonte (acessibilidade)
      expect(theme.textTheme.displayLarge?.fontSize, 32);
      expect(theme.textTheme.displayMedium?.fontSize, 28);
      expect(theme.textTheme.bodyLarge?.fontSize, 18);
      expect(theme.textTheme.bodyMedium?.fontSize, 16);
    });
  });
}
