import 'dart:io';

import 'package:bandspace_mobile/shared/models/song_download_url.dart';
import 'package:dio/dio.dart';

import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/project_member.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/models/song_create_data.dart';
import 'package:bandspace_mobile/shared/models/update_song_data.dart';

part 'projects_repository.songs.dart';
part 'projects_repository.members.dart';

class ProjectsRepository extends CachedRepository {
  const ProjectsRepository({
    required super.apiClient,
  });

  // Pobiera listę wszystkich projektów użytkownika.
  // GET /api/projects
  Stream<List<Project>> getProjects({bool forceRefresh = false}) {
    if (forceRefresh) {
      return cachedListStream<Project>(
        methodName: 'getProjects',
        parameters: {},
        remoteCall: _fetchProjects,
        fromJson: (json) => _projectFromJson(json),
        forceRefresh: forceRefresh,
      );
    }

    return reactiveListStream<Project>(
      methodName: 'getProjects',
      parameters: {},
      remoteCall: _fetchProjects,
      fromJson: (json) => _projectFromJson(json),
    );
  }

  // Odświeża listę projektów.
  Future<void> refreshProjects() async {
    await refreshList<Project>(
      listMethodName: 'getProjects',
      listParameters: {},
      remoteCall: _fetchProjects,
      fromJson: (json) => _projectFromJson(json),
    );
  }

  // Tworzy nowy projekt.
  // POST /api/projects
  Future<Project> createProject({
    required String name,
    String? description,
  }) async {
    return addToList<Project>(
      listMethodName: 'getProjects',
      listParameters: {},
      createCall: () async {
        final response = await apiClient.post(
          '/api/projects',
          data: {
            'name': name,
            if (description != null) 'description': description,
          },
        );
        return _projectFromJson(response.data);
      },
      fromJson: (json) => _projectFromJson(json),
    );
  }

  // Pobiera szczegóły projektu.
  // GET /api/projects/{projectId}
  Stream<Project> getProject(int projectId) {
    return reactiveStream<Project>(
      methodName: 'getProject',
      parameters: {'projectId': projectId},
      remoteCall: () async {
        final response = await apiClient.get('/api/projects/$projectId');
        return _projectFromJson(response.data);
      },
      fromJson: (json) => _projectFromJson(json),
    );
  }

  // Aktualizuje projekt.
  // PATCH /api/projects/{projectId}
  Future<Project> updateProject({
    required int projectId,
    required String name,
  }) async {
    final updatedProject = await updateSingle<Project>(
      methodName: 'getProject',
      parameters: {'projectId': projectId},
      updateCall: () async {
        final response = await apiClient.patch(
          '/api/projects/$projectId',
          data: {
            'name': name,
          },
        );

        return _projectFromJson(response.data);
      },
      fromJson: (json) => _projectFromJson(json),
    );

    return updatedProject;
  }

  // Usuwa projekt.
  // DELETE /api/projects/{projectId}
  Future<void> deleteProject(int projectId) async {
    await removeFromList<Project>(
      listMethodName: 'getProjects',
      listParameters: {},
      deleteCall: () async {
        await apiClient.delete('/api/projects/$projectId');
      },
      fromJson: (json) => _projectFromJson(json),
      predicate: (project) => project.id == projectId,
    );
  }

  Future<List<Project>> _fetchProjects() async {
    final response = await apiClient.get('/api/projects');
    final List<dynamic> projectsData = response.data;
    return projectsData
        .map((projectData) => _projectFromJson(projectData))
        .toList();
  }

  Project _projectFromJson(Map<String, dynamic> json) {
    return Project.fromJson(json);
  }
}
