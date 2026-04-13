// arquivo: lib/widgets/custom_button.dart

import 'package:flutter/material.dart';
import '../utils/accessibility_scaler.dart';

/// Widget de botão customizado
/// Usado em todo o app para manter consistência visual
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;
    final txtColor = textColor ?? Colors.white;

    if (isOutlined) {
      // Botão com borda (outlined)
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: bgColor, width: 2),
        ),
        child: _buildButtonContent(context, bgColor),
      );
    }

    // Botão preenchido (padrão)
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: txtColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: bgColor.withOpacity(0.4),
      ),
      child: _buildButtonContent(context, txtColor),
    );
  }

  /// Constrói o conteúdo do botão (texto + ícone opcional + loading)
  Widget _buildButtonContent(BuildContext context, Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (icon != null) {
      // Botão com ícone
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.scaleIcon(20)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: context.scaleFont(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Botão apenas com texto
    return Text(
      text,
      style: TextStyle(
        fontSize: context.scaleFont(16),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
