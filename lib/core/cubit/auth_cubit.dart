import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/core/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(const AuthState());

  // Kontrolery tekstowe
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Węzły fokusa
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  @override
  Future<void> close() {
    // Zwolnienie zasobów
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
    final newView = state.view == AuthView.login ? AuthView.register : AuthView.login;

    // Wyczyść pole potwierdzenia hasła przy przejściu do logowania
    if (newView == AuthView.login) {
      confirmPasswordController.clear();
    }

    emit(
      state.copyWith(
        view: newView,
        errorMessage: null, // Wyczyść błędy przy zmianie widoku
        showConfirmPassword: newView == AuthView.register ? false : state.showConfirmPassword,
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

  /// Obsługuje proces logowania
  Future<void> login() async {
    // Sprawdź, czy pola nie są puste
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: "Wprowadź email i hasło."));
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Wywołanie metody logowania z repozytorium
      final session = await authRepository.login(email: emailController.text.trim(), password: passwordController.text);

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false));

      // Nawigacja do ekranu głównego po udanym logowaniu
      debugPrint("Zalogowano pomyślnie: ${session.user.email}");

      // Nawigacja do DashboardScreen zostanie obsłużona przez widok
      // Emitujemy stan z danymi użytkownika, co oznacza że jest zalogowany
      emit(state.copyWith(user: session.user));
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd logowania: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    }
  }

  /// Obsługuje proces rejestracji
  Future<void> register() async {
    // Sprawdź, czy pola nie są puste
    if (emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: "Wypełnij wszystkie pola."));
      return;
    }

    // Sprawdź, czy hasła są zgodne
    if (passwordController.text != confirmPasswordController.text) {
      emit(state.copyWith(errorMessage: "Hasła nie są zgodne."));
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: null));

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
      emit(state.copyWith(user: session.user));
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd rejestracji: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    }
  }

  /// Obsługuje logowanie przez Google
  Future<void> loginWithGoogle() async {
    // Tutaj dodaj rzeczywistą logikę logowania przez Google
    // np. Firebase Auth, Google Sign-In, itp.
    debugPrint("Próba logowania przez Google");

    // W rzeczywistej implementacji, tutaj byłaby logika logowania przez Google
  }

  /// Otwiera modal resetowania hasła
  void openResetPasswordModal(BuildContext context) {
    // Implementacja pozostaje w widoku, ponieważ wymaga kontekstu
    // i jest ściśle związana z UI
  }
}
