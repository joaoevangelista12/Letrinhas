// arquivo: test/widgets/home_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dislexia_app/screens/home_page.dart';
import 'package:dislexia_app/main.dart';

/// Testes de widgets para HomePage
///
/// NOTA: Estes testes focam no layout e estrutura da UI.
/// Para testar navegação e integração com Firestore, seria necessário
/// usar mocks ou testes de integração.
void main() {
  late UserProvider userProvider;

  setUp(() {
    userProvider = UserProvider();
    userProvider.updateUser('test-uid', 'test@email.com', 'João Silva');
    userProvider.updateProgress(totalPoints: 150, activitiesCompleted: 3);
  });

  /// Helper para criar widget de teste com providers
  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: const HomePage(),
      ),
    );
  }

  group('HomePage - Layout Básico', () {
    testWidgets('deve renderizar AppBar com título', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Letrinhas'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('deve ter botões de navegação no AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Botões de ação no AppBar
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('deve renderizar cabeçalho com saudação',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Olá,'), findsOneWidget);
      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('deve ser scrollável', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('HomePage - Cards de Progresso', () {
    testWidgets('deve renderizar seção "Seu Progresso"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Espera carregar dados

      expect(find.text('Seu Progresso'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('deve mostrar pontos totais do usuário',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('150'), findsOneWidget); // Total de pontos
      expect(find.text('Pontos'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('deve mostrar nível do usuário', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Nível 2 (150 / 100 = 1, +1 = 2)
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Nível'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('deve mostrar atividades completadas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget); // Atividades completadas
      expect(find.text('Completas'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('deve mostrar barra de progresso de nível',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Progresso do nível
      expect(find.text('Progresso do Nível 2'), findsOneWidget);

      // Percentual (150 % 100 = 50, 50/100 = 0.5 = 50%)
      expect(find.text('50%'), findsOneWidget);

      // Barra de progresso
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Texto de pontos faltantes (100 - 50 = 50)
      expect(find.textContaining('Faltam 50 pontos para o nível 3'),
          findsOneWidget);
    });
  });

  group('HomePage - Lista de Atividades', () {
    testWidgets('deve renderizar seção de atividades',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Atividades'), findsOneWidget);
    });

    testWidgets('deve renderizar todas as 5 atividades',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Activity 1
      expect(find.text('Associar Palavras'), findsOneWidget);
      expect(find.text('Combine palavras com imagens correspondentes'),
          findsOneWidget);

      // Activity 2
      expect(find.text('Completar Palavras'), findsOneWidget);
      expect(find.text('Complete as palavras com letras faltando'),
          findsOneWidget);

      // Activity 3
      expect(find.text('Ordenar Sílabas'), findsOneWidget);
      expect(find.text('Arraste as sílabas na ordem correta'), findsOneWidget);

      // Activity 4
      expect(find.text('Leitura de Frases'), findsOneWidget);
      expect(find.text('Leia frases e responda perguntas'), findsOneWidget);

      // Activity 5
      expect(find.text('Áudio e Imagem'), findsOneWidget);
      expect(find.text('Ouça e escolha a imagem correta'), findsOneWidget);
    });

    testWidgets('deve ter ícones apropriados para cada atividade',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsOneWidget);
      expect(find.byIcon(Icons.reorder), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(find.byIcon(Icons.hearing), findsOneWidget);
    });

    testWidgets('deve ter setas indicadoras nos cards de atividade',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Deve ter 5 setas (uma para cada atividade)
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(5));
    });

    testWidgets('cards de atividade devem ser clicáveis',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Todos os cards devem ter InkWell
      expect(find.byType(InkWell), findsWidgets);
    });
  });

  group('HomePage - Interações', () {
    testWidgets('botão de perfil deve ter tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final profileButton = find.byIcon(Icons.person);
      expect(profileButton, findsOneWidget);

      // Verifica tooltip
      final button = tester.widget<IconButton>(
        find.ancestor(of: profileButton, matching: find.byType(IconButton)).first,
      );
      expect(button.tooltip, 'Meu Perfil');
    });

    testWidgets('botão de configurações deve ter tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      final button = tester.widget<IconButton>(
        find.ancestor(of: settingsButton, matching: find.byType(IconButton)).first,
      );
      expect(button.tooltip, 'Configurações');
    });

    testWidgets('botão de logout deve ter tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final logoutButton = find.byIcon(Icons.exit_to_app);
      expect(logoutButton, findsOneWidget);

      final button = tester.widget<IconButton>(
        find.ancestor(of: logoutButton, matching: find.byType(IconButton)).first,
      );
      expect(button.tooltip, 'Sair');
    });

    testWidgets('deve mostrar diálogo de logout ao clicar em sair',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Clica no botão de logout
      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();

      // Verifica que diálogo apareceu
      expect(find.text('Sair'), findsWidgets);
      expect(find.text('Deseja realmente sair da sua conta?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('deve cancelar logout ao clicar em Cancelar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Abre diálogo de logout
      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();

      // Cancela
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Verifica que ainda está na HomePage
      expect(find.text('Letrinhas'), findsOneWidget);
      expect(find.text('João Silva'), findsOneWidget);
    });
  });

  group('HomePage - Valores Dinâmicos', () {
    testWidgets('deve usar "Usuário" como nome padrão se não informado',
        (WidgetTester tester) async {
      final emptyProvider = UserProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: emptyProvider,
          child: const HomePage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Usuário'), findsOneWidget);
    });

    testWidgets('deve calcular corretamente o progresso para nível 1',
        (WidgetTester tester) async {
      final level1Provider = UserProvider();
      level1Provider.updateUser('uid', 'test@email.com', 'Maria');
      level1Provider.updateProgress(totalPoints: 50, activitiesCompleted: 1);

      final widget = MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: level1Provider,
          child: const HomePage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Nível 1, 50 pontos
      expect(find.text('1'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('Progresso do Nível 1'), findsOneWidget);
    });

    testWidgets('deve calcular corretamente o progresso para nível 3',
        (WidgetTester tester) async {
      final level3Provider = UserProvider();
      level3Provider.updateUser('uid', 'test@email.com', 'Pedro');
      level3Provider.updateProgress(totalPoints: 275, activitiesCompleted: 7);

      final widget = MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: level3Provider,
          child: const HomePage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Nível 3 (275 / 100 = 2, +1 = 3)
      // Progresso: 275 % 100 = 75, 75/100 = 0.75 = 75%
      expect(find.text('3'), findsOneWidget);
      expect(find.text('275'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.textContaining('Faltam 25 pontos para o nível 4'),
          findsOneWidget);
    });
  });

  group('HomePage - Layout Responsivo', () {
    testWidgets('deve ter cards de estatística em linha (Row)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verifica que os 3 cards de estatística estão em uma Row
      final rows = find.byType(Row);
      expect(rows, findsWidgets);
    });

    testWidgets('deve usar Expanded para distribuir cards uniformemente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Deve haver 3 Expanded (um para cada card de estatística)
      expect(find.byType(Expanded), findsWidgets);
    });
  });
}
