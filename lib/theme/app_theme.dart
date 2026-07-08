import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedLight,
      brightness: Brightness.light,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: Brightness.light,
    );
  }

  static ThemeData get dark {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedDark,
      brightness: Brightness.dark,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final TextTheme baseTextTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
    ).textTheme;
    final TextTheme bodyTextTheme = GoogleFonts.baloo2TextTheme(baseTextTheme);
    final TextTheme textTheme = bodyTextTheme.copyWith(
      displayLarge:
          GoogleFonts.balooBhai2(textStyle: bodyTextTheme.displayLarge),
      displayMedium:
          GoogleFonts.balooBhai2(textStyle: bodyTextTheme.displayMedium),
      displaySmall:
          GoogleFonts.balooBhai2(textStyle: bodyTextTheme.displaySmall),
      headlineLarge:
          GoogleFonts.balooBhai2(textStyle: bodyTextTheme.headlineLarge),
      headlineMedium:
          GoogleFonts.balooBhai2(textStyle: bodyTextTheme.headlineMedium),
      headlineSmall:
          GoogleFonts.balooBhai2(textStyle: bodyTextTheme.headlineSmall),
      titleLarge: GoogleFonts.balooBhai2(textStyle: bodyTextTheme.titleLarge),
      titleMedium: GoogleFonts.balooBhai2(textStyle: bodyTextTheme.titleMedium),
      titleSmall: GoogleFonts.balooBhai2(textStyle: bodyTextTheme.titleSmall),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      fontFamily: GoogleFonts.baloo2().fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.inputFillLight
            : colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: BorderSide(
            color: colorScheme.primary,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: brightness == Brightness.light
            ? AppColors.surfaceLight
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ),
    );
  }
}
