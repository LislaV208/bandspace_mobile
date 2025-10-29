import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/features/auth/api/authentication_interceptor.dart';
import 'package:bandspace_mobile/features/auth/models/authentication_tokens.dart';

class AuthenticatedApiClient extends ApiClient {
  final AuthenticationTokens tokens;

  AuthenticatedApiClient({required this.tokens}) : super() {
    dio.options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';

    dio.interceptors.add(
      AuthenticationInterceptor(),
    );
  }
}
