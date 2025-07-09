import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/features/project_detail/models/song_create_dto.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';
import 'package:bandspace_mobile/shared/models/send_invitation_request.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

/// Repozytorium odpowiedzialne za operacje związane z konkretnym projektem.
class ProjectDetailRepository extends CachedRepository {
  /// Konstruktor przyjmujący opcjonalną instancję ApiClient
  ProjectDetailRepository({required super.apiClient});

  /// Pobiera szczegóły projektu.
  ///
  /// Zwraca szczegóły projektu dla podanego ID.
  Stream<Project> getProject(int projectId) {
    return reactiveStream<Project>(
      methodName: 'getProject',
      parameters: {'projectId': projectId},
      remoteCall: () async {
        final response = await apiClient.get('/api/projects/$projectId');

        return Project.fromJson(response.data);
      },
      fromJson: (json) => Project.fromJson(json),
    );
  }

  /// Aktualizuje projekt.
  ///
  /// Przyjmuje ID projektu, nową nazwę i opcjonalny opis.
  /// Zwraca zaktualizowany projekt.
  Future<Project> updateProject({
    required int projectId,
    required String name,
  }) async {
    // Definicja API call
    Future<Project> apiCall() async {
      final projectData = {
        'name': name,
      };

      final response = await apiClient.patch(
        '/api/projects/$projectId',
        data: projectData,
      );

      return Project.fromJson(response.data);
    }

    // Aktualizuj pojedynczy cache projektu
    final updatedProject = await updateSingle<Project>(
      methodName: 'getProject',
      parameters: {'projectId': projectId},
      updateCall: apiCall,
      fromJson: (json) => Project.fromJson(json),
    );

    refreshList(
      customCacheKeyPrefix: 'dashboard',
      listMethodName: 'getProjects',
      listParameters: {},
      remoteCall: () async {
        final response = await apiClient.get('/api/projects');
        final List<dynamic> projectsData = response.data;
        return projectsData
            .map((projectData) => Project.fromJson(projectData))
            .toList();
      },
      fromJson: (json) => Project.fromJson(json),
    );

    return updatedProject;
  }

  /// Usuwa projekt.
  Future<void> deleteProject(int projectId) async {
    await removeFromList<Project>(
      listMethodName: 'getProjects',
      listParameters: {},
      deleteCall: () async {
        await apiClient.delete('/api/projects/$projectId');
      },
      fromJson: (json) => Project.fromJson(json),
      predicate: (project) => project.id == projectId,
      customCacheKeyPrefix: 'dashboard',
    );
  }

  /// Usuwa członka z projektu.
  ///
  /// Przyjmuje ID projektu i ID użytkownika do usunięcia.
  Future<void> removeMember(int projectId, int userId) async {
    try {
      await apiClient.delete(
        '/api/projects/$projectId/members/$userId',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas usuwania członka: $e',
      );
    }
  }

  /// Opuszcza projekt.
  ///
  /// Usuwa aktualnego użytkownika z projektu.
  Future<void> leaveProject(int projectId) async {
    try {
      await apiClient.delete('/api/projects/$projectId/members/me');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas opuszczania projektu: $e',
      );
    }
  }

  /// Wysyła zaproszenie do projektu.
  ///
  /// Przyjmuje ID projektu i dane zaproszenia.
  /// Zwraca utworzone zaproszenie.
  Future<ProjectInvitation> sendInvitation(
    int projectId,
    SendInvitationRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        '/api/projects/$projectId/invitations',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas wysyłania zaproszenia',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return ProjectInvitation.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas wysyłania zaproszenia: $e',
      );
    }
  }

  /// Pobiera listę zaproszeń do projektu.
  ///
  /// Zwraca listę aktywnych zaproszeń dla podanego projektu.
  Future<List<ProjectInvitation>> getProjectInvitations(
    int projectId,
  ) async {
    try {
      final response = await apiClient.get(
        '/api/projects/$projectId/invitations',
      );

      if (response.data == null) {
        return [];
      }

      final List<dynamic> invitationsData = response.data;
      return invitationsData
          .map(
            (invitationData) => ProjectInvitation.fromJson(invitationData),
          )
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas pobierania zaproszeń: $e',
      );
    }
  }

  /// Anuluje zaproszenie do projektu.
  ///
  /// Przyjmuje ID projektu i ID zaproszenia.
  Future<void> cancelInvitation(
    int projectId,
    int invitationId,
  ) async {
    try {
      await apiClient.delete(
        '/api/projects/$projectId/invitations/$invitationId',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas anulowania zaproszenia: $e',
      );
    }
  }

  /// Pobiera listę utworów dla danego projektu.
  Stream<List<Song>> getProjectSongs(int projectId) {
    return reactiveListStream<Song>(
      methodName: 'getProjectSongs',
      parameters: {'projectId': projectId},
      remoteCall: () async {
        final response = await apiClient.get(
          '/api/projects/$projectId/songs',
        );

        final List<dynamic> songsData = response.data;
        return songsData.map((songData) => Song.fromJson(songData)).toList();
      },
      fromJson: (json) => Song.fromJson(json),
    );
  }

  /// Tworzy nowy utwór w projekcie.
  Future<Song> createSong(
    int projectId,
    SongCreateDto songData,
    void Function(int sent, int total)? onProgress,
  ) async {
    return addToList<Song>(
      listMethodName: 'getProjectSongs',
      listParameters: {'projectId': projectId},
      createCall: () async {
        // TODO: wyodrebnic rzeczy zwiazane z dio do core (apiClient)
        final formData = FormData.fromMap({
          'title': songData.title,
          'file': await MultipartFile.fromFile(
            songData.file.path,
            filename: songData.file.path.split('/').last,
          ),
        });

        final response = await apiClient.post(
          '/api/projects/$projectId/songs',
          data: formData,
          onSendProgress: onProgress,
        );

        return Song.fromJson(response.data);
      },
      fromJson: (json) => Song.fromJson(json),
    );
  }

  /// Aktualizuje utwór w projekcie.
  ///
  /// Przyjmuje ID projektu, ID utworu i nowe dane.
  /// Zwraca zaktualizowany utwór.
  Future<Song> updateSong(
    int projectId,
    int songId,
    Map<String, dynamic> songData,
  ) async {
    try {
      final response = await apiClient.patch(
        '/api/projects/$projectId/songs/$songId',
        data: songData,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas aktualizacji utworu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return Song.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas aktualizacji utworu: $e',
      );
    }
  }

  /// Usuwa utwór z projektu.
  ///
  /// Przyjmuje ID projektu i ID utworu.
  Future<void> deleteSong(int projectId, int songId) async {
    try {
      await apiClient.delete(
        '/api/projects/$projectId/songs/$songId',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Wystąpił nieoczekiwany błąd podczas usuwania utworu: $e',
      );
    }
  }
}
