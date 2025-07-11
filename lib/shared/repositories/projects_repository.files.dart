part of 'projects_repository.dart';

extension FilesManagement on ProjectsRepository {
  // Pobiera plik dla danego utworu.
  // GET /api/projects/{projectId}/songs/{songId}/file
  Stream<SongFile?> getSongFile(int projectId, int songId) {
    return reactiveStream<SongFile?>(
      methodName: 'getSongFile',
      parameters: {'projectId': projectId, 'songId': songId},
      remoteCall: () async => _fetchSongFile(projectId, songId),
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Odświeża plik dla danego utworu.
  Future<void> refreshSongFile(int projectId, int songId) async {
    await refreshSingle<SongFile?>(
      methodName: 'getSongFile',
      parameters: {'projectId': projectId, 'songId': songId},
      remoteCall: () async => _fetchSongFile(projectId, songId),
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Aktualizuje metadane pliku.
  // PATCH /api/projects/{projectId}/songs/{songId}/file
  Future<SongFile> updateSongFile(
    int projectId,
    int songId,
    UpdateSongFileData updateData,
  ) async {
    return updateSingle<SongFile>(
      methodName: 'getSongFile',
      parameters: {'projectId': projectId, 'songId': songId},
      updateCall: () async {
        final response = await apiClient.patch(
          '/api/projects/$projectId/songs/$songId/file',
          data: updateData.toJson(),
        );

        return _songFileFromJson(response.data);
      },
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Usuwa plik z utworu.
  // DELETE /api/projects/{projectId}/songs/{songId}/file
  Future<void> deleteSongFile(int projectId, int songId) async {
    await updateSingle<SongFile?>(
      methodName: 'getSongFile',
      parameters: {'projectId': projectId, 'songId': songId},
      updateCall: () async {
        await apiClient.delete(
          '/api/projects/$projectId/songs/$songId/file',
        );
        return null;
      },
      fromJson: (json) => null,
    );
  }

  // Pobiera URL do pobrania pliku.
  // GET /api/projects/{projectId}/songs/{songId}/file/download-url
  Future<String> getSongFileDownloadUrl(
    int projectId,
    int songId,
  ) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/songs/$songId/file/download-url',
    );

    return response.data['url'];
  }

  Future<SongFile?> _fetchSongFile(int projectId, int songId) async {
    try {
      print(
        'Repository: Fetching song file for project: $projectId, song: $songId',
      ); // Debug log
      final response = await apiClient.get(
        '/api/projects/$projectId/songs/$songId/file',
      );

      print('Repository: Response status: ${response.statusCode}'); // Debug log
      print('Repository: Response data: ${response.data}'); // Debug log

      return _songFileFromJson(response.data);
    } catch (e) {
      print('Repository: Error fetching song file: $e'); // Debug log
      // Jeśli plik nie istnieje, zwracamy null
      return null;
    }
  }

  SongFile _songFileFromJson(Map<String, dynamic> json) {
    return SongFile.fromJson(json);
  }
}
