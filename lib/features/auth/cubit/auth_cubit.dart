import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/auth/auth_event_service.dart';
import 'package:bandspace_mobile/core/storage/database_storage.dart';
import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final AuthEventService authEventService;
  final DatabaseStorage databaseStorage;

  // Subskrypcja do eventów auth
  StreamSubscription<AuthEvent>? _authEventSubscription;

  AuthCubit({
    required this.authRepository,
    required this.authEventService,
    required this.databaseStorage,
  }) : super(const AuthState()) {
    // Nasłuchuj na eventy związane z uwierzytelnianiem
    _authEventSubscription = authEventService.events.listen((event) {
      if (event == AuthEvent.tokenRefreshFailed) {
        _handleTokenRefreshFailed();
      }
    });

    // Inicjalizacja sesji przy tworzeniu cubita
    _initSession();
  }

  // Kontrolery tekstowe
  final TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'lislav.hms@gmail.com' : null,
  );
  final TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? '@rbuz0Hol' : null,
  );
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Węzły fokusa
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  @override
  Future<void> close() {
    // Zwolnienie zasobów streamów
    _authEventSubscription?.cancel();

    // Zwolnienie zasobów kontrolerów
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    return super.close();
  }

  /// Przełącza widok między logowaniem a rejestracją
  void toggleView() {
    final newView = state.view == AuthView.login
        ? AuthView.register
        : AuthView.login;

    // Wyczyść pole potwierdzenia hasła przy przejściu do logowania
    if (newView == AuthView.login) {
      confirmPasswordController.clear();
    }

    emit(
      state.copyWith(
        view: newView,
        errorMessage: Value(null), // Wyczyść błędy przy zmianie widoku
        showConfirmPassword: newView == AuthView.register
            ? false
            : state.showConfirmPassword,
      ),
    );
  }

  /// Przełącza widoczność hasła
  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  /// Przełącza widoczność potwierdzenia hasła
  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  /// Czyści komunikat błędu
  void clearError() {
    emit(state.copyWith(errorMessage: Value(null)));
  }

  /// Obsługuje proces logowania
  Future<void> login() async {
    // Sprawdź, czy pola nie są puste
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wprowadź email i hasło.")));
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: Value(null)));

    try {
      // Wywołanie metody logowania z repozytorium
      final session = await authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false));

      // Nawigacja do ekranu głównego po udanym logowaniu
      debugPrint("Zalogowano pomyślnie: ${session.user.email}");

      // Nawigacja do DashboardScreen zostanie obsłużona przez widok
      // Emitujemy stan z danymi użytkownika, co oznacza że jest zalogowany
      emit(
        state.copyWith(
          user: Value(session.user),
          loggedOutDueToTokenFailure:
              false, // Reset flagi przy udanym logowaniu
        ),
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Login failed',
        extras: {'email': emailController.text.trim()},
      );
      emit(state.copyWith(isLoading: false, errorMessage: Value(e.toString())));
    }
  }

  /// Obsługuje proces rejestracji
  Future<void> register() async {
    // Sprawdź, czy pola nie są puste
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wypełnij wszystkie pola.")));
      return;
    }

    // Sprawdź, czy hasła są zgodne
    if (passwordController.text != confirmPasswordController.text) {
      emit(state.copyWith(errorMessage: Value("Hasła nie są zgodne.")));
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: Value(null)));

    try {
      // Wywołanie metody rejestracji z repozytorium
      final session = await authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false));

      // Nawigacja do ekranu głównego po udanej rejestracji
      debugPrint("Zarejestrowano pomyślnie: ${session.user.email}");

      // Emitujemy stan z danymi użytkownika, co oznacza że jest zalogowany
      emit(
        state.copyWith(
          user: Value(session.user),
          loggedOutDueToTokenFailure:
              false, // Reset flagi przy udanym logowaniu
        ),
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Registration failed',
        extras: {'email': emailController.text.trim()},
      );
      emit(state.copyWith(isLoading: false, errorMessage: Value(e.toString())));
    }
  }

  /// Obsługuje logowanie przez Google
  Future<void> loginWithGoogle() async {
    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: Value(null)));

    try {
      // Wywołanie metody logowania przez Google z repozytorium
      final session = await authRepository.loginWithGoogle();

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false));

      // Emitujemy stan z danymi użytkownika, co oznacza że jest zalogowany
      emit(
        state.copyWith(
          user: Value(session.user),
          loggedOutDueToTokenFailure:
              false, // Reset flagi przy udanym logowaniu
        ),
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Google login failed',
      );
      emit(state.copyWith(isLoading: false, errorMessage: Value(e.toString())));
    }
  }

  /// Otwiera modal resetowania hasła
  void openResetPasswordModal(BuildContext context) {
    // Implementacja pozostaje w widoku, ponieważ wymaga kontekstu
    // i jest ściśle związana z UI
  }

  /// Inicjalizuje sesję użytkownika na podstawie danych z lokalnego magazynu.
  ///
  /// Sprawdza, czy użytkownik jest zalogowany i ustawia odpowiedni stan.
  Future<void> _initSession() async {
    try {
      // Sprawdź, czy użytkownik jest zalogowany
      final session = await authRepository.initSession();

      if (session != null) {
        // Użytkownik jest zalogowany, ustaw dane użytkownika w stanie
        emit(
          state.copyWith(
            user: Value(session.user),
            isAuthStateInitialized: true,
          ),
        );
        debugPrint("Załadowano sesję użytkownika: ${session.user.email}");
      } else {
        // Użytkownik nie jest zalogowany, ustaw flagę inicjalizacji
        emit(state.copyWith(isAuthStateInitialized: true));
        debugPrint("Brak zapisanej sesji użytkownika");
      }
    } catch (e) {
      // W przypadku błędu, ustaw flagę inicjalizacji, aby aplikacja mogła przejść dalej
      emit(state.copyWith(isAuthStateInitialized: true));
      debugPrint("Błąd podczas inicjalizacji sesji: ${e.toString()}");
    }
  }

  /// Obsługuje proces wylogowania
  Future<void> logout() async {
    await databaseStorage.clear();
    emit(state.copyWith(isLoading: true, errorMessage: Value(null)));

    String? errorMessage;

    try {
      await authRepository.logout();
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Logout failed',
      );
      errorMessage = e.toString();
    }

    emit(
      const AuthState().copyWith(
        errorMessage: Value(errorMessage),
        loggedOutDueToTokenFailure: false, // Reset flagi
      ),
    );
  }

  /// Aktualizuje dane użytkownika w stanie autoryzacji
  ///
  /// Używane po aktualizacji profilu użytkownika, aby zachować spójność danych
  void updateUserData(User updatedUser) {
    if (state.user != null) {
      emit(state.copyWith(user: Value(updatedUser)));
      debugPrint("Zaktualizowano dane użytkownika: ${updatedUser.email}");
    }
  }

  /// Czyści lokalny stan użytkownika bez wywoływania API logout
  ///
  /// Używane po usunięciu konta, gdy użytkownik już nie istnieje w systemie
  Future<void> clearUserSession() async {
    try {
      // Wyczyść token i lokalną sesję
      await authRepository.clearLocalSession();

      // Invaliduj wszystkie cache
      await databaseStorage.clear();

      // Wyczyść stan ładowania i dane użytkownika
      emit(
        state.copyWith(
          isLoading: false,
          user: Value(null),
          errorMessage: Value(null),
        ),
      );

      // Wyczyść pola formularza
      if (!kDebugMode) {
        emailController.clear();
        passwordController.clear();
      }
      confirmPasswordController.clear();

      debugPrint("Wyczyszczono sesję użytkownika po usunięciu konta");
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to clear user session after account deletion',
      );
      // Nawet jeśli wystąpi błąd, wyczyść lokalny stan UI
      emit(
        state.copyWith(
          isLoading: false,
          user: Value(null),
          errorMessage: Value(null),
        ),
      );
    }
  }

  /// Obsługuje niepowodzenie odświeżania tokenu - automatyczne wylogowanie użytkownika
  void _handleTokenRefreshFailed() {
    debugPrint("Token refresh failed - automatyczne wylogowanie użytkownika");

    // Ustaw flagę wylogowania z powodu błędu tokenu i wyczyść sesję
    emit(
      state.copyWith(
        loggedOutDueToTokenFailure: true,
        user: Value(null),
      ),
    );

    // Wyczyść lokalne dane (bez API call - token już jest nieprawidłowy)
    _clearLocalData();
  }

  /// Czyści lokalne dane bez wywołania API
  Future<void> _clearLocalData() async {
    try {
      // Wyczyść token i lokalną sesję
      await authRepository.clearLocalSession();

      // Invaliduj wszystkie cache
      await databaseStorage.clear();

      // Wyczyść pola formularza
      if (!kDebugMode) {
        emailController.clear();
        passwordController.clear();
      }
      confirmPasswordController.clear();

      debugPrint("Wyczyszczono lokalne dane po niepowodzeniu refresh tokenu");
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to clear local data after token refresh failure',
      );
    }
  }
}
