part of 'projects_repository.dart';

extension TracksManagement on ProjectsRepository {
  // Tworzy nowy track w projekcie.
  // POST /api/projects/{projectId}/tracks
  Future<Track> createTrack(
    int projectId,
    CreateTrackData trackData,
    File? file, {
    required void Function(int sent, int total)? onProgress,
  }) async {
    return addToList<Track>(
      listMethodName: 'getTracks',
      listParameters: {'projectId': projectId},
      createCall: () async {
        if (file != null) {
          // Utwór z plikiem - multipart
          final formData = FormData.fromMap({
            'title': trackData.title,
            if (trackData.bpm != null) 'bpm': trackData.bpm,
            'file': await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          });

          final response = await apiClient.post(
            '/api/projects/$projectId/tracks',
            data: formData,
            onSendProgress: onProgress,
          );

          return Track.fromJson(response.data);
        } else {
          // Utwór bez pliku - JSON
          final response = await apiClient.post(
            '/api/projects/$projectId/tracks',
            data: trackData.toJson(),
            onSendProgress: onProgress,
          );

          return Track.fromJson(response.data);
        }
      },
      fromJson: (json) => _trackFromJson(json),
    );
  }

  // Pobiera listę ścieżek dla danego projektu.
  // GET /api/projects/{projectId}/tracks
  Future<RepositoryResponse<List<Track>>> getTracks(int projectId) {
    return hybridListStream<Track>(
      methodName: 'getTracks',
      parameters: {'projectId': projectId},
      remoteCall: () async => _fetchTracks(projectId),
      fromJson: (json) => _trackFromJson(json),
    );
  }

  // Odświeża listę ścieżek dla danego projektu.
  Future<void> refreshTracks(int projectId) async {
    await refreshList<Track>(
      listMethodName: 'getTracks',
      listParameters: {'projectId': projectId},
      remoteCall: () async => _fetchTracks(projectId),
      fromJson: (json) => _trackFromJson(json),
    );
  }

  // Pobiera listę wersji dla danej ścieżki.
  // GET /api/tracks/{trackId}/versions
  Future<RepositoryResponse<List<Version>>> getVersions(int trackId) {
    return hybridListStream<Version>(
      methodName: 'getVersions',
      parameters: {'trackId': trackId},
      remoteCall: () async => _fetchVersions(trackId),
      fromJson: (json) => _versionFromJson(json),
    );
  }

  // Pobiera listę komentarzy dla danej wersji.
  // GET /api/versions/{versionId}/comments
  Future<RepositoryResponse<List<Comment>>> getComments(int versionId) {
    return hybridListStream<Comment>(
      methodName: 'getComments',
      parameters: {'versionId': versionId},
      remoteCall: () async => _fetchComments(versionId),
      fromJson: (json) => _commentFromJson(json),
    );
  }

  Future<List<Track>> _fetchTracks(int projectId) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/tracks',
    );

    final List<dynamic> tracksData = response.data;
    return tracksData.map((trackData) => _trackFromJson(trackData)).toList();
  }

  Future<List<Version>> _fetchVersions(int trackId) async {
    final response = await apiClient.get(
      '/api/tracks/$trackId/versions',
    );

    final List<dynamic> versionsData = response.data;
    return versionsData
        .map((versionData) => _versionFromJson(versionData))
        .toList();
  }

  Future<List<Comment>> _fetchComments(int versionId) async {
    final response = await apiClient.get(
      '/api/versions/$versionId/comments',
    );

    final List<dynamic> commentsData = response.data;
    return commentsData
        .map((commentData) => _commentFromJson(commentData))
        .toList();
  }

  Track _trackFromJson(Map<String, dynamic> json) {
    return Track.fromJson(json);
  }

  Version _versionFromJson(Map<String, dynamic> json) {
    return Version.fromJson(json);
  }

  Comment _commentFromJson(Map<String, dynamic> json) {
    return Comment.fromJson(json);
  }

  // Aktualizuje ścieżkę w projekcie.
  // PATCH /api/projects/{projectId}/tracks/{trackId}
  Future<Track> updateTrack(
    int projectId,
    int trackId,
    UpdateTrackData updateData,
  ) async {
    final updatedTrack = await updateSingle<Track>(
      methodName: 'getTrack',
      parameters: {'projectId': projectId, 'trackId': trackId},
      updateCall: () async {
        final response = await apiClient.patch(
          '/api/projects/$projectId/tracks/$trackId',
          data: updateData.toJson(),
        );
        return Track.fromJson(response.data);
      },
      fromJson: (json) => _trackFromJson(json),
    );

    // Odśwież listę ścieżek aby zaktualizować cache i reaktywny stream
    await refreshTracks(projectId);

    return updatedTrack;
  }

  // Usuwa ścieżkę z projektu.
  // DELETE /api/projects/{projectId}/tracks/{trackId}
  Future<void> deleteTrack(int projectId, int trackId) async {
    await removeFromList<Track>(
      listMethodName: 'getTracks',
      listParameters: {'projectId': projectId},
      deleteCall: () async {
        await apiClient.delete('/api/projects/$projectId/tracks/$trackId');
      },
      fromJson: (json) => _trackFromJson(json),
      predicate: (track) => track.id == trackId,
    );
  }

  // Pobiera szczegóły pojedynczej ścieżki.
  // GET /api/projects/{projectId}/tracks/{trackId}
  Stream<Track> getTrack(int projectId, int trackId) {
    return reactiveStream<Track>(
      methodName: 'getTrack',
      parameters: {'projectId': projectId, 'trackId': trackId},
      remoteCall: () async {
        final response = await apiClient.get(
          '/api/projects/$projectId/tracks/$trackId',
        );
        return Track.fromJson(response.data);
      },
      fromJson: (json) => _trackFromJson(json),
    );
  }

  // Odświeża szczegóły pojedynczej ścieżki.
  Future<void> refreshTrack(int projectId, int trackId) async {
    await refreshSingle<Track>(
      methodName: 'getTrack',
      parameters: {'projectId': projectId, 'trackId': trackId},
      remoteCall: () async {
        final response = await apiClient.get(
          '/api/projects/$projectId/tracks/$trackId',
        );
        return Track.fromJson(response.data);
      },
      fromJson: (json) => _trackFromJson(json),
    );
  }

  // Dodaje plik do istniejącego utworu.
  // POST /api/projects/{projectId}/tracks/{trackId}/file
  Future<Track> addTrackFile(
    int projectId,
    int trackId,
    File file, {
    required void Function(int sent, int total)? onProgress,
  }) async {
    final updatedTrack = await updateSingle<Track>(
      methodName: 'getTrack',
      parameters: {'projectId': projectId, 'trackId': trackId},
      updateCall: () async {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });

        final response = await apiClient.post(
          '/api/projects/$projectId/tracks/$trackId/file',
          data: formData,
          onSendProgress: onProgress,
        );

        return Track.fromJson(response.data);
      },
      fromJson: (json) => _trackFromJson(json),
    );

    // Odśwież listę ścieżek aby zaktualizować cache i reaktywny stream
    await refreshTracks(projectId);

    return updatedTrack;
  }
}
