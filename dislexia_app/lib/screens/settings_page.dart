// arquivo: lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import '../utils/accessibility_scaler.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

/// Tela de configurações de acessibilidade
/// Permite personalizar fonte, contraste, tamanhos e mais
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              _buildHeader(context),
              const SizedBox(height: 24),

              // Seção: Visual
              _buildSectionTitle(context, 'Visual', Icons.visibility),
              const SizedBox(height: 16),
              _buildHighContrastSwitch(context, accessibilityProvider),
              const SizedBox(height: 32),

              // Seção: Tamanhos
              _buildSectionTitle(context, 'Tamanhos', Icons.format_size),
              const SizedBox(height: 16),
              _buildFontSizeSlider(context, accessibilityProvider),
              const SizedBox(height: 20),
              _buildIconSizeSlider(context, accessibilityProvider),
              const SizedBox(height: 32),

              // Seção: Experiência
              _buildSectionTitle(context, 'Experiência', Icons.tune),
              const SizedBox(height: 16),
              _buildAnimationsSwitch(context, accessibilityProvider),
              const SizedBox(height: 32),

              // Botão de resetar
              _buildResetButton(context, accessibilityProvider),
              const SizedBox(height: 16),

              // Informações
              _buildInfoCard(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Cabeçalho com descrição
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.accessibility_new,
            size: context.scaleIcon(48),
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acessibilidade',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalize o app para facilitar sua leitura',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Título de seção
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: context.scaleIcon(24), color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// Switch de alto contraste
  Widget _buildHighContrastSwitch(
    BuildContext context,
    AccessibilityProvider provider,
  ) {
    return _buildSettingCard(
      context,
      icon: Icons.contrast,
      title: 'Modo Alto Contraste',
      subtitle: provider.highContrast
          ? 'Preto e branco para melhor legibilidade'
          : 'Tema colorido e amigável',
      trailing: Switch(
        value: provider.highContrast,
        onChanged: (_) => provider.toggleHighContrast(),
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Slider de tamanho de fonte
  Widget _buildFontSizeSlider(
    BuildContext context,
    AccessibilityProvider provider,
  ) {
    return _buildSettingCard(
      context,
      icon: Icons.text_fields,
      title: 'Tamanho do Texto',
      subtitle: 'Ajuste o tamanho das letras: ${provider.fontSizeLabel}',
      trailing: const SizedBox.shrink(),
      bottom: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.text_fields, size: context.scaleIcon(16)),
              Expanded(
                child: Slider(
                  value: provider.fontSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: provider.fontSizeLabel,
                  onChanged: (value) => provider.setFontSize(value),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              Icon(Icons.text_fields, size: context.scaleIcon(32)),
            ],
          ),
          // Exemplo de texto
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Exemplo de texto com o tamanho selecionado',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Slider de tamanho de ícone
  Widget _buildIconSizeSlider(
    BuildContext context,
    AccessibilityProvider provider,
  ) {
    return _buildSettingCard(
      context,
      icon: Icons.image_aspect_ratio,
      title: 'Tamanho dos Ícones',
      subtitle: 'Ajuste o tamanho dos ícones: ${provider.iconSizeLabel}',
      trailing: const SizedBox.shrink(),
      bottom: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, size: context.scaleIcon(20)),
              Expanded(
                child: Slider(
                  value: provider.iconSize,
                  min: 1.0,
                  max: 1.4,
                  divisions: 4,
                  label: provider.iconSizeLabel,
                  onChanged: (value) => provider.setIconSize(value),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              Icon(Icons.star, size: 32 * provider.iconSize),
            ],
          ),
        ],
      ),
    );
  }

  /// Switch de animações
  Widget _buildAnimationsSwitch(
    BuildContext context,
    AccessibilityProvider provider,
  ) {
    return _buildSettingCard(
      context,
      icon: Icons.animation,
      title: 'Animações',
      subtitle: provider.enableAnimations
          ? 'Animações ativadas'
          : 'Animações desativadas',
      trailing: Switch(
        value: provider.enableAnimations,
        onChanged: (_) => provider.toggleAnimations(),
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Card de configuração genérico
  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Widget? bottom,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: context.scaleIcon(28), color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
          if (bottom != null) bottom,
        ],
      ),
    );
  }

  /// Botão de resetar configurações
  Widget _buildResetButton(
    BuildContext context,
    AccessibilityProvider provider,
  ) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          // Confirmação
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Restaurar Padrões'),
              content: Text(
                'Isso irá restaurar todas as configurações de acessibilidade para os valores padrão. Deseja continuar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Restaurar'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            await provider.resetToDefaults();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        icon: Icon(Icons.restore),
        label: Text('Restaurar Padrões'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  /// Card informativo
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: context.scaleIcon(28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre a Acessibilidade',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A fonte OpenDyslexic foi desenvolvida para facilitar a leitura de pessoas com dislexia. '
                  'O modo alto contraste reduz distrações visuais.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
