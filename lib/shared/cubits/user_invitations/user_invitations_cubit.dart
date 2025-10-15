import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:bandspace_mobile/shared/repositories/invitations_repository.dart';

import 'user_invitations_state.dart';

class UserInvitationsCubit extends Cubit<UserInvitationsState> {
  final InvitationsRepository _invitationsRepository;

  UserInvitationsCubit({required InvitationsRepository invitationsRepository})
    : _invitationsRepository = invitationsRepository,
      super(const UserInvitationsInitial());

  Future<void> loadInvitations() async {
    emit(const UserInvitationsLoading());

    try {
      final invitations = await _invitationsRepository.getUserInvitations();
      emit(UserInvitationsLoadSuccess(invitations));
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to load user invitations',
      );
      emit(UserInvitationsLoadFailure(e.toString()));
    }
  }

  Future<void> acceptInvitation(int invitationId) async {
    emit(const UserInvitationsAccepting());

    try {
      await _invitationsRepository.acceptInvitation(invitationId);
      final invitations = await _invitationsRepository.getUserInvitations();
      emit(
        UserInvitationsActionSuccess(
          message: 'Zaproszenie zostało przyjęte',
          invitations: invitations,
        ),
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to accept user invitation',
        extras: {'invitationId': invitationId},
      );
      emit(UserInvitationsActionFailure(e.toString()));
    }
  }

  Future<void> rejectInvitation(int invitationId) async {
    emit(const UserInvitationsRejecting());

    try {
      await _invitationsRepository.rejectInvitation(invitationId);
      final invitations = await _invitationsRepository.getUserInvitations();
      emit(
        UserInvitationsActionSuccess(
          message: 'Zaproszenie zostało odrzucone',
          invitations: invitations,
        ),
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to reject user invitation',
      );
      emit(UserInvitationsActionFailure(e.toString()));
    }
  }

  void refreshInvitations() => loadInvitations();
}
