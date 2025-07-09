import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class ProjectSongsRepository extends CachedRepository {
  const ProjectSongsRepository({
    required super.apiClient,
  });

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
}
