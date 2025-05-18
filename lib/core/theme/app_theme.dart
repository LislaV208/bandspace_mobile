import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'text_styles.dart';

/// Klasa zawierająca konfigurację motywu aplikacji BandSpace
class AppTheme {
  // Główny motyw aplikacji
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.background,

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
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentLight,
      onSecondaryContainer: Colors.white,
      tertiary: AppColors.accentLight,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentLight,
      onTertiaryContainer: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorBackground,
      onErrorContainer: AppColors.error,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceMedium,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: AppColors.primaryLight,
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
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.buttonPrimaryDisabled,
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
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
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
        foregroundColor: AppColors.accentLight,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        textStyle: AppTextStyles.link,
      ),
    );
  }

  // Motyw pól formularzy
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      hintStyle: TextStyle(color: AppColors.textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.withAlpha(AppColors.border, 0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      labelStyle: TextStyle(color: AppColors.textSecondary),
    );
  }

  // Motyw AppBar
  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Motyw Divider
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1);
  }

  // Motyw Card
  static CardTheme get _cardTheme {
    return CardTheme(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  // Motyw Dialog
  static DialogTheme get _dialogTheme {
    return DialogTheme(
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Motyw BottomSheet
  static BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      modalBackgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }

  // Motyw SnackBar
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.surfaceMedium,
      contentTextStyle: AppTextStyles.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    );
  }

  // Motyw TabBar
  static TabBarTheme get _tabBarTheme {
    return const TabBarTheme(
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textHint,
      indicatorColor: AppColors.accent,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    );
  }

  // Motyw Checkbox
  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.buttonPrimaryDisabled;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.surfaceMedium;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: const BorderSide(color: AppColors.border),
    );
  }

  // Motyw Radio
  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.buttonPrimaryDisabled;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.surfaceMedium;
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
          return AppColors.accent;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.withAlpha(100);
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withAlpha(100);
        }
        return Colors.grey.withAlpha(180);
      }),
    );
  }

  // Motyw Slider
  static SliderThemeData get _sliderTheme {
    return const SliderThemeData(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.surfaceMedium,
      thumbColor: AppColors.accent,
      overlayColor: Color(0x292563EB), // AppColors.accent z alpha 0.16
      valueIndicatorColor: AppColors.accent,
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    );
  }

  // Motyw ProgressIndicator
  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: AppColors.accent,
      circularTrackColor: AppColors.surfaceMedium,
      linearTrackColor: AppColors.surfaceMedium,
    );
  }

  // Konfiguracja statusbar
  static void setStatusBarColor({bool darkMode = true}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
