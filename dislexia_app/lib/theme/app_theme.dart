// arquivo: lib/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Definição de temas do aplicativo
/// Contém tema colorido/amigável e tema de alto contraste
class AppTheme {
  // Cores do tema colorido (para crianças)
  static const Color primaryColorful = Color(0xFF4CAF50); // Verde amigável
  static const Color secondaryColorful = Color(0xFFFFEB3B); // Amarelo alegre
  static const Color accentColorful = Color(0xFFFF9800); // Laranja vibrante
  static const Color backgroundColorful = Color(0xFFFFFDE7); // Amarelo muito claro
  static const Color surfaceColorful = Colors.white;

  // Cores do tema alto contraste (preto e branco)
  static const Color primaryHighContrast = Color(0xFF000000);
  static const Color secondaryHighContrast = Color(0xFFFFFFFF);
  static const Color backgroundHighContrast = Color(0xFFFFFFFF);
  static const Color surfaceHighContrast = Color(0xFFF5F5F5);
  static const Color textHighContrast = Color(0xFF000000);

  /// Tema colorido e amigável para crianças
  static ThemeData getColorfulTheme({
    required double fontSizeMultiplier,
    required double iconSizeMultiplier,
  }) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'OpenDyslexic',

      // Esquema de cores alegre
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColorful,
        primary: primaryColorful,
        secondary: secondaryColorful,
        tertiary: accentColorful,
        surface: surfaceColorful,
        background: backgroundColorful,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: backgroundColorful,

      // Tipografia com fonte para dislexia ou Sans Serif
      textTheme: _buildTextTheme(
        fontSizeMultiplier: fontSizeMultiplier,
        color: Colors.black87,
      ),

      // AppBar com visual amigável
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColorful,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'OpenDyslexic',
          fontSize: 22 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Botões com design amigável
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorful,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          textStyle: TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 18 * fontSizeMultiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Botões de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColorful,
          textStyle: TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 16 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Cards com sombras suaves
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColorful,
      ),

      // Campos de texto amigáveis
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColorful, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColorful, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      // Ícones
      iconTheme: IconThemeData(
        color: primaryColorful,
        size: 28 * iconSizeMultiplier,
      ),
    );
  }

  /// Tema de alto contraste (preto e branco)
  static ThemeData getHighContrastTheme({
    required double fontSizeMultiplier,
    required double iconSizeMultiplier,
  }) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'OpenDyslexic',

      // Esquema de cores preto e branco
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryHighContrast,
        onPrimary: secondaryHighContrast,
        secondary: primaryHighContrast,
        onSecondary: secondaryHighContrast,
        error: Color(0xFF000000),
        onError: Color(0xFFFFFFFF),
        background: backgroundHighContrast,
        onBackground: textHighContrast,
        surface: surfaceHighContrast,
        onSurface: textHighContrast,
      ),

      scaffoldBackgroundColor: backgroundHighContrast,

      // Tipografia com alto contraste
      textTheme: _buildTextTheme(
        fontSizeMultiplier: fontSizeMultiplier,
        color: textHighContrast,
      ),

      // AppBar alto contraste
      appBarTheme: AppBarTheme(
        backgroundColor: primaryHighContrast,
        foregroundColor: secondaryHighContrast,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'OpenDyslexic',
          fontSize: 22 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: secondaryHighContrast,
        ),
      ),

      // Botões alto contraste
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryHighContrast,
          foregroundColor: secondaryHighContrast,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: primaryHighContrast, width: 3),
          ),
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 18 * fontSizeMultiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Botões de texto alto contraste
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryHighContrast,
          textStyle: TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 16 * fontSizeMultiplier,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // Cards alto contraste
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primaryHighContrast, width: 3),
        ),
        color: surfaceHighContrast,
      ),

      // Campos de texto alto contraste
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundHighContrast,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryHighContrast, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryHighContrast, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryHighContrast, width: 4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      // Ícones alto contraste
      iconTheme: IconThemeData(
        color: primaryHighContrast,
        size: 32 * iconSizeMultiplier,
      ),
    );
  }

  /// Constrói tema de tipografia personalizado
  static TextTheme _buildTextTheme({
    required double fontSizeMultiplier,
    required Color color,
  }) {
    const fontFamily = 'OpenDyslexic';

    return TextTheme(
      // Títulos grandes
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.4, // Espaçamento entre linhas (importante para dislexia)
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.4,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.4,
      ),

      // Títulos médios
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      ),

      // Títulos pequenos
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      ),

      // Corpo de texto
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18 * fontSizeMultiplier,
        color: color,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * fontSizeMultiplier,
        color: color,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * fontSizeMultiplier,
        color: color,
        height: 1.5,
      ),

      // Labels
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      ),
    );
  }
}
