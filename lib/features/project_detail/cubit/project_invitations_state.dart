// import 'package:equatable/equatable.dart';
// import '../../core/models/project_invitation.dart';

// enum ProjectInvitationsStatus {
//   initial,
//   loading,
//   loaded,
//   error,
// }

// class ProjectInvitationsState extends Equatable {
//   final ProjectInvitationsStatus status;
//   final List<ProjectInvitation> invitations;
//   final String? errorMessage;
//   final String? successMessage;
//   final bool isSendingInvitation;
//   final bool isCancelingInvitation;

//   const ProjectInvitationsState({
//     this.status = ProjectInvitationsStatus.initial,
//     this.invitations = const [],
//     this.errorMessage,
//     this.successMessage,
//     this.isSendingInvitation = false,
//     this.isCancelingInvitation = false,
//   });

//   ProjectInvitationsState copyWith({
//     ProjectInvitationsStatus? status,
//     List<ProjectInvitation>? invitations,
//     String? errorMessage,
//     String? successMessage,
//     bool? isSendingInvitation,
//     bool? isCancelingInvitation,
//   }) {
//     return ProjectInvitationsState(
//       status: status ?? this.status,
//       invitations: invitations ?? this.invitations,
//       errorMessage: errorMessage,
//       successMessage: successMessage,
//       isSendingInvitation: isSendingInvitation ?? this.isSendingInvitation,
//       isCancelingInvitation: isCancelingInvitation ?? this.isCancelingInvitation,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         status,
//         invitations,
//         errorMessage,
//         successMessage,
//         isSendingInvitation,
//         isCancelingInvitation,
//       ];
// }
