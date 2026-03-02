// arquivo: lib/providers/accessibility_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar configurações de acessibilidade
/// Permite personalizar a experiência para usuários com dislexia
class AccessibilityProvider extends ChangeNotifier {
  bool _highContrast = false;
  bool _useDyslexicFont = true;
  double _fontSize = 1.0; // Multiplicador (0.8, 1.0, 1.2, 1.4)
  double _iconSize = 1.0; // Multiplicador (1.0, 1.2, 1.4)
  bool _enableAnimations = true;

  // Timer para debouncing dos sliders de tamanho
  Timer? _debounceTimer;

  static const String _keyHighContrast = 'high_contrast';
  static const String _keyDyslexicFont = 'dyslexic_font';
  static const String _keyFontSize = 'font_size';
  static const String _keyIconSize = 'icon_size';
  static const String _keyAnimations = 'enable_animations';

  bool get highContrast => _highContrast;
  bool get useDyslexicFont => _useDyslexicFont;
  double get fontSize => _fontSize;
  double get iconSize => _iconSize;
  bool get enableAnimations => _enableAnimations;

  /// Carrega configurações salvas do SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highContrast = prefs.getBool(_keyHighContrast) ?? false;
      _useDyslexicFont = prefs.getBool(_keyDyslexicFont) ?? true;
      _fontSize = prefs.getDouble(_keyFontSize) ?? 1.0;
      _iconSize = prefs.getDouble(_keyIconSize) ?? 1.0;
      _enableAnimations = prefs.getBool(_keyAnimations) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
    }
  }

  /// Alterna modo alto contraste
  Future<void> toggleHighContrast() async {
    _highContrast = !_highContrast;
    notifyListeners();
    await _saveSettings();
  }

  /// Alterna uso da fonte para dislexia
  Future<void> toggleDyslexicFont() async {
    _useDyslexicFont = !_useDyslexicFont;
    notifyListeners();
    await _saveSettings();
  }

  /// Define tamanho da fonte
  /// Usa debouncing para evitar salvar a cada mudança do slider (otimização)
  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(0.8, 1.4);
    notifyListeners(); // UI atualiza imediatamente

    // Cancela timer anterior e agenda novo salvamento após 500ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveSettings();
    });
  }

  /// Define tamanho dos ícones
  /// Usa debouncing para evitar salvar a cada mudança do slider (otimização)
  Future<void> setIconSize(double size) async {
    _iconSize = size.clamp(1.0, 1.4);
    notifyListeners(); // UI atualiza imediatamente

    // Cancela timer anterior e agenda novo salvamento após 500ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveSettings();
    });
  }

  /// Alterna animações
  Future<void> toggleAnimations() async {
    _enableAnimations = !_enableAnimations;
    notifyListeners();
    await _saveSettings();
  }

  /// Reseta todas as configurações para os valores padrão
  Future<void> resetToDefaults() async {
    _highContrast = false;
    _useDyslexicFont = true;
    _fontSize = 1.0;
    _iconSize = 1.0;
    _enableAnimations = true;
    notifyListeners();
    await _saveSettings();
  }

  /// Salva configurações no SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHighContrast, _highContrast);
      await prefs.setBool(_keyDyslexicFont, _useDyslexicFont);
      await prefs.setDouble(_keyFontSize, _fontSize);
      await prefs.setDouble(_keyIconSize, _iconSize);
      await prefs.setBool(_keyAnimations, _enableAnimations);
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações: $e');
    }
  }

  /// Retorna descrição do tamanho de fonte atual
  String get fontSizeLabel {
    if (_fontSize <= 0.9) return 'Pequena';
    if (_fontSize <= 1.1) return 'Normal';
    if (_fontSize <= 1.3) return 'Grande';
    return 'Muito Grande';
  }

  /// Retorna descrição do tamanho de ícone atual
  String get iconSizeLabel {
    if (_iconSize <= 1.1) return 'Normal';
    if (_iconSize <= 1.3) return 'Grande';
    return 'Muito Grande';
  }

  /// Limpa recursos ao destruir o provider (prevenção de memory leaks)
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
