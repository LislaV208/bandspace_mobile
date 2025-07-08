// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../core/api/invitation_api.dart';
// import '../../core/models/project_invitation.dart';
// import 'project_invitations_state.dart';

// class ProjectInvitationsCubit extends Cubit<ProjectInvitationsState> {
//   final InvitationApi _invitationApi;
//   final int projectId;

//   ProjectInvitationsCubit({
//     required InvitationApi invitationApi,
//     required this.projectId,
//   })  : _invitationApi = invitationApi,
//         super(const ProjectInvitationsState());

//   /// Ładuje zaproszenia dla projektu
//   Future<void> loadInvitations() async {
//     emit(state.copyWith(status: ProjectInvitationsStatus.loading));

//     try {
//       final response = await _invitationApi.getProjectInvitations(
//         projectId: projectId,
//       );

//       emit(state.copyWith(
//         status: ProjectInvitationsStatus.loaded,
//         invitations: response.invitations,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         status: ProjectInvitationsStatus.error,
//         errorMessage: e.toString(),
//       ));
//     }
//   }

//   /// Wysyła zaproszenie do użytkownika
//   Future<void> sendInvitation(String email) async {
//     emit(state.copyWith(isSendingInvitation: true));

//     try {
//       final response = await _invitationApi.sendInvitation(
//         projectId: projectId,
//         email: email,
//       );

//       // Dodaj nowe zaproszenie do listy
//       final updatedInvitations = List<ProjectInvitation>.from(state.invitations)
//         ..add(response.invitation);

//       emit(state.copyWith(
//         isSendingInvitation: false,
//         invitations: updatedInvitations,
//         successMessage: response.message,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         isSendingInvitation: false,
//         errorMessage: e.toString(),
//       ));
//     }
//   }

//   /// Anuluje zaproszenie
//   Future<void> cancelInvitation(int invitationId) async {
//     emit(state.copyWith(isCancelingInvitation: true));

//     try {
//       final response = await _invitationApi.cancelInvitation(
//         projectId: projectId,
//         invitationId: invitationId,
//       );

//       // Usuń zaproszenie z listy
//       final updatedInvitations = state.invitations
//           .where((invitation) => invitation.id != invitationId)
//           .toList();

//       emit(state.copyWith(
//         isCancelingInvitation: false,
//         invitations: updatedInvitations,
//         successMessage: response.message,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         isCancelingInvitation: false,
//         errorMessage: e.toString(),
//       ));
//     }
//   }

//   /// Czyści komunikat o błędzie
//   void clearError() {
//     emit(state.copyWith(errorMessage: null));
//   }

//   /// Czyści komunikat o sukcesie
//   void clearSuccess() {
//     emit(state.copyWith(successMessage: null));
//   }

// }
