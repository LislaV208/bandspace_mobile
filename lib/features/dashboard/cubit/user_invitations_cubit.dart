import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';

import 'package:bandspace_mobile/features/dashboard/repository/dashboard_repository.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';

import 'user_invitations_state.dart';

class UserInvitationsCubit extends Cubit<UserInvitationsState> {
  final DashboardRepository _dashboardRepository;

  UserInvitationsCubit({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const UserInvitationsState());

  /// Ładuje zaproszenia użytkownika
  Future<void> loadUserInvitations() async {
    emit(state.copyWith(status: UserInvitationsStatus.loading));

    try {
      final response = await _dashboardRepository.getUserInvitations();

      emit(state.copyWith(status: UserInvitationsStatus.loaded, invitations: response));
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
      final response = await _dashboardRepository.acceptInvitation(token);

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
      final response = await _dashboardRepository.rejectInvitation(token);

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
      final response = await _dashboardRepository.getInvitationDetails(token);
      return response;
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
