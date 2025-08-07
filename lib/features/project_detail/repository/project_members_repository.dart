import 'package:bandspace_mobile/core/api/cached_repository.dart';
import 'package:bandspace_mobile/shared/models/project_user.dart';

class ProjectMembersRepository extends CachedRepository {
  const ProjectMembersRepository({
    required super.apiClient,
  });

  /// Pobiera listę członków projektu.
  Stream<List<ProjectMember>> getProjectMembers(int projectId) {
    return cachedListStream<ProjectMember>(
      methodName: 'getProjectMembers',
      parameters: {'projectId': projectId},
      remoteCall: () async {
        final response = await apiClient.get(
          '/api/projects/$projectId/members',
        );

        final List<dynamic> membersData = response.data;
        return membersData
            .map((memberData) => ProjectMember.fromJson(memberData))
            .toList();
      },
      fromJson: (json) => ProjectMember.fromJson(json),
    );
  }
}
