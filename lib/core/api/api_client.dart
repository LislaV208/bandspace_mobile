import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/auth/auth_event_service.dart';
import 'package:bandspace_mobile/core/auth/auth_interceptor.dart';
import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/shared/services/session_storage_service.dart';

/// Klasa ApiClient odpowiedzialna za wykonywanie żądań HTTP
/// do API BandSpace przy użyciu biblioteki dio z obsługą automatycznego
/// odświeżania tokenów autoryzacji.
class ApiClient {
  /// Instancja Dio używana do wykonywania żądań
  final Dio _dio;

  /// Konstruktor inicjalizujący Dio z odpowiednimi ustawieniami
  ApiClient({AuthEventService? authEventService}) : _dio = Dio() {
    // Pobranie bazowego URL z konfiguracji środowiskowej
    final baseUrl = EnvConfig().apiBaseUrl;

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Upewnij się, że kody 2xx (200-299) są traktowane jako sukces
    _dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };

    // Dodanie Auth Interceptor z AuthEventService
    _dio.interceptors.add(AuthInterceptor(
      SessionStorageService(),
      authEventService: authEventService,
    ));
    
    // Dodanie interceptorów dla logowania
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  /// Wykonuje żądanie GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Wykonuje żądanie POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Wykonuje żądanie PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Wykonuje żądanie DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Wykonuje żądanie PATCH
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obsługuje błędy Dio i przekształca je na bardziej przyjazne komunikaty
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Przekroczono limit czasu połączenia');
        case DioExceptionType.badResponse:
          return ApiException(
            message: _getErrorMessage(error.response),
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.cancel:
          return RequestCancelledException('Żądanie zostało anulowane');
        case DioExceptionType.connectionError:
          return NetworkException('Problem z połączeniem internetowym');
        default:
          return UnknownException('Wystąpił nieznany błąd');
      }
    }
    return UnknownException('Wystąpił nieznany błąd');
  }

  /// Wyciąga komunikat błędu z odpowiedzi
  String _getErrorMessage(Response? response) {
    if (response == null) {
      return 'Brak odpowiedzi z serwera';
    }

    try {
      if (response.data is Map) {
        // Próba wyciągnięcia komunikatu błędu z różnych formatów odpowiedzi
        final data = response.data as Map;
        if (data.containsKey('message')) {
          return data['message'] as String;
        } else if (data.containsKey('error')) {
          final error = data['error'];
          if (error is String) {
            return error;
          } else if (error is Map && error.containsKey('message')) {
            return error['message'] as String;
          }
        }
      }
    } catch (e) {
      // Ignoruj błędy parsowania
    }

    // Domyślny komunikat błędu bazujący na kodzie statusu
    switch (response.statusCode) {
      case 400:
        return 'Nieprawidłowe żądanie';
      case 401:
        return 'Brak autoryzacji';
      case 403:
        return 'Brak dostępu';
      case 404:
        return 'Nie znaleziono zasobu';
      case 500:
        return 'Błąd serwera';
      default:
        return 'Błąd HTTP ${response.statusCode}';
    }
  }
}

/// Wyjątek dla błędów API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (kod: $statusCode)';
}

/// Wyjątek dla problemów z siecią
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Wyjątek dla przekroczenia limitu czasu
class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Wyjątek dla anulowanych żądań
class RequestCancelledException implements Exception {
  final String message;

  RequestCancelledException(this.message);

  @override
  String toString() => 'RequestCancelledException: $message';
}

/// Wyjątek dla nieznanych błędów
class UnknownException implements Exception {
  final String message;

  UnknownException(this.message);

  @override
  String toString() => 'UnknownException: $message';
}