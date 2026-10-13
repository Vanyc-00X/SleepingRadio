import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    try {
      return _build(useGoogleFonts: true);
    } catch (_) {
      // Без сети/шрифтов google_fonts не должен ронять UI.
      return _build(useGoogleFonts: false);
    }
  }

  static ThemeData _build({required bool useGoogleFonts}) {
    final baseDark = ThemeData.dark();
    TextTheme baseText;
    TextTheme uiText;

    if (useGoogleFonts) {
      baseText = GoogleFonts.literataTextTheme(baseDark.textTheme).apply(
        bodyColor: AppColors.moon,
        displayColor: AppColors.moon,
      );
      uiText = GoogleFonts.manropeTextTheme(baseText);
    } else {
      baseText = baseDark.textTheme.apply(
        bodyColor: AppColors.moon,
        displayColor: AppColors.moon,
        fontFamily: 'serif',
      );
      uiText = baseDark.textTheme.apply(
        bodyColor: AppColors.moon,
        displayColor: AppColors.moon,
        fontFamily: 'sans-serif',
      );
    }

    final colorScheme = ColorScheme.dark(
      surface: AppColors.night,
      onSurface: AppColors.moon,
      primary: AppColors.amber,
      onPrimary: AppColors.night,
      secondary: AppColors.amberDim,
      onSecondary: AppColors.moon,
      surfaceContainerHighest: AppColors.nightSoft,
      outline: AppColors.mist.withValues(alpha: 0.35),
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.night,
      textTheme: uiText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleLarge: uiText.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: uiText.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: uiText.bodyMedium?.copyWith(
          color: AppColors.mist,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: uiText.titleLarge?.copyWith(
          color: AppColors.moon,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.moon),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.nightElevated,
        indicatorColor: AppColors.amber.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return uiText.labelMedium?.copyWith(
            color: selected ? AppColors.amber : AppColors.mist,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.amber : AppColors.mist,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.night,
          minimumSize: const Size(48, 52),
          textStyle: uiText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.moon,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: AppColors.mist.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightElevated,
        hintStyle: uiText.bodyMedium?.copyWith(color: AppColors.mist),
        labelStyle: uiText.bodyMedium?.copyWith(color: AppColors.mist),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.mist.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.mist.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.amber, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.nightElevated,
        selectedColor: AppColors.amber.withValues(alpha: 0.25),
        labelStyle: uiText.labelLarge?.copyWith(color: AppColors.moon),
        secondaryLabelStyle: uiText.labelLarge?.copyWith(
          color: AppColors.amber,
        ),
        side: BorderSide(color: AppColors.mist.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.mist,
        textColor: AppColors.moon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.mist.withValues(alpha: 0.15),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.nightSoft,
        contentTextStyle: uiText.bodyMedium?.copyWith(color: AppColors.moon),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.nightElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
