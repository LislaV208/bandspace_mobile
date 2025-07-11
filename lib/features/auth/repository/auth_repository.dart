import 'package:google_sign_in/google_sign_in.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/shared/models/change_password_request.dart';
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
    try {
      final response = await apiClient.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      final session = Session.fromMap(response.data);

      // Ustawienie tokenu autoryzacji w ApiClient
      apiClient.setAuthToken(session.accessToken);

      // Zapisanie danych sesji w lokalnym magazynie
      await storageService.saveSession(session);

      return session;
    } catch (e) {
      rethrow;
    }
  }

  /// Loguje użytkownika za pomocą Google Sign-In.
  ///
  /// Wykorzystuje Google OAuth do autoryzacji i wymienia token Google na JWT token aplikacji.
  /// Zwraca sesję użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<Session> loginWithGoogle() async {
    try {
      // Krok 1: Logowanie przez Google
      final GoogleSignInAccount? googleAccount = await googleSignInService
          .signIn();

      if (googleAccount == null) {
        throw ApiException(
          message: 'Anulowano logowanie przez Google',
          statusCode: 401,
          data: null,
        );
      }

      // Krok 2: Pobranie tokenów autoryzacji Google
      final GoogleSignInAuthentication googleAuth =
          googleAccount.authentication;

      if (googleAuth.idToken == null) {
        throw ApiException(
          message: 'Nie udało się pobrać tokenu ID Google',
          statusCode: 401,
          data: null,
        );
      }

      // Krok 3: Wysłanie ID tokenu Google do backendu w celu wymiany na JWT
      // Backend zweryfikuje token Google i zwróci sesję aplikacji
      final response = await apiClient.post(
        '/api/auth/login',
        data: {'googleToken': googleAuth.idToken},
      );

      final session = Session.fromMap(response.data);

      // Krok 4: Ustawienie tokenu autoryzacji w ApiClient
      apiClient.setAuthToken(session.accessToken);

      // Krok 5: Zapisanie danych sesji w lokalnym magazynie
      await storageService.saveSession(session);

      return session;
    } on ApiException {
      // Wyloguj z Google w przypadku błędu autoryzacji w backendzie
      await googleSignInService.signOut();
      rethrow;
    } catch (e) {
      // Wyloguj z Google w przypadku innych błędów
      await googleSignInService.signOut();
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas logowania przez Google: $e',
      );
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
    try {
      final response = await apiClient.post(
        '/api/auth/register',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data;

      // Nowy backend zwraca bezpośrednio accessToken i user, nie ma wrapper 'success'
      if (responseData['accessToken'] != null && responseData['user'] != null) {
        // Tworzymy sesję z danych odpowiedzi
        final session = Session(
          accessToken: responseData['accessToken'],
          refreshToken: '', // Backend nie zwraca refreshToken przy rejestracji
          user: User.fromMap(responseData['user']),
        );

        // Ustawienie tokenu autoryzacji w ApiClient
        apiClient.setAuthToken(session.accessToken);

        // Zapisanie danych sesji w lokalnym magazynie
        await storageService.saveSession(session);

        return session;
      } else {
        throw ApiException(
          message:
              responseData['message'] ?? 'Nieznany błąd podczas rejestracji',
          statusCode: response.statusCode,
          data: responseData,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas rejestracji: $e',
      );
    }
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
      if (await googleSignInService.isSignedIn()) {
        await googleSignInService.signOut();
      }
    } catch (e) {
      rethrow;
    } finally {
      // Czyszczenie tokenu autoryzacji
      apiClient.clearAuthToken();

      // Usunięcie danych sesji z lokalnego magazynu
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
  /// Jeśli dane sesji istnieją w lokalnym magazynie, ustawia token autoryzacji w ApiClient.
  /// Zwraca sesję użytkownika, jeśli istnieje, null w przeciwnym razie.
  Future<Session?> initSession() async {
    final session = await storageService.getSession();

    if (session != null) {
      // Ustawienie tokenu autoryzacji w ApiClient
      apiClient.setAuthToken(session.accessToken);
    }

    return session;
  }

  /// Czyści lokalny stan autoryzacji bez wywoływania API
  ///
  /// Używane po usunięciu konta, gdy użytkownik już nie istnieje w systemie
  Future<void> clearLocalSession() async {
    try {
      // Czyszczenie tokenu autoryzacji
      apiClient.clearAuthToken();

      // Usunięcie danych sesji z lokalnego magazynu
      await storageService.clearSession();
    } catch (e) {
      throw UnknownException(
        'Wystąpił błąd podczas czyszczenia lokalnej sesji: $e',
      );
    }
  }

  /// Zmienia hasło użytkownika.
  ///
  /// Wymaga podania aktualnego hasła oraz nowego hasła.
  /// Zwraca odpowiedź z informacją o powodzeniu operacji.
  Future<ChangePasswordResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final response = await apiClient.patch(
        '/api/auth/change-password',
        data: request.toJson(),
      );

      return ChangePasswordResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas zmiany hasła: $e');
    }
  }

  /// Wysyła żądanie resetowania hasła na podany adres email.
  ///
  /// Zwraca odpowiedź z informacją o wysłaniu instrukcji resetowania.
  Future<ForgotPasswordResponse> forgotPassword({required String email}) async {
    try {
      final request = ForgotPasswordRequest(email: email);

      final response = await apiClient.post(
        '/api/auth/password/request-reset',
        data: request.toJson(),
      );

      return ForgotPasswordResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił błąd podczas żądania resetowania hasła: $e',
      );
    }
  }

  /// Resetuje hasło używając tokenu otrzymanego w emailu.
  ///
  /// Wymaga podania tokenu resetowania oraz nowego hasła.
  /// Zwraca odpowiedź z informacją o powodzeniu operacji.
  Future<ResetPasswordResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );

      final response = await apiClient.post(
        '/api/auth/password/reset',
        data: request.toJson(),
      );

      return ResetPasswordResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas resetowania hasła: $e');
    }
  }
}
