import 'package:flutter/material.dart';

/// Klasa zawierająca wszystkie kolory używane w aplikacji BandSpace
///
/// **DEPRECATED**: Ta klasa jest przestarzała. Używaj `Theme.of(context).colorScheme`
/// oraz `Theme.of(context).textTheme` zamiast bezpośredniego odwoływania się do AppColors.
///
/// Przykład migracji:
/// ```dart
/// // STARE (deprecated):
/// color: AppColors.primary
///
/// // NOWE (zalecane):
/// color: Theme.of(context).colorScheme.primary
/// ```
// @Deprecated('Używaj Theme.of(context).colorScheme zamiast AppColors')
class AppColors {
  // Kolory podstawowe
  static const Color primary = Color(0xFF273486); // BandSpace Blue
  static const Color primaryLight = Color(
    0xFF3A4DB0,
  ); // Jaśniejsza wersja BandSpace Blue
  static const Color primaryDark = Color(
    0xFF1A2360,
  ); // Ciemniejsza wersja BandSpace Blue

  static const Color onPrimary = Colors.white;

  static const Color accent = Color(
    0xFF2563EB,
  ); // Akcent - używany dla przycisków, linków itp.
  static const Color accentLight = Color(
    0xFF60A5FA,
  ); // Jaśniejszy akcent - używany dla linków

  // Kolory tła
  static const Color background = Color(0xFF111827); // bg-gray-900
  static const Color surface = Color(0xFF1F2937); // bg-gray-800
  static const Color surfaceLight = Color(0xFF1F2937); // bg-gray-800
  static const Color surfaceDark = Color(0xFF0F172A); // bg-slate-900
  static const Color surfaceMedium = Color(0xFF374151); // bg-gray-700

  // Kolory tekstu
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFD1D5DB); // text-gray-300
  static const Color textHint = Color(0xFF6B7280); // placeholder-gray-500

  // Kolory ikon
  static const Color iconPrimary = Colors.white;
  static const Color iconSecondary = Color(0xFF6B7280); // text-gray-500

  // Kolory obramowań
  static const Color border = Color(0xFF374151); // border-gray-700
  static const Color borderFocused = Color(
    0xFF60A5FA,
  ); // Jaśniejszy niebieski dla zaznaczenia

  // Kolory statusów
  static const Color error = Colors.redAccent;
  static const Color errorBackground = Color(
    0x33FF0000,
  ); // Czerwony z alpha 0.2
  static const Color errorBorder = Color(0x80FF0000); // Czerwony z alpha 0.5
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500

  // Kolory przycisków
  static const Color buttonPrimary = Color(0xFF2563EB); // bg-blue-600
  static const Color buttonPrimaryDisabled = Color(
    0x802563EB,
  ); // bg-blue-600 z alpha 0.5

  // Kolory dividerów
  static const Color divider = Color(0xFF374151); // border-gray-700

  // Pomocnicze metody do modyfikacji kolorów
  static Color withAlpha(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }
}
