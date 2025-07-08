import 'package:equatable/equatable.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';

enum UserInvitationsStatus {
  initial,
  loading,
  loaded,
  error,
}

class UserInvitationsState extends Equatable {
  final UserInvitationsStatus status;
  final List<ProjectInvitation> invitations;
  final String? errorMessage;
  final String? successMessage;
  final bool isProcessingInvitation;

  const UserInvitationsState({
    this.status = UserInvitationsStatus.initial,
    this.invitations = const [],
    this.errorMessage,
    this.successMessage,
    this.isProcessingInvitation = false,
  });

  UserInvitationsState copyWith({
    UserInvitationsStatus? status,
    List<ProjectInvitation>? invitations,
    String? errorMessage,
    String? successMessage,
    bool? isProcessingInvitation,
  }) {
    return UserInvitationsState(
      status: status ?? this.status,
      invitations: invitations ?? this.invitations,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isProcessingInvitation: isProcessingInvitation ?? this.isProcessingInvitation,
    );
  }

  @override
  List<Object?> get props => [
        status,
        invitations,
        errorMessage,
        successMessage,
        isProcessingInvitation,
      ];
}