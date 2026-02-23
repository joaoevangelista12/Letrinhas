// arquivo: test/widgets/settings_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dislexia_app/screens/settings_page.dart';
import 'package:dislexia_app/providers/accessibility_provider.dart';

/// Testes de widgets para SettingsPage
///
/// Testa a interface de configurações de acessibilidade
void main() {
  late AccessibilityProvider accessibilityProvider;

  setUp(() {
    accessibilityProvider = AccessibilityProvider();
  });

  /// Helper para criar widget de teste com providers
  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AccessibilityProvider>.value(
        value: accessibilityProvider,
        child: const SettingsPage(),
      ),
    );
  }

  group('SettingsPage - Layout Básico', () {
    testWidgets('deve renderizar AppBar com título', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('deve renderizar cabeçalho de acessibilidade',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Acessibilidade'), findsOneWidget);
      expect(find.text('Personalize o app para facilitar sua leitura'),
          findsOneWidget);
      expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
    });

    testWidgets('deve renderizar todas as seções', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Seção Visual
      expect(find.text('Visual'), findsOneWidget);

      // Seção Tamanhos
      expect(find.text('Tamanhos'), findsOneWidget);

      // Seção Experiência
      expect(find.text('Experiência'), findsOneWidget);
    });

    testWidgets('deve renderizar card de informações',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sobre a Acessibilidade'), findsOneWidget);
      expect(find.text(
        'A fonte OpenDyslexic foi desenvolvida para facilitar a leitura de pessoas com dislexia. '
        'O modo alto contraste reduz distrações visuais.',
      ), findsOneWidget);
    });
  });

  group('SettingsPage - Controles de Acessibilidade', () {
    testWidgets('deve ter switch de alto contraste', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Modo Alto Contraste'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('deve ter switch de fonte OpenDyslexic',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Fonte OpenDyslexic'), findsOneWidget);
    });

    testWidgets('deve ter slider de tamanho de texto',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tamanho do Texto'), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('deve ter slider de tamanho de ícones',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tamanho dos Ícones'), findsOneWidget);
    });

    testWidgets('deve ter switch de animações', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Animações'), findsOneWidget);
    });

    testWidgets('deve ter switch de sons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sons e Voz'), findsOneWidget);
    });

    testWidgets('deve ter botão de restaurar padrões',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Restaurar Padrões'), findsOneWidget);
      expect(find.byIcon(Icons.restore), findsOneWidget);
    });
  });

  group('SettingsPage - Interações', () {
    testWidgets('deve alternar alto contraste ao clicar no switch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verifica estado inicial
      expect(accessibilityProvider.highContrast, false);

      // Encontra e clica no switch de alto contraste
      // Como há múltiplos switches, procura pelo que está próximo do texto
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pump();

      // Verifica que o estado mudou
      expect(accessibilityProvider.highContrast, true);
    });

    testWidgets('deve mostrar exemplo de texto ao ajustar tamanho',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Exemplo de texto com o tamanho selecionado'),
          findsOneWidget);
    });

    testWidgets('deve mostrar diálogo de confirmação ao restaurar padrões',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Clica no botão de restaurar
      await tester.tap(find.text('Restaurar Padrões'));
      await tester.pumpAndSettle();

      // Verifica que diálogo apareceu
      expect(find.text('Restaurar Padrões'), findsWidgets);
      expect(
        find.text(
          'Isso irá restaurar todas as configurações de acessibilidade para os valores padrão. Deseja continuar?',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Restaurar'), findsOneWidget);
    });

    testWidgets('deve cancelar restauração ao clicar em Cancelar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Altera configurações
      accessibilityProvider.toggleHighContrast();
      final initialHighContrast = accessibilityProvider.highContrast;

      // Abre diálogo de restauração
      await tester.tap(find.text('Restaurar Padrões'));
      await tester.pumpAndSettle();

      // Cancela
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Verifica que configurações não foram alteradas
      expect(accessibilityProvider.highContrast, initialHighContrast);
    });
  });

  group('SettingsPage - Textos Descritivos', () {
    testWidgets('deve mostrar texto correto quando alto contraste está ativo',
        (WidgetTester tester) async {
      accessibilityProvider.toggleHighContrast();
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Preto e branco para melhor legibilidade'), findsOneWidget);
    });

    testWidgets('deve mostrar texto correto quando alto contraste está inativo',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tema colorido e amigável'), findsOneWidget);
    });

    testWidgets('deve mostrar texto correto quando fonte OpenDyslexic está ativa',
        (WidgetTester tester) async {
      accessibilityProvider.toggleDyslexicFont();
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Fonte otimizada para dislexia ativada'), findsOneWidget);
    });

    testWidgets('deve mostrar texto correto quando animações estão ativas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Animações ativadas'), findsOneWidget);
    });

    testWidgets('deve mostrar texto correto quando sons estão ativos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Leitura por voz ativada'), findsOneWidget);
    });
  });

  group('SettingsPage - Acessibilidade Visual', () {
    testWidgets('deve ter ícones adequados para cada seção',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Ícones de seções
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.format_size), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Ícones de controles
      expect(find.byIcon(Icons.contrast), findsOneWidget);
      expect(find.byIcon(Icons.font_download), findsOneWidget);
      expect(find.byIcon(Icons.animation), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('deve ser scrollável quando conteúdo excede tela',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('SettingsPage - Valores dos Sliders', () {
    testWidgets('deve mostrar label do tamanho de fonte atual',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verifica que o label do slider aparece no subtítulo
      final fontSizeLabel = accessibilityProvider.fontSizeLabel;
      expect(
        find.textContaining('Ajuste o tamanho das letras: $fontSizeLabel'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar label do tamanho de ícone atual',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final iconSizeLabel = accessibilityProvider.iconSizeLabel;
      expect(
        find.textContaining('Ajuste o tamanho dos ícones: $iconSizeLabel'),
        findsOneWidget,
      );
    });
  });
}
