/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;
  
  const AppException(this.message, [this.code, this.context]);
  
  @override
  String toString() => message;
}

/// Network-related exceptions

/// Base network exception
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.'
  ]);
}

/// Timeout exceptions
class TimeoutException extends NetworkException {
  const TimeoutException([
    super.message = 'Przekroczono limit czasu połączenia. Spróbuj ponownie.'
  ]);
}

/// Connection exceptions
class ConnectionException extends NetworkException {
  const ConnectionException([
    super.message = 'Brak połączenia z internetem. Sprawdź swoje połączenie.'
  ]);
}

/// Server exceptions
class ServerException extends NetworkException {
  const ServerException([
    super.message = 'Wystąpił błąd serwera. Spróbuj ponownie za chwilę.'
  ]);
}

/// Authentication & Authorization exceptions

/// Base auth exception
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Session expired exception
class SessionExpiredException extends AuthException {
  const SessionExpiredException([
    super.message = 'Sesja wygasła. Zaloguj się ponownie.',
    super.code = 'SESSION_EXPIRED'
  ]);
}

/// Permission exception
class PermissionException extends AuthException {
  const PermissionException([
    super.message = 'Nie masz uprawnień do wykonania tej operacji.',
    super.code = 'INSUFFICIENT_PERMISSIONS'
  ]);
}

/// Invalid credentials exception
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([
    super.message = 'Nieprawidłowe dane logowania.',
    super.code = 'INVALID_CREDENTIALS'
  ]);
}

/// Business Logic exceptions

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Resource not found exception
class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException(String resourceType) : 
    super('$resourceType nie został znaleziony.');
}

/// Conflict exception
class ConflictException extends AppException {
  const ConflictException([
    super.message = 'Zasób został zmodyfikowany przez kogoś innego. Odśwież dane i spróbuj ponownie.'
  ]);
}

/// Request cancelled exception
class RequestCancelledException extends AppException {
  const RequestCancelledException([
    super.message = 'Operacja została anulowana.'
  ]);
}