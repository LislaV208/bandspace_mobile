import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_cubit.dart';

/// Główny Cubit aplikacji zarządzający koordynacją między różnymi Cubitami
class AppCubit extends Cubit<AppState> {
  final AuthCubit authCubit;
  final DashboardCubit dashboardCubit;

  AppCubit({
    required this.authCubit,
    required this.dashboardCubit,
  }) : super(AppState.initial) {
    // Słuchaj zmian w AuthCubit
    authCubit.stream.listen((authState) {
      _handleAuthStateChange(authState);
    });
  }

  /// Obsługuje zmiany stanu autentykacji
  void _handleAuthStateChange(AuthState authState) {
    if (authState.user != null && authState.isAuthStateInitialized) {
      // Użytkownik się zalogował - załaduj projekty
      emit(AppState.authenticated);
      dashboardCubit.loadProjects();
    } else if (authState.user == null && authState.isAuthStateInitialized) {
      // Użytkownik się wylogował - wyczyść stan dashboardu
      emit(AppState.unauthenticated);
      dashboardCubit.clearProjects();
    }
  }

}

/// Stan główny aplikacji
enum AppState {
  initial,
  authenticated,
  unauthenticated,
}