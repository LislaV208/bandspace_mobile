part of 'projects_repository.dart';

extension TracksManagement on ProjectsRepository {
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
    return versionsData.map((versionData) => _versionFromJson(versionData)).toList();
  }

  Future<List<Comment>> _fetchComments(int versionId) async {
    final response = await apiClient.get(
      '/api/versions/$versionId/comments',
    );

    final List<dynamic> commentsData = response.data;
    return commentsData.map((commentData) => _commentFromJson(commentData)).toList();
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
}
