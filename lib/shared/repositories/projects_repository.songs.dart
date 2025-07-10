part of 'projects_repository.dart';

extension SongsManagement on ProjectsRepository {
  // Pobiera listę utworów dla danego projektu.
  // GET /api/projects/{projectId}/songs
  Stream<List<Song>> getSongs(int projectId) {
    return reactiveListStream<Song>(
      methodName: 'getSongs',
      parameters: {'projectId': projectId},
      remoteCall: () async => _fetchSongs(projectId),
      fromJson: (json) => _songFromJson(json),
    );
  }

  // Odświeża listę utworów dla danego projektu.
  Future<void> refreshSongs(int projectId) async {
    await refreshList<Song>(
      listMethodName: 'getSongs',
      listParameters: {'projectId': projectId},
      remoteCall: () async => _fetchSongs(projectId),
      fromJson: (json) => _songFromJson(json),
    );
  }

  // Tworzy nowy utwór w projekcie.
  // POST /api/projects/{projectId}/songs
  Future<Song> createSong(
    int projectId,
    CreateSongData songData,
    File file, {
    required void Function(int sent, int total)? onProgress,
  }) async {
    return addToList<Song>(
      listMethodName: 'getSongs',
      listParameters: {'projectId': projectId},
      createCall: () async {
        // TODO: wyodrebnic rzeczy zwiazane z dio do core (apiClient)
        final formData = FormData.fromMap({
          'title': songData.title,
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });

        final response = await apiClient.post(
          '/api/projects/$projectId/songs',
          data: formData,
          onSendProgress: onProgress,
        );

        return Song.fromJson(response.data);
      },
      fromJson: (json) => _songFromJson(json),
    );
  }

  Future<List<Song>> _fetchSongs(int projectId) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/songs',
    );

    final List<dynamic> songsData = response.data;
    return songsData.map((songData) => _songFromJson(songData)).toList();
  }

  Song _songFromJson(Map<String, dynamic> json) {
    return Song.fromJson(json);
  }
}
