import 'package:google_sign_in/google_sign_in.dart';

import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/shared/models/forgot_password_request.dart';
import 'package:bandspace_mobile/shared/models/session.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/services/google_sign_in_service.dart';
import 'package:bandspace_mobile/shared/services/session_storage_service.dart';

/// Repozytorium odpowiedzialne za operacje związane z autoryzacją.
///
/// Obsługuje logowanie, rejestrację, wylogowywanie i inne operacje
/// związane z autoryzacją użytkownika.
class AuthRepository extends ApiRepository {
  final SessionStorageService storageService;
  final GoogleSignInService googleSignInService;

  /// Konstruktor przyjmujący opcjonalną instancję ApiClient i StorageService
  AuthRepository({
    required super.apiClient,
    required this.storageService,
    required this.googleSignInService,
  }) {
    // Inicjalizuj Google Sign-In przy tworzeniu repozytorium
    googleSignInService.initialize();
  }

  /// Loguje użytkownika przy użyciu emaila i hasła.
  ///
  /// Zwraca sesję użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final session = Session.fromMap(response.data);

    // Zapisanie danych sesji w lokalnym magazynie
    await storageService.saveSession(session);

    return session;
  }

  /// Loguje użytkownika za pomocą Google Sign-In.
  ///
  /// Wykorzystuje Google OAuth do autoryzacji i wymienia token Google na JWT token aplikacji.
  Future<Session?> loginWithGoogle() async {
    try {
      // Krok 1: Logowanie przez Google
      final GoogleSignInAccount? googleAccount = await googleSignInService
          .signIn();

      if (googleAccount == null) {
        return null;
      }

      // Krok 2: Pobranie tokenów autoryzacji Google
      final GoogleSignInAuthentication googleAuth =
          googleAccount.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Nie udało się pobrać tokenu ID Google',
        );
      }

      // Krok 3: Wysłanie ID tokenu Google do backendu w celu wymiany na JWT
      // Backend zweryfikuje token Google i zwróci sesję aplikacji
      final response = await apiClient.post(
        '/api/auth/google/mobile',
        data: {'token': googleAuth.idToken},
      );

      final session = Session.fromMap(response.data);

      // Krok 4: Tokeny są automatycznie zarządzane przez AuthInterceptor

      // Krok 5: Zapisanie danych sesji w lokalnym magazynie
      await storageService.saveSession(session);

      return session;
    } catch (e) {
      // Cleanup: wyloguj z Google przy błędzie logowania
      await googleSignInService.signOut();

      rethrow;
    }
  }

  /// Rejestruje nowego użytkownika.
  ///
  /// Zwraca sesję użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<Session> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await apiClient.post(
      '/api/auth/register',
      data: {'email': email, 'password': password},
    );

    final responseData = response.data;

    // Nowy backend zwraca bezpośrednio accessToken i user, nie ma wrapper 'success'
    final session = Session(
      accessToken: responseData['accessToken'],
      refreshToken:
          responseData['refreshToken'] ??
          '', // Backend może zwrócić lub nie refreshToken
      user: User.fromMap(responseData['user']),
    );

    // Tokeny są automatycznie zarządzane przez AuthInterceptor

    // Zapisanie danych sesji w lokalnym magazynie
    await storageService.saveSession(session);

    return session;
  }

  /// Wylogowuje użytkownika.
  ///
  /// Wywołuje endpoint wylogowania i czyści token autoryzacji w ApiClient.
  /// Również wylogowuje z Google Sign-In jeśli użytkownik był zalogowany przez Google.
  Future<void> logout() async {
    try {
      // Wywołanie endpointu wylogowania
      await apiClient.post('/api/auth/logout');

      // Wylogowanie z Google Sign-In
      await googleSignInService.signOut();
    } finally {
      // Usunięcie danych sesji z lokalnego magazynu (zawsze wykonaj cleanup)
      await storageService.clearSession();
    }
  }

  /// Sprawdza, czy użytkownik jest zalogowany.
  ///
  /// Zwraca true, jeśli użytkownik jest zalogowany, false w przeciwnym razie.
  Future<bool> isLoggedIn() async {
    return await storageService.isLoggedIn();
  }

  /// Inicjalizuje sesję użytkownika na podstawie danych z lokalnego magazynu.
  ///
  /// Zwraca sesję użytkownika, jeśli istnieje, null w przeciwnym razie.
  /// AuthInterceptor automatycznie obsłuży refresh tokenów przy pierwszym żądaniu.
  Future<Session?> initSession() async {
    return await storageService.getSession();
  }

  /// Czyści lokalny stan autoryzacji bez wywoływania API
  ///
  /// Używane po usunięciu konta, gdy użytkownik już nie istnieje w systemie
  Future<void> clearLocalSession() async {
    await storageService.clearSession();
  }

  /// Wysyła żądanie resetowania hasła na podany adres email.
  ///
  /// Zwraca odpowiedź z informacją o wysłaniu instrukcji resetowania.
  Future<ForgotPasswordResponse> forgotPassword({required String email}) async {
    final request = ForgotPasswordRequest(email: email);

    final response = await apiClient.post(
      '/api/auth/password/request-reset',
      data: request.toJson(),
    );

    return ForgotPasswordResponse.fromJson(response.data);
  }

  /// Resetuje hasło używając tokenu otrzymanego w emailu.
  ///
  /// Wymaga podania tokenu resetowania oraz nowego hasła.
  /// Zwraca odpowiedź z informacją o powodzeniu operacji.
  Future<ResetPasswordResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final request = ResetPasswordRequest(
      token: token,
      newPassword: newPassword,
    );

    final response = await apiClient.post(
      '/api/auth/password/reset',
      data: request.toJson(),
    );

    return ResetPasswordResponse.fromJson(response.data);
  }
}
