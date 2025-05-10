import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/session.dart';
import 'package:bandspace_mobile/core/repositories/base_repository.dart';

/// Repozytorium odpowiedzialne za operacje związane z autoryzacją.
///
/// Obsługuje logowanie, rejestrację, wylogowywanie i inne operacje
/// związane z autoryzacją użytkownika.
class AuthRepository extends BaseRepository {
  /// Konstruktor przyjmujący opcjonalną instancję ApiClient
  AuthRepository({super.apiClient});

  /// Loguje użytkownika przy użyciu emaila i hasła.
  ///
  /// Zwraca sesję użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<Session> login({required String email, required String password}) async {
    try {
      final response = await apiClient.post('api/auth/login', data: {'email': email, 'password': password});

      final responseData = response.data;

      if (responseData['success'] == true) {
        final session = Session.fromJson(responseData['session']);

        // Ustawienie tokenu autoryzacji w ApiClient
        apiClient.setAuthToken(session.accessToken);

        return session;
      } else {
        throw ApiException(
          message: responseData['error'] ?? 'Nieznany błąd podczas logowania',
          statusCode: response.statusCode,
          data: responseData,
        );
      }
    } on ApiException {
      rethrow;
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
      final response = await apiClient.post(
        'api/auth/register',
        data: {'email': email, 'password': password, 'confirmPassword': confirmPassword},
      );

      final responseData = response.data;

      if (responseData['success'] == true) {
        final session = Session.fromJson(responseData['session']);

        // Ustawienie tokenu autoryzacji w ApiClient
        apiClient.setAuthToken(session.accessToken);

        return session;
      } else {
        throw ApiException(
          message: responseData['error'] ?? 'Nieznany błąd podczas rejestracji',
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
      final response = await apiClient.post('api/auth/logout');

      final responseData = response.data;

      if (responseData['success'] != true) {
        throw ApiException(
          message: responseData['error'] ?? 'Nieznany błąd podczas wylogowywania',
          statusCode: response.statusCode,
          data: responseData,
        );
      }

      // Czyszczenie tokenu autoryzacji
      apiClient.clearAuthToken();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas wylogowywania: $e');
    }
  }
}
