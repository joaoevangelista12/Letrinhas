import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/accessibility_provider.dart';

double scaleFont(double size, AccessibilityProvider acc) => size * acc.fontSize;

double scaleIcon(double size, AccessibilityProvider acc) => size * acc.iconSize;

extension AccessibilityScaleExtension on BuildContext {
  double scaleFont(double size) =>
      size * watch<AccessibilityProvider>().fontSize;

  double scaleIcon(double size) =>
      size * watch<AccessibilityProvider>().iconSize;
}
