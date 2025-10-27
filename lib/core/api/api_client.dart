import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/auth/auth_event_service.dart';
import 'package:bandspace_mobile/core/auth/auth_interceptor.dart';
import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/core/exceptions/error_interceptor.dart';
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
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Upewnij się, że kody 2xx (200-299) są traktowane jako sukces
    _dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };

    // Dodanie interceptorów
    _dio.interceptors.addAll([
      AuthInterceptor(
        SessionStorageService(),
        authEventService: authEventService,
      ),
      ErrorInterceptor(), // Nasz nowy interceptor błędów
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);
  }

  /// Wykonuje żądanie GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _dio.get(
    path,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Wykonuje żądanie POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Wykonuje żądanie PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.put(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Wykonuje żądanie DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _dio.delete(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
  );

  /// Wykonuje żądanie PATCH
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.patch(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );
}
