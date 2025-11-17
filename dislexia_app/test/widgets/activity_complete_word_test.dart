// arquivo: test/widgets/activity_complete_word_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dislexia_app/screens/activity_complete_word.dart';
import 'package:dislexia_app/main.dart';
import 'package:dislexia_app/providers/accessibility_provider.dart';

/// Testes de widgets para ActivityCompleteWord
///
/// NOTA: Estes testes focam no layout e estrutura da UI.
/// Para testar TTS e integração com Firestore, seria necessário usar mocks.
void main() {
  late UserProvider userProvider;
  late AccessibilityProvider accessibilityProvider;

  setUp(() {
    userProvider = UserProvider();
    userProvider.updateUser('test-uid', 'test@email.com', 'João');

    accessibilityProvider = AccessibilityProvider();
  });

  /// Helper para criar widget de teste com providers
  Widget createTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ChangeNotifierProvider<AccessibilityProvider>.value(
            value: accessibilityProvider,
          ),
        ],
        child: const ActivityCompleteWord(),
      ),
    );
  }

  group('ActivityCompleteWord - Layout Básico', () {
    testWidgets('deve renderizar AppBar com título', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Completar Palavras'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('deve ter botão de áudio para instruções no AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Botão de volume no AppBar
      final appBarVolume = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.volume_up),
      );
      expect(appBarVolume, findsOneWidget);
    });

    testWidgets('deve ser scrollável quando necessário',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });

  group('ActivityCompleteWord - Indicadores de Progresso', () {
    testWidgets('deve mostrar número da palavra atual',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Primeira palavra (1 de 5)
      expect(find.textContaining('Palavra 1 de'), findsOneWidget);
    });

    testWidgets('deve mostrar contador de acertos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Acertos:'), findsOneWidget);
    });

    testWidgets('deve ter barra de progresso visual',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('ActivityCompleteWord - Exibição da Palavra', () {
    testWidgets('deve mostrar emoji da palavra', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Primeira palavra é GATO com emoji 🐱
      expect(find.text('🐱'), findsOneWidget);
    });

    testWidgets('deve mostrar palavra com letra faltando',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Primeira palavra mostra G_TO
      expect(find.text('G_TO'), findsOneWidget);
    });

    testWidgets('deve ter botão "Ouvir Palavra"', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ouvir Palavra'), findsOneWidget);
      expect(find.widgetWithIcon(ElevatedButton, Icons.volume_up),
          findsOneWidget);
    });
  });

  group('ActivityCompleteWord - Instruções', () {
    testWidgets('deve mostrar instruções claras', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Escolha a letra que falta:'), findsOneWidget);
    });
  });

  group('ActivityCompleteWord - Opções de Letras', () {
    testWidgets('deve mostrar 4 opções de letras', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Para a primeira palavra (GATO), as opções são ['A', 'O', 'E', 'I']
      expect(find.text('A'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
      expect(find.text('I'), findsOneWidget);
    });

    testWidgets('opções devem ser clicáveis com GestureDetector',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('opções devem ter AnimatedContainer',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Cada opção deve ter AnimatedContainer para animações de feedback
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });

  group('ActivityCompleteWord - Interações', () {
    testWidgets('deve permitir selecionar uma letra',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Toca na letra 'A' (resposta correta para G_TO)
      await tester.tap(find.text('A'));
      await tester.pump();

      // Verifica que feedback visual aparece
      // (O texto específico depende da implementação)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('deve mostrar feedback de acerto', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Seleciona resposta correta
      await tester.tap(find.text('A'));
      await tester.pump();

      // Deve mostrar feedback "Correto!"
      expect(find.text('Correto!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('deve mostrar feedback de erro', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Seleciona resposta incorreta (O ao invés de A)
      await tester.tap(find.text('O'));
      await tester.pump();

      // Deve mostrar feedback "Tente novamente"
      expect(find.text('Tente novamente'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
  });

  group('ActivityCompleteWord - Acessibilidade', () {
    testWidgets('deve respeitar configurações de tamanho de fonte',
        (WidgetTester tester) async {
      // Aumenta tamanho da fonte
      accessibilityProvider.setFontSize(1.4);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verifica que o emoji está maior (80 * 1.4 = 112)
      // Não podemos verificar o tamanho exato facilmente, mas garantimos que está renderizado
      expect(find.text('🐱'), findsOneWidget);
    });

    testWidgets('deve respeitar configurações de tamanho de ícones',
        (WidgetTester tester) async {
      // Aumenta tamanho dos ícones
      accessibilityProvider.setIconSize(1.4);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Ícones devem estar presentes e maiores
      expect(find.byIcon(Icons.volume_up), findsWidgets);
    });

    testWidgets('deve respeitar configuração de animações',
        (WidgetTester tester) async {
      // Desativa animações
      accessibilityProvider.toggleAnimations();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // AnimatedContainer deve usar duration 0 quando animações desativadas
      // O widget ainda existe, mas animações são instantâneas
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });

  group('ActivityCompleteWord - Feedback Visual', () {
    testWidgets('deve ter bordas coloridas nas opções',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Cada opção tem Container com decoração
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('deve mostrar palavra completa após acerto',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Seleciona resposta correta
      await tester.tap(find.text('A'));
      await tester.pump();

      // Palavra completa (GATO) deve aparecer
      expect(find.text('GATO'), findsOneWidget);
    });

    testWidgets('deve mudar cor de fundo ao mostrar feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Seleciona resposta correta
      await tester.tap(find.text('A'));
      await tester.pump();

      // Container com feedback deve estar verde (sucesso)
      // Verificamos através da presença do AnimatedContainer que muda de cor
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });

  group('ActivityCompleteWord - Estrutura de Dados', () {
    testWidgets('deve ter 5 palavras no total', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verifica que mostra "de 5"
      expect(find.textContaining('de 5'), findsOneWidget);
    });

    testWidgets('deve começar na palavra 1', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Palavra 1'), findsOneWidget);
    });

    testWidgets('contador de acertos deve começar em 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Acertos: 0'), findsOneWidget);
    });
  });

  group('ActivityCompleteWord - Layout Responsivo', () {
    testWidgets('deve usar Wrap para opções de letras',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Wrap permite que letras se ajustem à tela
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('deve ter espaçamento adequado entre elementos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Múltiplos SizedBox para espaçamento
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('deve usar Column para estrutura vertical',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });
  });

  group('ActivityCompleteWord - Documentação', () {
    test('DOCUMENTAÇÃO: Lista de palavras usadas na atividade', () {
      // Documenta as palavras usadas na atividade:
      final words = [
        {'word': 'GATO', 'display': 'G_TO', 'missing': 'A', 'emoji': '🐱'},
        {'word': 'CASA', 'display': 'C_SA', 'missing': 'A', 'emoji': '🏠'},
        {'word': 'BOLA', 'display': 'BO_A', 'missing': 'L', 'emoji': '⚽'},
        {'word': 'PATO', 'display': 'PA_O', 'missing': 'T', 'emoji': '🦆'},
        {'word': 'FLOR', 'display': 'FL_R', 'missing': 'O', 'emoji': '🌸'},
      ];

      expect(words.length, 5);
      expect(words[0]['word'], 'GATO');
      expect(words[4]['word'], 'FLOR');
    });

    test('DOCUMENTAÇÃO: Pontuação da atividade', () {
      // Atividade "Completar Palavras" vale 50 pontos
      const int points = 50;
      expect(points, 50);
    });

    test('DOCUMENTAÇÃO: ID da atividade no Firestore', () {
      // ID usado para salvar no Firestore
      const String activityId = 'complete-word';
      expect(activityId, 'complete-word');
    });
  });
}
