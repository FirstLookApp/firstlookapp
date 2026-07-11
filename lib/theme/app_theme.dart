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
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppColors.seedDark,
      onPrimary: Colors.white,
      surface: Color(0xFF101114),
      onSurface: Color(0xFFF4F4F5),
      onSurfaceVariant: Color(0xFFA9ABB3),
      surfaceContainerLowest: Color(0xFF101114),
      surfaceContainerLow: Color(0xFF181A1F),
      surfaceContainer: Color(0xFF202329),
      surfaceContainerHigh: Color(0xFF272A31),
      surfaceContainerHighest: Color(0xFF30343C),
      surfaceTint: Colors.transparent,
      outline: Color(0xFF3A3F48),
      outlineVariant: Color(0xFF2C3037),
      shadow: Colors.black,
      scrim: Colors.black,
      error: Color(0xFFFF6B72),
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
      applyElevationOverlayColor: false,
      canvasColor: colorScheme.surface,
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
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
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
      dividerColor: brightness == Brightness.dark
          ? const Color(0xFF2C3037)
          : AppColors.border,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF101114)
            : Colors.white,
        modalBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF101114)
            : Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF2A2D34)
            : const Color(0xFF25252A),
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.baloo2().fontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
