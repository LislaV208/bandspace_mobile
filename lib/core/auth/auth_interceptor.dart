import 'package:dio/dio.dart';

import 'package:bandspace_mobile/shared/services/session_storage_service.dart';
import 'package:bandspace_mobile/shared/models/session.dart';
import 'package:bandspace_mobile/core/config/env_config.dart';

/// Interceptor obsługujący autoryzację i automatyczne odświeżanie tokenów.
/// 
/// Automatycznie dodaje Authorization header do żądań i obsługuje 
/// błędy 401 poprzez odświeżenie access tokenu.
class AuthInterceptor extends Interceptor {
  final SessionStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Sprawdź czy endpoint jest publiczny (wszystkie /api/auth/ są publiczne)
    final isPublicEndpoint = options.path.contains('/api/auth/');

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
      final isPublicEndpoint = err.requestOptions.path.contains('/api/auth/');

      if (isPublicEndpoint) {
        handler.next(err);
        return;
      }

      try {
        // Spróbuj odświeżyć access token
        final success = await _tryRefreshToken();
        
        if (success) {
          // Jeśli refresh się powiódł, ponów pierwotne żądanie
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          return;
        }
        
      } catch (e) {
        // Jeśli refresh się nie powiódł, przekaż oryginalny błąd 401
      }
    }

    // Dla innych błędów lub gdy refresh się nie powiódł
    handler.next(err);
  }

  /// Próbuje odświeżyć access token używając refresh tokenu
  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    
    try {
      // Użyj nowej instancji Dio żeby uniknąć interceptorów
      final dio = Dio();
      dio.options.baseUrl = EnvConfig().apiBaseUrl;
      
      final response = await dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      final session = Session.fromMap(response.data);
      await _storage.saveSession(session);
      return true;
      
    } catch (e) {
      // W przypadku błędu refresh tokenu, wyczyść sesję
      await _storage.clearSession();
      return false;
    }
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