import 'package:flutter/material.dart';

import 'package:bandspace_mobile/shared/utils/error_logger.dart';

/// Uniwersalny dialog błędu
///
/// Wyświetla komunikat błędu w spójny sposób w całej aplikacji.
/// Automatycznie ekstraktuje komunikat z obiektu błędu używając [getErrorMessage].
/// Obsługuje opcjonalny retry i customizację tytułu.
///
/// Przykład użycia:
/// ```dart
/// try {
///   await someOperation();
/// } catch (e, stackTrace) {
///   logError(e, stackTrace: stackTrace, hint: 'someOperation failed');
///   if (mounted) {
///     ErrorDialog.show(
///       context,
///       error: e,
///       onRetry: () => cubit.retryOperation(),
///     );
///   }
/// }
/// ```
class ErrorDialog extends StatelessWidget {
  final Object error;
  final String title;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final String? dismissButtonText;
  final String? fallbackMessage;

  const ErrorDialog({
    super.key,
    required this.error,
    this.title = 'Wystąpił błąd',
    this.onRetry,
    this.retryButtonText,
    this.dismissButtonText,
    this.fallbackMessage,
  });

  /// Wyświetla dialog błędu
  ///
  /// [context] - BuildContext
  /// [error] - Obiekt błędu (Exception, Error, DioException, itp.)
  ///           Dialog automatycznie ekstraktuje odpowiedni komunikat używając [getErrorMessage]
  /// [title] - Tytuł dialogu (domyślnie "Wystąpił błąd")
  /// [onRetry] - Opcjonalny callback dla akcji "Spróbuj ponownie"
  /// [retryButtonText] - Tekst przycisku retry (domyślnie "Spróbuj ponownie")
  /// [dismissButtonText] - Tekst przycisku zamykającego (domyślnie "OK" lub "Wróć" gdy jest retry)
  /// [fallbackMessage] - Opcjonalny komunikat zastępczy gdy nie można wydobyć komunikatu z błędu
  /// [barrierDismissible] - Czy można zamknąć dialog klikając poza nim (domyślnie false)
  ///
  /// Zwraca [Future<bool?>] - true jeśli użytkownik wybrał retry, false/null jeśli dismiss
  static Future<bool?> show(
    BuildContext context, {
    required Object error,
    String? title,
    VoidCallback? onRetry,
    String? retryButtonText,
    String? dismissButtonText,
    String? fallbackMessage,
    bool barrierDismissible = false,
  }) {
    logError(error);

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ErrorDialog(
        error: error,
        title: title ?? 'Wystąpił błąd',
        onRetry: onRetry,
        retryButtonText: retryButtonText,
        dismissButtonText: dismissButtonText,
        fallbackMessage: fallbackMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = getErrorMessage(
      error,
      fallbackMessage: fallbackMessage ?? 'Wystąpił nieoczekiwany błąd',
    );

    return AlertDialog(
      title: _ErrorDialogTitle(title: title),
      content: _ErrorDialogContent(message: message),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actions: [
        _DismissButton(
          text: dismissButtonText ?? (onRetry != null ? 'Wróć' : 'OK'),
          hasRetry: onRetry != null,
        ),
        if (onRetry != null)
          _RetryButton(
            text: retryButtonText ?? 'Spróbuj ponownie',
            onRetry: onRetry,
          ),
      ],
    );
  }
}

/// Widget tytułu dialogu z ikoną błędu
class _ErrorDialogTitle extends StatelessWidget {
  final String title;

  const _ErrorDialogTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Widget zawartości dialogu z komunikatem błędu
class _ErrorDialogContent extends StatelessWidget {
  final String message;

  const _ErrorDialogContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}

/// Przycisk zamykający dialog
class _DismissButton extends StatelessWidget {
  final String text;
  final bool hasRetry;

  const _DismissButton({
    required this.text,
    required this.hasRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TextButton(
      onPressed: () => Navigator.pop(context, false),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Przycisk retry
class _RetryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;

  const _RetryButton({
    required this.text,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FilledButton(
      onPressed: () {
        Navigator.pop(context, true);
        onRetry?.call();
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
