import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/account/cubit/user_profile_state.dart';
import 'package:bandspace_mobile/features/account/repository/user_repository.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Cubit zarządzający stanem profilu użytkownika
class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository userRepository;
  final Function(User)? onUserUpdated;
  final VoidCallback? onAccountDeleted;

  UserProfileCubit({required this.userRepository, this.onUserUpdated, this.onAccountDeleted})
    : super(const UserProfileState());

  // Kontrolery tekstowe
  final TextEditingController nameController = TextEditingController();

  // Węzły fokusa
  final FocusNode nameFocus = FocusNode();

  @override
  Future<void> close() {
    // Zwolnienie zasobów
    nameController.dispose();
    nameFocus.dispose();
    return super.close();
  }

  /// Ładuje profil użytkownika
  Future<void> loadProfile() async {
    // Wyczyść poprzednie komunikaty
    emit(state.copyWith(errorMessage: Value(null), successMessage: Value(null)));

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true));

    try {
      // Wywołanie metody pobrania profilu z repozytorium
      final user = await userRepository.getProfile();

      // Wyczyść stan ładowania i ustaw dane użytkownika
      emit(state.copyWith(isLoading: false, user: Value(user)));

      // Wypełnij formularz danymi użytkownika
      nameController.text = user.name ?? '';
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd ładowania profilu: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(isLoading: false, errorMessage: Value(errorMessage)));
    }
  }

  /// Przełącza tryb edycji profilu
  void toggleEditing() {
    if (state.isEditing) {
      // Anuluj edycję - przywróć oryginalne wartości
      if (state.user != null) {
        nameController.text = state.user!.name ?? '';
      }
    }

    emit(state.copyWith(isEditing: !state.isEditing, errorMessage: Value(null), successMessage: Value(null)));
  }

  /// Aktualizuje profil użytkownika
  Future<void> updateProfile() async {
    // Wyczyść poprzednie komunikaty
    emit(state.copyWith(errorMessage: Value(null), successMessage: Value(null)));

    // Sprawdź, czy są jakieś zmiany
    final currentName = state.user?.name ?? '';
    final newName = nameController.text.trim();

    if (currentName == newName) {
      // Brak zmian - po prostu wyjdź z trybu edycji
      emit(state.copyWith(isEditing: false));
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true));

    try {
      // Wywołanie metody aktualizacji profilu z repozytorium
      final response = await userRepository.updateProfile(name: newName.isEmpty ? null : newName);

      // Wyczyść stan ładowania i ustaw zaktualizowane dane użytkownika
      emit(
        state.copyWith(
          isLoading: false,
          user: Value(response.user),
          isEditing: false,
          successMessage: Value(response.message),
        ),
      );

      // Aktualizuj dane użytkownika w AuthCubit
      if (onUserUpdated != null) {
        onUserUpdated!(response.user);
      }
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd aktualizacji profilu: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(isLoading: false, errorMessage: Value(errorMessage)));
    }
  }

  /// Usuwa konto użytkownika
  Future<void> deleteAccount() async {
    // Wyczyść poprzednie komunikaty
    emit(state.copyWith(errorMessage: Value(null), successMessage: Value(null)));

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true));

    try {
      // Wywołanie metody usunięcia konta z repozytorium
      final response = await userRepository.deleteProfile();

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false, successMessage: Value(response.message)));

      // Konto zostało usunięte - wywołaj callback do wylogowania
      if (onAccountDeleted != null) {
        onAccountDeleted!();
      }
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd usuwania konta: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(isLoading: false, errorMessage: Value(errorMessage)));
    }
  }

  /// Czyści komunikaty błędów i sukcesu
  void clearMessages() {
    emit(state.copyWith(errorMessage: Value(null), successMessage: Value(null)));
  }
}
