# Design Document

## Overview

This design implements a centralized error management system that replaces scattered error handling logic with a unified, maintainable approach. The solution uses a custom exception hierarchy, Dio interceptor for automatic error transformation, and simplified cubit error handling patterns.

## Architecture

### Core Components Architecture

```
lib/core/exceptions/
├── app_exceptions.dart          // Custom exception hierarchy
├── error_interceptor.dart       // Dio interceptor for error transformation
└── error_mapper.dart           // Maps DioException to AppException

lib/core/api/
├── api_client.dart             // Refactored to use ErrorInterceptor
└── api_repository.dart         // Base repository with simplified error handling
```

## Exception Hierarchy

### Base Exception Class

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;
  
  const AppException(this.message, [this.code, this.context]);
  
  @override
  String toString() => message;
}
```

### Network-Related Exceptions

```dart
// Base network exception
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.'
  ]);
}

// Specific network exceptions
class TimeoutException extends NetworkException {
  const TimeoutException([
    super.message = 'Przekroczono limit czasu połączenia. Spróbuj ponownie.'
  ]);
}

class ConnectionException extends NetworkException {
  const ConnectionException([
    super.message = 'Brak połączenia z internetem. Sprawdź swoje połączenie.'
  ]);
}

class ServerException extends NetworkException {
  const ServerException([
    super.message = 'Wystąpił błąd serwera. Spróbuj ponownie za chwilę.'
  ]);
}
```

### Authentication & Authorization Exceptions

```dart
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException([
    super.message = 'Sesja wygasła. Zaloguj się ponownie.',
    super.code = 'SESSION_EXPIRED'
  ]);
}

class PermissionException extends AuthException {
  const PermissionException([
    super.message = 'Nie masz uprawnień do wykonania tej operacji.',
    super.code = 'INSUFFICIENT_PERMISSIONS'
  ]);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([
    super.message = 'Nieprawidłowe dane logowania.',
    super.code = 'INVALID_CREDENTIALS'
  ]);
}
```

### Business Logic Exceptions

```dart
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException(String resourceType) : 
    super('$resourceType nie został znaleziony.');
}

class ConflictException extends AppException {
  const ConflictException([
    super.message = 'Zasób został zmodyfikowany przez kogoś innego. Odśwież dane i spróbuj ponownie.'
  ]);
}
```

## Error Interceptor Implementation

### ErrorInterceptor Class

```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ErrorMapper.fromDioException(err);
    
    // Log error for debugging
    _logError(err, appException);
    
    // Create new DioException with AppException as error
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appException,
      type: err.type,
      response: err.response,
      stackTrace: err.stackTrace,
    ));
  }
  
  void _logError(DioException dioError, AppException appException) {
    // Implementation for error logging
  }
}
```

### ErrorMapper Class

```dart
class ErrorMapper {
  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();
        
      case DioExceptionType.connectionError:
        return const ConnectionException();
        
      case DioExceptionType.badResponse:
        return _mapStatusCodeToException(error.response);
        
      case DioExceptionType.cancel:
        return const AppException('Operacja została anulowana.');
        
      case DioExceptionType.unknown:
      default:
        return const NetworkException('Wystąpił nieoczekiwany błąd sieciowy.');
    }
  }
  
  static AppException _mapStatusCodeToException(Response? response) {
    final statusCode = response?.statusCode;
    final message = _extractErrorMessage(response);
    
    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Nieprawidłowe dane żądania.');
      case 401:
        return const SessionExpiredException();
      case 403:
        return const PermissionException();
      case 404:
        return const ResourceNotFoundException('Zasób');
      case 409:
        return const ConflictException();
      case 422:
        return ValidationException(message ?? 'Dane nie przeszły walidacji.');
      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerException();
      default:
        return AppException(message ?? 'Wystąpił błąd HTTP ($statusCode).');
    }
  }
  
  static String? _extractErrorMessage(Response? response) {
    // Implementation for extracting error messages from response
  }
}
```

## ApiClient Refactoring

### Simplified ApiClient

```dart
class ApiClient {
  final Dio _dio;

  ApiClient({AuthEventService? authEventService}) : _dio = Dio() {
    _setupDio(authEventService);
  }

  void _setupDio(AuthEventService? authEventService) {
    // Base configuration
    _dio.options.baseUrl = EnvConfig().apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(SessionStorageService(), authEventService: authEventService),
      ErrorInterceptor(), // Our new error interceptor
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);
  }

  // HTTP methods without try-catch blocks
  Future<Response> get(String path, {/* params */}) => _dio.get(path, /* params */);
  Future<Response> post(String path, {/* params */}) => _dio.post(path, /* params */);
  Future<Response> patch(String path, {/* params */}) => _dio.patch(path, /* params */);
  Future<Response> delete(String path, {/* params */}) => _dio.delete(path, /* params */);
}
```

## Cubit Integration Pattern

### Simplified Error Handling in Cubits

```dart
// Before (with TrackErrorHandler)
} catch (error) {
  emit(TrackDetailUpdateFailure(
    message: TrackErrorHandler.getUpdateErrorMessage(error),
    track: currentTrack,
  ));
}

// After (with AppException)
} catch (error) {
  emit(TrackDetailUpdateFailure(
    message: error.toString(),
    track: currentTrack,
  ));
}
```

### Pattern for Specific Error Handling

```dart
} catch (error) {
  // Extract the actual exception from DioException if needed
  final actualException = error is DioException ? error.error : error;
  
  // Handle specific error types
  if (actualException is SessionExpiredException) {
    // Trigger logout flow
    context.read<AuthCubit>().logout();
  }
  
  // Use error.toString() for display message
  emit(SomeFailureState(error.toString()));
}
```

## Migration Strategy

### Phase 1: Core Infrastructure
1. Create `app_exceptions.dart` with exception hierarchy
2. Implement `ErrorInterceptor` and `ErrorMapper`
3. Refactor `ApiClient` to use new interceptor
4. Remove old exception classes from `ApiClient`

### Phase 2: Feature Migration
1. Remove `TrackErrorHandler` and update `TrackDetailCubit`
2. Update other cubits to use `error.toString()` pattern
3. Remove other feature-specific error handlers
4. Ensure all error messages are consistent

### Phase 3: Enhancement
1. Add error logging and monitoring
2. Implement retry mechanisms for appropriate error types
3. Add error analytics and reporting
4. Fine-tune error messages based on user feedback

## Error Message Localization

### Message Structure
- All error messages in Polish
- Clear, actionable language
- Consistent terminology across the application
- Appropriate level of technical detail for end users

### Categories of Messages
1. **Network Issues**: Connection, timeout, server problems
2. **Authentication**: Session, permissions, credentials
3. **Validation**: Form validation, business rules
4. **Resource Issues**: Not found, conflicts, access denied
5. **System Issues**: Unexpected errors, service unavailable


## Performance Considerations

### Error Processing Overhead
- Minimal performance impact from error transformation
- Efficient error message extraction from responses
- Lazy initialization of error context where appropriate

### Memory Management
- Proper disposal of error context data
- Avoid memory leaks from error state retention
- Efficient string handling for error messages

## Security Considerations

### Error Information Disclosure
- Sanitize error messages to avoid sensitive data leakage
- Appropriate level of detail in error messages
- Secure handling of authentication error contexts

### Error Logging
- Safe logging practices for error information
- Avoid logging sensitive user data
- Appropriate log levels for different error types