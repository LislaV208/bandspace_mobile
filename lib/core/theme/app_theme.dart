import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'text_styles.dart';

class _AppColors {
  // Kolory podstawowe
  static const Color primary = Color(0xFF273486); // BandSpace Blue
  static const Color primaryLight = Color(0xFF3A4DB0); // Jaśniejsza wersja BandSpace Blue
  static const Color primaryDark = Color(0xFF1A2360); // Ciemniejsza wersja BandSpace Blue

  static const Color onPrimary = Colors.white;

  static const Color accent = Color(0xFF2563EB); // Akcent - używany dla przycisków, linków itp.
  static const Color accentLight = Color(0xFF60A5FA); // Jaśniejszy akcent - używany dla linków

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
  static const Color borderFocused = Color(0xFF60A5FA); // Jaśniejszy niebieski dla zaznaczenia

  // Kolory statusów
  static const Color error = Colors.redAccent;
  static const Color errorBackground = Color(0x33FF0000); // Czerwony z alpha 0.2
  static const Color errorBorder = Color(0x80FF0000); // Czerwony z alpha 0.5
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500

  // Kolory przycisków
  static const Color buttonPrimary = Color(0xFF2563EB); // bg-blue-600
  static const Color buttonPrimaryDisabled = Color(0x802563EB); // bg-blue-600 z alpha 0.5

  // Kolory dividerów
  static const Color divider = Color(0xFF374151); // border-gray-700

  // Pomocnicze metody do modyfikacji kolorów
  static Color withAlpha(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }
}

/// Klasa zawierająca konfigurację motywu aplikacji BandSpace
class AppTheme {
  // Główny motyw aplikacji
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: _AppColors.background,

      // Konfiguracja tekstu
      textTheme: _textTheme,

      // Konfiguracja przycisków
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,

      // Konfiguracja pól formularzy
      inputDecorationTheme: _inputDecorationTheme,

      // Konfiguracja AppBar
      appBarTheme: _appBarTheme,

      // Konfiguracja Divider
      dividerTheme: _dividerTheme,

      // Konfiguracja Card
      cardTheme: _cardTheme,

      // Konfiguracja Dialog
      dialogTheme: _dialogTheme,

      // Konfiguracja BottomSheet
      bottomSheetTheme: _bottomSheetTheme,

      // Konfiguracja SnackBar
      snackBarTheme: _snackBarTheme,

      // Konfiguracja TabBar
      tabBarTheme: _tabBarTheme,

      // Konfiguracja Checkbox
      checkboxTheme: _checkboxTheme,

      // Konfiguracja Radio
      radioTheme: _radioTheme,

      // Konfiguracja Switch
      switchTheme: _switchTheme,

      // Konfiguracja Slider
      sliderTheme: _sliderTheme,

      // Konfiguracja ProgressIndicator
      progressIndicatorTheme: _progressIndicatorTheme,
    );
  }

  // Schemat kolorów dla ciemnego motywu
  static ColorScheme get _darkColorScheme {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: _AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: _AppColors.primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: _AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: _AppColors.accentLight,
      onSecondaryContainer: Colors.white,
      tertiary: _AppColors.accentLight,
      onTertiary: Colors.white,
      tertiaryContainer: _AppColors.accentLight,
      onTertiaryContainer: Colors.white,
      error: _AppColors.error,
      onError: Colors.white,
      errorContainer: _AppColors.errorBackground,
      onErrorContainer: _AppColors.error,
      surface: _AppColors.surfaceLight,
      onSurface: _AppColors.textPrimary,
      surfaceContainerHighest: _AppColors.surfaceMedium,
      onSurfaceVariant: _AppColors.textSecondary,
      outline: _AppColors.border,
      outlineVariant: _AppColors.divider,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: _AppColors.primaryLight,
    );
  }

  // Motyw tekstu
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyles.headlineLarge,
      displayMedium: AppTextStyles.headlineMedium,
      displaySmall: AppTextStyles.headlineSmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonLarge,
      labelMedium: AppTextStyles.buttonMedium,
      labelSmall: AppTextStyles.buttonSmall,
    );
  }

  // Motyw przycisków Elevated
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _AppColors.buttonPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _AppColors.buttonPrimaryDisabled,
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }

  // Motyw przycisków Outlined
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _AppColors.textSecondary,
        side: const BorderSide(color: _AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }

  // Motyw przycisków Text
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _AppColors.accentLight,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        textStyle: AppTextStyles.link,
      ),
    );
  }

  // Motyw pól formularzy
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: _AppColors.surfaceLight,
      hintStyle: TextStyle(color: _AppColors.textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _AppColors.borderFocused, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _AppColors.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _AppColors.withAlpha(_AppColors.border, 0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      labelStyle: TextStyle(color: _AppColors.textSecondary),
    );
  }

  // Motyw AppBar
  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: _AppColors.background,
      foregroundColor: _AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Motyw Divider
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(color: _AppColors.divider, thickness: 1, space: 1);
  }

  // Motyw Card
  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: _AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _AppColors.border),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  // Motyw Dialog
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: _AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Motyw BottomSheet
  static BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: _AppColors.surfaceLight,
      modalBackgroundColor: _AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }

  // Motyw SnackBar
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: _AppColors.surfaceMedium,
      contentTextStyle: AppTextStyles.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    );
  }

  // Motyw TabBar
  static TabBarThemeData get _tabBarTheme {
    return const TabBarThemeData(
      labelColor: _AppColors.textPrimary,
      unselectedLabelColor: _AppColors.textHint,
      indicatorColor: _AppColors.accent,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    );
  }

  // Motyw Checkbox
  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _AppColors.buttonPrimaryDisabled;
        }
        if (states.contains(WidgetState.selected)) {
          return _AppColors.accent;
        }
        return _AppColors.surfaceMedium;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: const BorderSide(color: _AppColors.border),
    );
  }

  // Motyw Radio
  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _AppColors.buttonPrimaryDisabled;
        }
        if (states.contains(WidgetState.selected)) {
          return _AppColors.accent;
        }
        return _AppColors.surfaceMedium;
      }),
    );
  }

  // Motyw Switch
  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey;
        }
        if (states.contains(WidgetState.selected)) {
          return _AppColors.accent;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.withAlpha(100);
        }
        if (states.contains(WidgetState.selected)) {
          return _AppColors.accent.withAlpha(100);
        }
        return Colors.grey.withAlpha(180);
      }),
    );
  }

  // Motyw Slider
  static SliderThemeData get _sliderTheme {
    return const SliderThemeData(
      activeTrackColor: _AppColors.accent,
      inactiveTrackColor: _AppColors.surfaceMedium,
      thumbColor: _AppColors.accent,
      overlayColor: Color(0x292563EB), // _AppColors.accent z alpha 0.16
      valueIndicatorColor: _AppColors.accent,
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    );
  }

  // Motyw ProgressIndicator
  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: _AppColors.accent,
      circularTrackColor: _AppColors.surfaceMedium,
      linearTrackColor: _AppColors.surfaceMedium,
    );
  }

  // Konfiguracja statusbar
  static void setStatusBarColor({bool darkMode = true}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _AppColors.background,
        systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
