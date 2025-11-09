import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/authentication/authentication_storage.dart';
import 'package:bandspace_mobile/features/authentication/repository/authentication_repository.dart';

typedef OnSessionExpired = void Function();

class AuthenticationInterceptor extends Interceptor {
  final ApiClient apiClient;
  final AuthenticationStorage storage;
  final AuthenticationRepository repository;
  final OnSessionExpired onSessionExpired;

  AuthenticationInterceptor({
    required this.apiClient,
    required this.storage,
    required this.repository,
    required this.onSessionExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await storage.getTokens();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      handler.next(options);
    } else {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
          ),
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    var sessionExpired = false;

    final options = err.response?.requestOptions;
    // if (options == null) return handler.reject(err);
    if (options == null) sessionExpired = true;

    final tokens = await storage.getTokens();
    // if (tokens == null) return handler.reject(err);
    if (tokens == null) sessionExpired = true;

    if (sessionExpired) {
      onSessionExpired();
      return handler.reject(err);
    }

    try {
      final newTokens = await repository.refreshTokens(
        refreshToken: tokens!.refreshToken,
      );

      await storage.saveTokens(newTokens);

      options!.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';

      final response = await apiClient.request(
        options.path,
        options: Options(
          method: options.method,
          headers: options.headers,
          extra: options.extra,
          responseType: options.responseType,
          contentType: options.contentType,
          validateStatus: options.validateStatus,
          followRedirects: options.followRedirects,
          maxRedirects: options.maxRedirects,
          receiveTimeout: options.receiveTimeout,
          sendTimeout: options.sendTimeout,
        ),
      );

      handler.resolve(response);
    } on DioException catch (e) {
      onSessionExpired();
      handler.reject(e);
    }
  }
}
