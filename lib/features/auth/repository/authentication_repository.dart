import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/features/auth/models/authentication_tokens.dart';

class AuthenticationRepository extends ApiRepository {
  AuthenticationRepository({
    required super.apiClient,
  });

  Future<AuthenticationTokens> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final tokens = AuthenticationTokens.fromMap(data);

    return tokens;
  }

  Future<AuthenticationTokens> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/api/auth/register',
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final tokens = AuthenticationTokens.fromMap(data);

    return tokens;
  }

  // Future<AuthenticationTokens> authenticateWithGoogle() async {}
}
