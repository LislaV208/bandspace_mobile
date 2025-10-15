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

/// Ustawia kontekst użytkownika w Sentry.
///
/// Automatycznie przypisuje zalogowanego użytkownika do wszystkich przyszłych błędów
/// i eventów wysyłanych do Sentry. Ułatwia to śledzenie problemów konkretnych użytkowników.
///
/// Parametry:
/// - [userId] - Unikalny identyfikator użytkownika (np. ID z bazy danych).
/// - [email] - Email użytkownika (opcjonalny).
/// - [username] - Nazwa użytkownika (opcjonalny).
/// - [extras] - Dodatkowe pola użytkownika (opcjonalne).
///
/// Aby wyczyścić kontekst użytkownika (np. po wylogowaniu), wywołaj funkcję
/// bez parametrów lub z `null`:
/// ```dart
/// setSentryUser(); // Wyczyści kontekst użytkownika
/// ```
///
/// Przykład użycia:
/// ```dart
/// // Po zalogowaniu
/// setSentryUser(
///   userId: user.id.toString(),
///   email: user.email,
///   username: user.name,
///   extras: {'authProviders': user.authProviders.join(',')},
/// );
///
/// // Po wylogowaniu
/// setSentryUser();
/// ```
void setSentryUser({
  String? userId,
  String? email,
  String? username,
  Map<String, dynamic>? extras,
}) {
  if (kDebugMode) {
    // W trybie debug loguj informację o ustawieniu użytkownika
    if (userId != null) {
      developer.log(
        'Sentry user context set: $userId ($email)',
        name: 'SentryUserContext',
      );
    } else {
      developer.log(
        'Sentry user context cleared',
        name: 'SentryUserContext',
      );
    }
  }

  // Ustaw lub wyczyść kontekst użytkownika w Sentry
  if (userId != null) {
    final sentryUser = SentryUser(
      id: userId,
      email: email,
      username: username,
      data: extras,
    );
    Sentry.configureScope((scope) => scope.setUser(sentryUser));
  } else {
    // Wyczyść kontekst użytkownika
    Sentry.configureScope((scope) => scope.setUser(null));
  }
}
