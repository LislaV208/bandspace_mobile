import '../api/api_client.dart';
import '../models/send_invitation_request.dart';
import '../models/invitation_response.dart';

class InvitationApi {
  final ApiClient _apiClient = ApiClient();

  /// Wysyła zaproszenie do projektu
  Future<SendInvitationResponse> sendInvitation({
    required int projectId,
    required String email,
  }) async {
    final request = SendInvitationRequest(email: email);
    
    final response = await _apiClient.post(
      '/api/projects/$projectId/invitations',
      data: request.toJson(),
    );

    return SendInvitationResponse.fromJson(response.data);
  }

  /// Pobiera listę zaproszeń dla projektu
  Future<InvitationsListResponse> getProjectInvitations({
    required int projectId,
  }) async {
    final response = await _apiClient.get(
      '/api/projects/$projectId/invitations',
    );

    return InvitationsListResponse.fromJson(response.data);
  }

  /// Anuluje zaproszenie
  Future<InvitationActionResponse> cancelInvitation({
    required int projectId,
    required int invitationId,
  }) async {
    final response = await _apiClient.delete(
      '/api/projects/$projectId/invitations/$invitationId',
    );

    return InvitationActionResponse.fromJson(response.data);
  }

  /// Pobiera szczegóły zaproszenia na podstawie tokenu
  Future<InvitationDetailsResponse> getInvitationDetails({
    required String token,
  }) async {
    final response = await _apiClient.get(
      '/api/invitations/$token',
    );

    return InvitationDetailsResponse.fromJson(response.data);
  }

  /// Akceptuje zaproszenie
  Future<InvitationActionResponse> acceptInvitation({
    required String token,
  }) async {
    final response = await _apiClient.post(
      '/api/invitations/$token/accept',
    );

    return InvitationActionResponse.fromJson(response.data);
  }

  /// Odrzuca zaproszenie
  Future<InvitationActionResponse> rejectInvitation({
    required String token,
  }) async {
    final response = await _apiClient.post(
      '/api/invitations/$token/reject',
    );

    return InvitationActionResponse.fromJson(response.data);
  }

  /// Pobiera listę zaproszeń użytkownika
  Future<InvitationsListResponse> getUserInvitations() async {
    final response = await _apiClient.get(
      '/api/user/invitations',
    );

    return InvitationsListResponse.fromJson(response.data);
  }
}