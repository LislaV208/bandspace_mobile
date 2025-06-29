import 'package:equatable/equatable.dart';
import 'project_invitation.dart';

class SendInvitationResponse extends Equatable {
  final bool success;
  final String message;
  final ProjectInvitation invitation;

  const SendInvitationResponse({
    required this.success,
    required this.message,
    required this.invitation,
  });

  factory SendInvitationResponse.fromJson(Map<String, dynamic> json) {
    return SendInvitationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      invitation: ProjectInvitation.fromJson(json['invitation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'invitation': invitation.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, invitation];
}

class InvitationsListResponse extends Equatable {
  final bool success;
  final List<ProjectInvitation> invitations;

  const InvitationsListResponse({
    required this.success,
    required this.invitations,
  });

  factory InvitationsListResponse.fromJson(Map<String, dynamic> json) {
    return InvitationsListResponse(
      success: json['success'] ?? false,
      invitations: (json['invitations'] as List<dynamic>?)
              ?.map((e) => ProjectInvitation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'invitations': invitations.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [success, invitations];
}

class InvitationDetailsResponse extends Equatable {
  final bool success;
  final ProjectInvitation invitation;

  const InvitationDetailsResponse({
    required this.success,
    required this.invitation,
  });

  factory InvitationDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InvitationDetailsResponse(
      success: json['success'] ?? false,
      invitation: ProjectInvitation.fromJson(json['invitation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'invitation': invitation.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, invitation];
}

class InvitationActionResponse extends Equatable {
  final bool success;
  final String message;

  const InvitationActionResponse({
    required this.success,
    required this.message,
  });

  factory InvitationActionResponse.fromJson(Map<String, dynamic> json) {
    return InvitationActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [success, message];
}