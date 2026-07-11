import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color seedLight = Color(0xFFFF1F2D);
  static const Color seedDark = Color(0xFFFF5A62);
  static const Color primary = Color(0xFFFF1F2D);
  static const Color primaryDark = Color(0xFFD81320);
  static const Color primarySoft = Color(0xFFFFF0F1);
  static const Color secondary = Color(0xFF171719);
  static const Color textMuted = Color(0xFF85858C);
  static const Color textSoft = Color(0xFFA6A6AD);
  static const Color border = Color(0xFFECECF0);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF101114);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFFAFAFB);
  static const Color chipFill = Color(0xFFF4F4F6);
  static const Color shadow = Color(0x1A111111);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? backgroundDark : const Color(0xFFFAFAFA);

  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF181A1F) : Colors.white;

  static Color surfaceAlt(BuildContext context) =>
      isDark(context) ? const Color(0xFF202329) : const Color(0xFFFAFAFA);

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF4F4F5) : secondary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? const Color(0xFFA9ABB3) : textMuted;

  static Color outline(BuildContext context) =>
      isDark(context) ? const Color(0xFF2C3037) : border;

  static Color softPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFF381A20) : primarySoft;

  static Color adaptiveShadow(BuildContext context) =>
      isDark(context) ? const Color(0x66000000) : shadow;
}
