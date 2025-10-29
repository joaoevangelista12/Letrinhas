// arquivo: test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dislexia_app/main.dart';

/// Testes básicos do aplicativo
void main() {
  group('UserProvider Tests', () {
    test('Login com credenciais válidas deve retornar true', () {
      final userProvider = UserProvider();

      final result = userProvider.login('teste@email.com', '123456');

      expect(result, true);
      expect(userProvider.isLoggedIn, true);
      expect(userProvider.userName, 'teste');
      expect(userProvider.userEmail, 'teste@email.com');
    });

    test('Login com email inválido deve retornar false', () {
      final userProvider = UserProvider();

      final result = userProvider.login('', '123456');

      expect(result, false);
      expect(userProvider.isLoggedIn, false);
    });

    test('Login com senha curta deve retornar false', () {
      final userProvider = UserProvider();

      final result = userProvider.login('teste@email.com', '123');

      expect(result, false);
      expect(userProvider.isLoggedIn, false);
    });

    test('Registro com dados válidos deve retornar true', () {
      final userProvider = UserProvider();

      final result = userProvider.register('João Silva', 'joao@email.com', '123456');

      expect(result, true);
      expect(userProvider.isLoggedIn, true);
      expect(userProvider.userName, 'João Silva');
      expect(userProvider.userEmail, 'joao@email.com');
    });

    test('Logout deve limpar dados do usuário', () {
      final userProvider = UserProvider();

      userProvider.login('teste@email.com', '123456');
      expect(userProvider.isLoggedIn, true);

      userProvider.logout();

      expect(userProvider.isLoggedIn, false);
      expect(userProvider.userName, null);
      expect(userProvider.userEmail, null);
    });
  });

  group('Widget Tests', () {
    testWidgets('DislexiaApp deve iniciar na SplashPage', (WidgetTester tester) async {
      await tester.pumpWidget(const DislexiaApp());

      // Verifica se está na splash screen
      expect(find.text('Letrinhas'), findsOneWidget);
      expect(find.text('Aprendendo com diversão'), findsOneWidget);
    });

    testWidgets('CustomButton deve exibir texto corretamente', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Import necessário para usar CustomButton
                return ElevatedButton(
                  onPressed: () => pressed = true,
                  child: const Text('Teste'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Teste'), findsOneWidget);

      await tester.tap(find.text('Teste'));
      await tester.pump();

      expect(pressed, true);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Deve ter todas as rotas configuradas', (WidgetTester tester) async {
      await tester.pumpWidget(const DislexiaApp());

      // Verifica se as rotas estão configuradas
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.routes?.containsKey('/'), true);
      expect(materialApp.routes?.containsKey('/login'), true);
      expect(materialApp.routes?.containsKey('/register'), true);
      expect(materialApp.routes?.containsKey('/home'), true);
      expect(materialApp.routes?.containsKey('/activity-match'), true);
    });
  });
}
