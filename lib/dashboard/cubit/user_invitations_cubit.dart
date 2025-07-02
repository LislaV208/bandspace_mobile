import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';

import '../../core/api/invitation_api.dart';
import '../../core/models/project_invitation.dart';

import 'user_invitations_state.dart';

class UserInvitationsCubit extends Cubit<UserInvitationsState> {
  final InvitationApi _invitationApi;

  UserInvitationsCubit({required InvitationApi invitationApi})
    : _invitationApi = invitationApi,
      super(const UserInvitationsState());

  /// Ładuje zaproszenia użytkownika
  Future<void> loadUserInvitations() async {
    emit(state.copyWith(status: UserInvitationsStatus.loading));

    try {
      final response = await _invitationApi.getUserInvitations();

      emit(state.copyWith(status: UserInvitationsStatus.loaded, invitations: response.invitations));
    } catch (e) {
      if (e is NetworkException) {
        return;
      }

      emit(state.copyWith(status: UserInvitationsStatus.error, errorMessage: e.toString()));
    }
  }

  /// Akceptuje zaproszenie
  Future<void> acceptInvitation(String token) async {
    emit(state.copyWith(isProcessingInvitation: true));

    try {
      final response = await _invitationApi.acceptInvitation(token: token);

      // Usuń zaproszenie z listy po akceptacji
      final updatedInvitations = state.invitations.where((invitation) => invitation.token != token).toList();

      emit(
        state.copyWith(
          isProcessingInvitation: false,
          invitations: updatedInvitations,
          successMessage: response.message,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessingInvitation: false, errorMessage: e.toString()));
    }
  }

  /// Odrzuca zaproszenie
  Future<void> rejectInvitation(String token) async {
    emit(state.copyWith(isProcessingInvitation: true));

    try {
      final response = await _invitationApi.rejectInvitation(token: token);

      // Usuń zaproszenie z listy po odrzuceniu
      final updatedInvitations = state.invitations.where((invitation) => invitation.token != token).toList();

      emit(
        state.copyWith(
          isProcessingInvitation: false,
          invitations: updatedInvitations,
          successMessage: response.message,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessingInvitation: false, errorMessage: e.toString()));
    }
  }

  /// Pobiera szczegóły zaproszenia
  Future<ProjectInvitation?> getInvitationDetails(String token) async {
    try {
      final response = await _invitationApi.getInvitationDetails(token: token);
      return response.invitation;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }

  /// Czyści komunikat o błędzie
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Czyści komunikat o sukcesie
  void clearSuccess() {
    emit(state.copyWith(successMessage: null));
  }
}
