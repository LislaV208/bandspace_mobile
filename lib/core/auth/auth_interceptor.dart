import 'dart:developer';

import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/auth/auth_event_service.dart';
import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/shared/models/session.dart';
import 'package:bandspace_mobile/shared/services/session_storage_service.dart';

/// Interceptor obsługujący autoryzację i automatyczne odświeżanie tokenów.
///
/// Automatycznie dodaje Authorization header do żądań i obsługuje
/// błędy 401 poprzez odświeżenie access tokenu.
class AuthInterceptor extends Interceptor {
  final SessionStorageService _storage;
  final AuthEventService? _authEventService;

  AuthInterceptor(this._storage, {AuthEventService? authEventService})
    : _authEventService = authEventService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Sprawdź czy endpoint jest publiczny (wszystkie /api/auth/ są publiczne, oprócz logout)
    final isPublicEndpoint = _isPublicEndpoint(options.path);

    if (!isPublicEndpoint) {
      // Dodaj Authorization header dla prywatnych endpointów
      final accessToken = await _storage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Obsługa błędu 401 (Unauthorized) - token wygasł
    if (err.response?.statusCode == 401) {
      // Nie próbuj odświeżać dla publicznych endpointów
      final isPublicEndpoint = _isPublicEndpoint(err.requestOptions.path);

      if (isPublicEndpoint) {
        handler.next(err);
        return;
      }

      try {
        // Spróbuj odświeżyć access token z retry do 3 prób
        await _tryRefreshTokenWithRetry();

        // Jeśli refresh się powiódł, ponów pierwotne żądanie
        final response = await _retryRequest(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        log('Refresh token failed: $e', error: e);
        // Wszystkie próby refresh się nie powiodły - powiadom o niepowodzeniu
        _authEventService?.emit(AuthEvent.tokenRefreshFailed);
      }
    }

    // Dla innych błędów lub gdy refresh się nie powiódł
    handler.next(err);
  }

  /// Sprawdza czy endpoint jest publiczny (nie wymaga autoryzacji)
  bool _isPublicEndpoint(String path) {
    // Endpointy auth są publiczne, oprócz logout który wymaga autoryzacji
    if (path.contains('/api/auth/')) {
      return !path.contains('/api/auth/logout');
    }
    return false;
  }

  /// Próbuje odświeżyć access token z retry do 5 prób
  /// Rzuca wyjątek jeśli wszystkie próby się nie powiodą
  Future<void> _tryRefreshTokenWithRetry() async {
    const maxRetries = 5;
    const retryDelay = Duration(milliseconds: 100);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _tryRefreshToken();
        return; // Sukces - zakończ retry loop
      } catch (e) {
        if (attempt == maxRetries) {
          // Ostatnia próba - rzuć wyjątek
          throw Exception(
            'Token refresh failed after $maxRetries attempts: $e',
          );
        }

        // Poczekaj przed następną próbą (exponential backoff)
        await Future.delayed(retryDelay * attempt);
      }
    }
  }

  /// Próbuje odświeżyć access token używając refresh tokenu
  /// Rzuca wyjątek w przypadku niepowodzenia
  Future<void> _tryRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Brak refresh tokenu');
    }

    // Użyj nowej instancji Dio żeby uniknąć interceptorów
    final dio = Dio();
    dio.options.baseUrl = EnvConfig().apiBaseUrl;

    final response = await dio.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final session = Session.fromMap(response.data);
    await _storage.saveSession(session);
  }

  /// Ponawia pierwotne żądanie z nowym tokenem
  Future<Response> _retryRequest(RequestOptions options) async {
    final accessToken = await _storage.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Użyj nowej instancji Dio żeby uniknąć interceptorów podczas retry
    final dio = Dio();
    dio.options.baseUrl = EnvConfig().apiBaseUrl;

    return await dio.request(
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
      data: options.data,
      queryParameters: options.queryParameters,
    );
  }
}
