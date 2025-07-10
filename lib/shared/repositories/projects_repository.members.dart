part of 'projects_repository.dart';

extension MembersManagement on ProjectsRepository {
  // Pobiera listę członków projektu.
  // GET /api/projects/{projectId}/members
  Stream<List<ProjectMember>> getProjectMembers(int projectId) {
    return cachedListStream<ProjectMember>(
      methodName: 'getProjectMembers',
      parameters: {'projectId': projectId},
      remoteCall: () async => _fetchProjectMembers(projectId),
      fromJson: (json) => _projectMemberFromJson(json),
    );
  }

  // Odświeża listę członków projektu.
  Future<void> refreshProjectMembers(int projectId) async {
    await refreshList<ProjectMember>(
      listMethodName: 'getProjectMembers',
      listParameters: {'projectId': projectId},
      remoteCall: () async => _fetchProjectMembers(projectId),
      fromJson: (json) => _projectMemberFromJson(json),
    );
  }

  Future<List<ProjectMember>> _fetchProjectMembers(int projectId) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/members',
    );

    final List<dynamic> membersData = response.data;
    return membersData
        .map((memberData) => ProjectMember.fromJson(memberData))
        .toList();
  }

  ProjectMember _projectMemberFromJson(Map<String, dynamic> json) {
    return ProjectMember.fromJson(json);
  }
}
