part of 'projects_repository.dart';

extension SongsManagement on ProjectsRepository {
  // Pobiera listę utworów dla danego projektu.
  // GET /api/projects/{projectId}/songs
  Stream<List<Song>> getSongs(int projectId, {bool forceRefresh = false}) {
    if (forceRefresh) {
      return cachedListStream<Song>(
        methodName: 'getSongs',
        parameters: {'projectId': projectId},
        remoteCall: () async {
          final response = await apiClient.get(
            '/api/projects/$projectId/songs',
          );

          final List<dynamic> songsData = response.data;
          return songsData.map((songData) => _songFromJson(songData)).toList();
        },
        fromJson: (json) => _songFromJson(json),
        forceRefresh: forceRefresh,
      );
    }

    return reactiveListStream<Song>(
      methodName: 'getSongs',
      parameters: {'projectId': projectId},
      remoteCall: () async {
        final response = await apiClient.get(
          '/api/projects/$projectId/songs',
        );

        final List<dynamic> songsData = response.data;
        return songsData.map((songData) => _songFromJson(songData)).toList();
      },
      fromJson: (json) => _songFromJson(json),
    );
  }

  // Tworzy nowy utwór w projekcie.
  // POST /api/projects/{projectId}/songs
  Future<Song> createSong(
    int projectId,
    SongCreateDto songData,
    void Function(int sent, int total)? onProgress,
  ) async {
    return addToList<Song>(
      listMethodName: 'getSongs',
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
      fromJson: (json) => _songFromJson(json),
    );
  }

  Song _songFromJson(Map<String, dynamic> json) {
    return Song.fromJson(json);
  }
}
