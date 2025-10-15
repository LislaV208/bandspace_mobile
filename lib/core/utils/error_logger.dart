import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralna funkcja do logowania błędów w aplikacji.
///
/// W trybie debug loguje błędy za pomocą [developer.log].
/// W trybie produkcyjnym wysyła błędy do Sentry.
///
/// Parametry:
/// - [error] - Błąd do zalogowania (może być Exception, Error lub dowolny obiekt).
/// - [stackTrace] - Opcjonalny stack trace. Jeśli nie podany, zostanie automatycznie
///   przechwycony dla Sentry.
/// - [hint] - Opcjonalny opis kontekstu błędu, pomocny przy debugowaniu.
/// - [extras] - Opcjonalne dodatkowe dane kontekstowe (pary klucz-wartość),
///   które zostaną załączone do raportu w Sentry.
///
/// Przykład użycia:
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (e, stackTrace) {
///   logError(
///     e,
///     stackTrace: stackTrace,
///     hint: 'Failed to load user data',
///     extras: {'userId': userId},
///   );
/// }
/// ```
void logError(
  dynamic error, {
  StackTrace? stackTrace,
  String? hint,
  Map<String, dynamic>? extras,
}) {
  if (kDebugMode) {
    // Tryb debug - loguj za pomocą developer.log
    final message = StringBuffer();

    if (hint != null) {
      message.writeln('[$hint]');
    }

    message.write('Error: $error');

    if (extras != null && extras.isNotEmpty) {
      message.writeln('\nExtras: $extras');
    }

    developer.log(
      message.toString(),
      name: 'ErrorLogger',
      error: error,
      stackTrace: stackTrace,
    );
  } else {
    // Tryb produkcyjny - loguj do Sentry
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: hint != null ? Hint.withMap({'context': hint}) : null,
      withScope: (scope) {
        if (extras != null) {
          scope.setContexts('extras', extras);
        }
      },
    );
  }
}
