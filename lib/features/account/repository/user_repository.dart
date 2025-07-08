import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/shared/models/update_profile_request.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Repozytorium odpowiedzialne za operacje związane z profilem użytkownika.
///
/// Obsługuje pobieranie, aktualizację i usuwanie profilu użytkownika.
class UserRepository extends ApiRepository {
  /// Konstruktor przyjmujący opcjonalną instancję ApiClient
  const UserRepository({
    required super.apiClient,
  });

  /// Pobiera profil zalogowanego użytkownika.
  ///
  /// Zwraca dane użytkownika w przypadku powodzenia.
  /// W przypadku niepowodzenia rzuca wyjątek.
  Future<User> getProfile() async {
    try {
      final response = await apiClient.get('/api/users/me');
      return User.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas pobierania profilu: $e');
    }
  }

  /// Aktualizuje profil zalogowanego użytkownika.
  ///
  /// Przyjmuje opcjonalne pole name do aktualizacji.
  /// Zwraca odpowiedź z zaktualizowanymi danymi użytkownika.
  Future<UpdateProfileResponse> updateProfile({
    String? name,
  }) async {
    try {
      final request = UpdateProfileRequest(name: name);

      final response = await apiClient.patch(
        '/api/users/me',
        data: request.toJson(),
      );

      return UpdateProfileResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas aktualizacji profilu: $e');
    }
  }

  /// Usuwa konto zalogowanego użytkownika.
  ///
  /// Operacja jest nieodwracalna i usuwa wszystkie dane związane z użytkownikiem.
  /// Zwraca odpowiedź z informacją o powodzeniu operacji.
  Future<DeleteProfileResponse> deleteProfile() async {
    try {
      final response = await apiClient.delete('/api/users/me');
      return DeleteProfileResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił błąd podczas usuwania konta: $e');
    }
  }
}
