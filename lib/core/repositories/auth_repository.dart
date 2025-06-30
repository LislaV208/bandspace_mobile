import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/session.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/models/change_password_request.dart';
import 'package:bandspace_mobile/core/models/forgot_password_request.dart';
import 'package:bandspace_mobile/core/repositories/base_repository.dart';
import 'package:bandspace_mobile/core/services/storage_service.dart';

/// Repozytorium odpowiedzialne za operacje związane z autoryzacją.
///
/// Obsługuje logowanie, rejestrację, wylogowywanie i inne operacje
/// związane z autoryzacją użytkownika.
class AuthRepository extends BaseRepository {
  final StorageService _storageService;

  /// Konstruktor przyjmujący opcjonalną instancję ApiClient i StorageService
  AuthRepository({super.apiClient, StorageService? storageService})
    : _storageService = storageService ?? StorageService();

  /// Loguje użytkownika przy użyciu emaila i hasła.
  ///
  /// Zwraca sesję użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<Session> login({required String email, required String password}) async {
    try {
      final response = await apiClient.post('api/auth/login', data: {'email': email, 'password': password});

      final session = Session.fromMap(response.data);

      // Ustawienie tokenu autoryzacji w ApiClient
      apiClient.setAuthToken(session.accessToken);

      // Zapisanie danych sesji w lokalnym magazynie
      await _storageService.saveSession(session);

      return session;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas logowania: $e');
    }
  }

  /// Rejestruje nowego użytkownika.
  ///
  /// Zwraca sesję użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<Session> register({required String email, required String password, required String confirmPassword}) async {
    try {
      final response = await apiClient.post('api/auth/register', data: {'email': email, 'password': password});

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
        await _storageService.saveSession(session);

        return session;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Nieznany błąd podczas rejestracji',
          statusCode: response.statusCode,
          data: responseData,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas rejestracji: $e');
    }
  }

  /// Wylogowuje użytkownika.
  ///
  /// Wywołuje endpoint wylogowania i czyści token autoryzacji w ApiClient.
  Future<void> logout() async {
    try {
      // Wywołanie endpointu wylogowania
      await apiClient.post('api/auth/logout');

      // Czyszczenie tokenu autoryzacji
      apiClient.clearAuthToken();

      // Usunięcie danych sesji z lokalnego magazynu
      await _storageService.clearSession();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas wylogowywania: $e');
    }
  }

  /// Sprawdza, czy użytkownik jest zalogowany.
  ///
  /// Zwraca true, jeśli użytkownik jest zalogowany, false w przeciwnym razie.
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Inicjalizuje sesję użytkownika na podstawie danych z lokalnego magazynu.
  ///
  /// Jeśli dane sesji istnieją w lokalnym magazynie, ustawia token autoryzacji w ApiClient.
  /// Zwraca sesję użytkownika, jeśli istnieje, null w przeciwnym razie.
  Future<Session?> initSession() async {
    final session = await _storageService.getSession();

    if (session != null) {
      // Ustawienie tokenu autoryzacji w ApiClient
      apiClient.setAuthToken(session.accessToken);
    }

    return session;
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
        'api/auth/change-password',
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
  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
  }) async {
    try {
      final request = ForgotPasswordRequest(email: email);

      final response = await apiClient.post(
        'api/auth/forgot-password',
        data: request.toJson(),
      );

      return ForgotPasswordResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas żądania resetowania hasła: $e');
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
        'api/auth/reset-password',
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
