part of 'projects_repository.dart';

extension FilesManagement on ProjectsRepository {
  // Pobiera listę plików dla danego utworu.
  // GET /api/projects/{projectId}/songs/{songId}/files
  Stream<List<SongFile>> getSongFiles(int projectId, int songId) {
    return reactiveListStream<SongFile>(
      methodName: 'getSongFiles',
      parameters: {'projectId': projectId, 'songId': songId},
      remoteCall: () async => _fetchSongFiles(projectId, songId),
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Odświeża listę plików dla danego utworu.
  Future<void> refreshSongFiles(int projectId, int songId) async {
    await refreshList<SongFile>(
      listMethodName: 'getSongFiles',
      listParameters: {'projectId': projectId, 'songId': songId},
      remoteCall: () async => _fetchSongFiles(projectId, songId),
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Pobiera metadane pliku.
  // GET /api/projects/{projectId}/songs/{songId}/files/{fileId}
  Stream<SongFile> getSongFile(int projectId, int songId, int fileId) {
    return reactiveStream<SongFile>(
      methodName: 'getSongFile',
      parameters: {'projectId': projectId, 'songId': songId, 'fileId': fileId},
      remoteCall: () async {
        final response = await apiClient.get(
          '/api/projects/$projectId/songs/$songId/files/$fileId',
        );
        return _songFileFromJson(response.data);
      },
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Aktualizuje metadane pliku.
  // PATCH /api/projects/{projectId}/songs/{songId}/files/{fileId}
  Future<SongFile> updateSongFile(
    int projectId,
    int songId,
    int fileId,
    UpdateSongFileData updateData,
  ) async {
    return updateSingle<SongFile>(
      methodName: 'getSongFile',
      parameters: {'projectId': projectId, 'songId': songId, 'fileId': fileId},
      updateCall: () async {
        final response = await apiClient.patch(
          '/api/projects/$projectId/songs/$songId/files/$fileId',
          data: updateData.toJson(),
        );

        return _songFileFromJson(response.data);
      },
      fromJson: (json) => _songFileFromJson(json),
    );
  }

  // Usuwa plik z utworu.
  // DELETE /api/projects/{projectId}/songs/{songId}/files/{fileId}
  Future<void> deleteSongFile(int projectId, int songId, int fileId) async {
    await removeFromList<SongFile>(
      listMethodName: 'getSongFiles',
      listParameters: {'projectId': projectId, 'songId': songId},
      deleteCall: () async {
        await apiClient.delete(
          '/api/projects/$projectId/songs/$songId/files/$fileId',
        );
      },
      fromJson: (json) => _songFileFromJson(json),
      predicate: (file) => file.id == fileId,
    );
  }

  // Pobiera URL do pobrania pliku.
  // GET /api/projects/{projectId}/songs/{songId}/files/{fileId}/download-url
  Future<String> getSongFileDownloadUrl(
    int projectId,
    int songId,
    int fileId,
  ) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/songs/$songId/files/$fileId/download-url',
    );

    return response.data['url'];
  }

  Future<List<SongFile>> _fetchSongFiles(int projectId, int songId) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/songs/$songId/files',
    );

    final List<dynamic> filesData = response.data;
    return filesData.map((fileData) => _songFileFromJson(fileData)).toList();
  }

  SongFile _songFileFromJson(Map<String, dynamic> json) {
    return SongFile.fromJson(json);
  }
}
