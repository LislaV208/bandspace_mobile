import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/session.dart';
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

      if (responseData['success'] == true) {
        final session = Session.fromMap(responseData['session']);

        // Ustawienie tokenu autoryzacji w ApiClient
        apiClient.setAuthToken(session.accessToken);

        // Zapisanie danych sesji w lokalnym magazynie
        await _storageService.saveSession(session);

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
}
