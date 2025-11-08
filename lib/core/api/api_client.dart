import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/features/authentication/api/authentication_interceptor.dart';

/// Klasa ApiClient odpowiedzialna za wykonywanie żądań HTTP
/// do API BandSpace przy użyciu biblioteki dio z obsługą automatycznego
/// odświeżania tokenów autoryzacji.
class ApiClient {
  /// Instancja Dio używana do wykonywania żądań
  @protected
  final dio = Dio();

  /// Konstruktor inicjalizujący Dio z odpowiednimi ustawieniami
  ApiClient() {
    // Pobranie bazowego URL z konfiguracji środowiskowej
    final baseUrl = EnvConfig().apiBaseUrl;

    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Upewnij się, że kody 2xx (200-299) są traktowane jako sukces
    dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };

    // Dodanie interceptorów
    dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);
  }

  void addAuthenticationInterceptor(AuthenticationInterceptor interceptor) {
    if (!dio.interceptors.contains(interceptor)) {
      dio.interceptors.add(interceptor);
    }
  }

  void removeAuthenticationInterceptor() {
    dio.interceptors.removeWhere((interceptor) => interceptor is AuthenticationInterceptor);
  }

  /// Wykonuje żądanie GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => dio.get(
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
  }) => dio.post(
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
  }) => dio.put(
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
  }) => dio.delete(
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
  }) => dio.patch(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  Future<Response> request(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => dio.request(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );
}
