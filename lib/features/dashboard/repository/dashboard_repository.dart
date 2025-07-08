import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/shared/models/invitation_response.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';

/// Repozytorium odpowiedzialne za operacje związane z dashboard.
// class DashboardRepository extends BaseRepository {
class DashboardRepository extends CachedRepository {
  DashboardRepository({
    required super.apiClient,
  });

  /// Pobiera listę wszystkich projektów użytkownika.
  Stream<List<Project>> getProjects() {
    return cachedListStream<Project>(
      methodName: 'getProjects',
      parameters: {},
      remoteCall: () async {
        final response = await apiClient.get('/api/projects');

        if (response.data == null) {
          return [];
        }

        final List<dynamic> projectsData = response.data;
        return projectsData
            .map((projectData) => Project.fromJson(projectData))
            .toList();
      },
      fromJson: (json) => Project.fromJson(json),
    );
  }

  /// Tworzy nowy projekt.
  Future<Project> createProject({
    required String name,
    String? description,
  }) async {
    try {
      final projectData = {
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await apiClient.post('/api/projects', data: projectData);

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas tworzenia projektu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return Project.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas tworzenia projektu: $e',
      );
    }
  }

  /// Usuwa projekt.
  Future<void> deleteProject(int projectId) async {
    try {
      await apiClient.delete('/api/projects/$projectId');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas usuwania projektu: $e',
      );
    }
  }

  /// Edytuje projekt.
  Future<Project> updateProject({
    required int projectId,
    required String name,
    String? description,
  }) async {
    try {
      final projectData = {
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await apiClient.patch(
        '/api/projects/$projectId',
        data: projectData,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas aktualizacji projektu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return Project.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas aktualizacji projektu: $e',
      );
    }
  }

  /// Pobiera listę zaproszeń użytkownika.
  Future<List<ProjectInvitation>> getUserInvitations() async {
    try {
      final response = await apiClient.get('/api/users/me/invitations');

      if (response.data == null) {
        return [];
      }

      final List<dynamic> invitationsData = response.data;
      return invitationsData
          .map((invitationData) => ProjectInvitation.fromJson(invitationData))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas pobierania zaproszeń: $e',
      );
    }
  }

  /// Pobiera szczegóły zaproszenia.
  Future<ProjectInvitation> getInvitationDetails(String token) async {
    try {
      final response = await apiClient.get('/api/invitations/$token');

      if (response.data == null) {
        throw ApiException(
          message:
              'Brak danych w odpowiedzi podczas pobierania szczegółów zaproszenia',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return ProjectInvitation.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas pobierania szczegółów zaproszenia: $e',
      );
    }
  }

  /// Akceptuje zaproszenie.
  Future<InvitationActionResponse> acceptInvitation(String token) async {
    try {
      final response = await apiClient.post('/api/invitations/$token/accept');

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas akceptacji zaproszenia',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return InvitationActionResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas akceptacji zaproszenia: $e',
      );
    }
  }

  /// Odrzuca zaproszenie.
  Future<InvitationActionResponse> rejectInvitation(String token) async {
    try {
      final response = await apiClient.post('/api/invitations/$token/reject');

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas odrzucenia zaproszenia',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return InvitationActionResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas odrzucenia zaproszenia: $e',
      );
    }
  }
}
