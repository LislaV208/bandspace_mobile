import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/song_create_state.dart';

/// Cubit zarzdzajcy procesem tworzenia nowego utworu
class SongCreateCubit extends Cubit<SongCreateState> {
  final PageController pageController;

  SongCreateCubit({PageController? pageController})
    : pageController = pageController ?? PageController(),
      super(const SongCreateState());

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }

  /// ObsBuguje wyb�r pliku w pierwszym kroku
  void onFileSelected(File file) {
    final fileName = path.basename(file.path);
    final songTitle = path.basenameWithoutExtension(file.path);

    emit(
      state.copyWith(
        status: SongCreateStatus.fileSelected,
        selectedFile: Value(file),
        fileName: Value(fileName),
        songTitle: songTitle,
        errorMessage: Value(null),
      ),
    );

    goToNextStep();
  }

  /// Aktualizuje szczeg�By utworu w drugim kroku
  void onDetailsChanged(String title, String description) {
    emit(
      state.copyWith(
        status: SongCreateStatus.detailsUpdated,
        songTitle: title,
        songDescription: description,
        errorMessage: Value(null),
      ),
    );
  }

  /// Przechodzi do nastpnego kroku
  void goToNextStep() {
    if (state.canGoToNextStep && state.currentStep < 1) {
      final newStep = state.currentStep + 1;

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      emit(state.copyWith(currentStep: newStep));
    }
  }

  /// Wraca do poprzedniego kroku
  void goToPreviousStep() {
    if (state.currentStep > 0) {
      final newStep = state.currentStep - 1;

      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      emit(state.copyWith(currentStep: newStep));
    }
  }

  /// Aktualizuje aktualny krok (callback z PageView)
  void onPageChanged(int page) {
    emit(state.copyWith(currentStep: page));
  }

  /// Aktualizuje progress uploadu
  void updateUploadProgress(double progress) {
    emit(
      state.copyWith(
        status: SongCreateStatus.uploadProgress,
        uploadProgress: progress,
      ),
    );
  }

  /// Tworzy nowy utw�r
  Future<void> createSong() async {
    if (!state.canCreateSong) {
      emit(
        state.copyWith(
          errorMessage: Value(
            "Nie mo|na utworzy piosenki - sprawdz czy wszystkie pola s wypeBnione",
          ),
        ),
      );
      return;
    }

    try {
      emit(
        state.copyWith(
          status: SongCreateStatus.creating,
          errorMessage: Value(null),
          uploadProgress: 0.0,
        ),
      );

      // TODO: Tutaj bdzie integracja z repository
      // Symulacja uploadu dla cel�w demonstracyjnych
      for (int i = 0; i <= 100; i += 1) {
        await Future.delayed(const Duration(milliseconds: 100));
        updateUploadProgress(i / 100.0);
      }

      emit(
        state.copyWith(
          status: SongCreateStatus.success,
          uploadProgress: 1.0,
        ),
      );
    } catch (e) {
      String errorMessage = "BBd tworzenia utworu: ${e.toString()}";

      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      }

      emit(
        state.copyWith(
          status: SongCreateStatus.error,
          errorMessage: Value(errorMessage),
          uploadProgress: 0.0,
        ),
      );
    }
  }

  /// Resetuje stan do pocztkowego
  void reset() {
    emit(const SongCreateState());

    // Powr�t do pierwszego kroku
    if (pageController.hasClients) {
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Czy[ci bBdy
  void clearError() {
    emit(state.copyWith(errorMessage: Value(null)));
  }
}
