import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';
import 'package:bandspace_mobile/shared/repositories/invitations_repository.dart';
import 'package:bandspace_mobile/shared/utils/error_logger.dart';

import 'project_invitations_state.dart';

class ProjectInvitationsCubit extends Cubit<ProjectInvitationsState> {
  final InvitationsRepository _invitationsRepository;
  final int projectId;

  ProjectInvitationsCubit({
    required InvitationsRepository invitationsRepository,
    required this.projectId,
  }) : _invitationsRepository = invitationsRepository,
       super(const ProjectInvitationsInitial());

  Future<void> loadInvitations() async {
    emit(const ProjectInvitationsLoading());

    try {
      final invitations = await _invitationsRepository.getProjectInvitations(
        projectId,
      );
      emit(ProjectInvitationsLoadSuccess(invitations));
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
      );
      emit(ProjectInvitationsLoadFailure(e.toString()));
    }
  }

  Future<void> sendInvitation(String email) async {
    // Get current invitations before starting the action
    final currentInvitations = _getCurrentInvitations();
    emit(ProjectInvitationsSending(currentInvitations));

    try {
      await _invitationsRepository.sendInvitation(
        projectId: projectId,
        email: email,
      );

      final updatedInvitations = await _invitationsRepository.getProjectInvitations(projectId);
      emit(
        ProjectInvitationsSendSuccess(
          message: 'Zaproszenie zostało wysłane',
          invitations: updatedInvitations,
        ),
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
      );
      emit(
        ProjectInvitationsSendFailure(
          message: e.toString(),
          invitations: currentInvitations,
        ),
      );
    }
  }

  Future<void> cancelInvitation(int invitationId) async {
    // Get current invitations before starting the action
    final currentInvitations = _getCurrentInvitations();
    emit(ProjectInvitationsCanceling(currentInvitations));

    try {
      await _invitationsRepository.cancelInvitation(
        projectId: projectId,
        invitationId: invitationId,
      );

      final updatedInvitations = await _invitationsRepository.getProjectInvitations(projectId);
      emit(ProjectInvitationsCancelSuccess(updatedInvitations));
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
      );
      emit(
        ProjectInvitationsCancelFailure(
          message: e.toString(),
          invitations: currentInvitations,
        ),
      );
    }
  }

  void refreshInvitations() => loadInvitations();

  /// Helper method to get current invitations from state
  List<ProjectInvitation> _getCurrentInvitations() {
    final currentState = state;
    if (currentState is ProjectInvitationsWithData) {
      return currentState.invitations;
    }
    return [];
  }
}
