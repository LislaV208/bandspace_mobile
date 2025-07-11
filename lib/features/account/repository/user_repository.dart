import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Repozytorium odpowiedzialne za operacje związane z profilem użytkownika.
class UserRepository extends CachedRepository {
  const UserRepository({
    required super.apiClient,
  });

  /// Pobiera profil zalogowanego użytkownika.
  Stream<User> getProfile() {
    return reactiveStream<User>(
      methodName: 'getProfile',
      parameters: {},
      remoteCall: () async {
        final response = await apiClient.get('/api/users/me');
        return User.fromMap(response.data);
      },
      fromJson: (json) => User.fromMap(json),
    );
  }

  /// Odświeża profil zalogowanego użytkownika.
  Future<void> refreshProfile() async {
    await refreshSingle<User>(
      methodName: 'getProfile',
      parameters: {},
      remoteCall: () async {
        final response = await apiClient.get('/api/users/me');
        return User.fromMap(response.data);
      },
      fromJson: (json) => User.fromMap(json),
    );
  }

  /// Aktualizuje profil zalogowanego użytkownika.
  Future<User> updateProfile({
    String? name,
  }) async {
    return updateSingle<User>(
      methodName: 'getProfile',
      parameters: {},
      updateCall: () async {
        final response = await apiClient.patch(
          '/api/users/me',
          data: {
            'name': name,
          },
        );

        return User.fromMap(response.data['user']);
      },
      fromJson: (json) => User.fromMap(json),
    );
  }

  /// Usuwa konto zalogowanego użytkownika.
  Future<void> deleteProfile() async {
    await apiClient.delete('/api/users/me');
    await CachedRepository.invalidateAll();
  }
}
