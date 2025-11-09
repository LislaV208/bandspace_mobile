import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/shared/models/change_password_request.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Repozytorium odpowiedzialne za operacje związane z kontem użytkownika.
class AccountRepository extends CachedRepository {
  const AccountRepository({
    required super.apiClient,
    required super.databaseStorage,
  });

  /// Pobiera profil zalogowanego użytkownika.
  Stream<User> getProfile() {
    return reactiveStream<User>(
      methodName: 'getProfile',
      parameters: {},
      remoteCall: () async {
        final response = await apiClient.get('/api/account');
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
        final response = await apiClient.get('/api/account');
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
          '/api/account',
          data: {
            'name': name,
          },
        );

        return User.fromMap(response.data);
      },
      fromJson: (json) => User.fromMap(json),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    await apiClient.post(
      '/api/account/password',
      data: request.toJson(),
    );
  }

  /// Usuwa konto zalogowanego użytkownika.
  Future<void> deleteAccount() async {
    await apiClient.delete('/api/account');
    await invalidateAll();
  }

  Future<void> signOut() async {
    await apiClient.post('/api/auth/logout');
    await invalidateAll();
  }
}
