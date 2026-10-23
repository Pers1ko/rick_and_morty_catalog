import 'package:flutter/material.dart';
import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.dead,
      outline: AppColors.outline,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: base.textTheme.copyWith(
      displaySmall: const TextStyle(
        fontSize: 36,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.3,
        color: AppColors.text,
      ),
      headlineMedium: const TextStyle(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
        color: AppColors.text,
      ),
      bodyLarge: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: AppColors.text,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.text,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.secondary, fontSize: 14),
      prefixIconColor: AppColors.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outline),
  );
}
