import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Klasa zawierająca style dla pól formularzy używane w aplikacji BandSpace
class AppInputDecorations {
  // Podstawowa dekoracja dla pól tekstowych
  static InputDecoration textField({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textHint),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: _defaultBorder(),
      enabledBorder: _defaultBorder(),
      focusedBorder: _focusedBorder(),
      disabledBorder: _disabledBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _focusedErrorBorder(),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  // Dekoracja dla pól z błędem
  static InputDecoration errorTextField({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return textField(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    ).copyWith(
      errorText: errorText,
      errorStyle: const TextStyle(color: AppColors.error),
    );
  }

  // Dekoracja dla pól wyszukiwania
  static InputDecoration searchField({
    String? hintText,
  }) {
    return textField(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search, color: AppColors.iconSecondary),
    ).copyWith(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }

  // Prywatne metody pomocnicze dla obramowań
  static OutlineInputBorder _defaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    );
  }

  static OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.5),
    );
  }

  static OutlineInputBorder _disabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.withAlpha(AppColors.border, 0.5),
      ),
    );
  }

  static OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    );
  }

  static OutlineInputBorder _focusedErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    );
  }
}
