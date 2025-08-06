import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';

class InvitationsRepository extends ApiRepository {
  const InvitationsRepository({
    required super.apiClient,
  });

  Future<InvitationResponse> sendInvitation({
    required int projectId,
    required String email,
  }) async {
    final response = await apiClient.post(
      '/api/projects/$projectId/invitations',
      data: {'email': email},
    );
    return InvitationResponse.fromJson(response.data);
  }

  Future<List<ProjectInvitation>> getProjectInvitations(int projectId) async {
    final response = await apiClient.get(
      '/api/projects/$projectId/invitations',
    );
    final invitationListResponse = InvitationListResponse.fromJson(
      response.data,
    );
    final invitationsData = invitationListResponse.invitations;

    return invitationsData;
  }

  Future<void> cancelInvitation({
    required int projectId,
    required int invitationId,
  }) async {
    await apiClient.delete(
      '/api/projects/$projectId/invitations/$invitationId',
    );
  }

  Future<InvitationListResponse> getUserInvitations() async {
    final response = await apiClient.get('/api/user/invitations');
    return InvitationListResponse.fromJson(response.data);
  }

  Future<void> acceptInvitation(int invitationId) async {
    await apiClient.post('/api/invitations/$invitationId/accept');
  }

  Future<void> rejectInvitation(int invitationId) async {
    await apiClient.post('/api/invitations/$invitationId/reject');
  }
}
