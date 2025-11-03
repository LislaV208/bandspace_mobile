import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/core/auth/google_sign_in_service.dart';
import 'package:bandspace_mobile/features/auth/models/authentication_tokens.dart';

class GoogleSignInCancelledByUser implements Exception {
  const GoogleSignInCancelledByUser();
}

class AuthenticationRepository extends ApiRepository {
  final GoogleSignInService googleSignInService;

  AuthenticationRepository({
    required super.apiClient,
    required this.googleSignInService,
  });

  Future<void> initialize() async {
    await googleSignInService.initialize();
  }

  Future<AuthenticationTokens> authenticateWithGoogle() async {
    final account = await googleSignInService.signIn();

    if (account == null) {
      throw GoogleSignInCancelledByUser();
    }

    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw Exception(
        'Nie udało się pobrać tokenu ID Google',
      );
    }

    final response = await apiClient.post(
      '/api/auth/google/mobile',
      data: {'token': idToken},
    );

    final data = response.data;
    final tokens = AuthenticationTokens.fromMap(data);

    return tokens;
  }

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
}
