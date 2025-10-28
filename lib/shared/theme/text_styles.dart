import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Klasa zawierająca wszystkie style tekstu używane w aplikacji BandSpace
///
/// **DEPRECATED**: Ta klasa jest przestarzała. Używaj `Theme.of(context).textTheme`
/// zamiast bezpośredniego odwoływania się do AppTextStyles.
///
/// Przykład migracji:
/// ```dart
/// // STARE (deprecated):
/// style: AppTextStyles.titleMedium
///
/// // NOWE (zalecane):
/// style: Theme.of(context).textTheme.titleMedium
/// ```
// @Deprecated('Używaj Theme.of(context).textTheme zamiast AppTextStyles')
class AppTextStyles {
  // Nagłówki
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // Podtytuły
  static TextStyle get titleLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Tekst podstawowy
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Tekst przycisków
  static TextStyle get buttonLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get buttonMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get buttonSmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Linki
  static TextStyle get link => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accentLight,
  );

  // Tekst pomocniczy
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // Tekst błędu
  static TextStyle get error => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );
}
