import 'package:dio/dio.dart';

import 'package:bandspace_mobile/features/auth/models/authentication_tokens.dart';

class AuthenticationInterceptor extends Interceptor {
  final AuthenticationTokens tokens;

  AuthenticationInterceptor({
    required this.tokens,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    handler.next(options);
  }
}
