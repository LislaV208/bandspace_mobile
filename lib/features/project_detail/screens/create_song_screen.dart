import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/song_create_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/song_create_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_create/file_picker_step.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_create/song_details_step.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_create_error_dialog.dart';

/// Ekran tworzenia nowego utworu z 2-stepowym flow
class CreateSongScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  const CreateSongScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SongCreateCubit(),
      child: _CreateSongScreenContent(
        projectId: projectId,
        projectName: projectName,
      ),
    );
  }
}

/// Wewnętrzny widget z logiką ekranu
class _CreateSongScreenContent extends StatefulWidget {
  final int projectId;
  final String projectName;

  const _CreateSongScreenContent({
    required this.projectId,
    required this.projectName,
  });

  @override
  State<_CreateSongScreenContent> createState() =>
      _CreateSongScreenContentState();
}

class _CreateSongScreenContentState extends State<_CreateSongScreenContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongCreateCubit, SongCreateState>(
      listener: (context, state) {
        // Obsługa błędów - pokaż dialog z opcją powrotu lub ponowienia
        if (state.status == SongCreateStatus.error &&
            state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final shouldRetry = await SongCreateErrorDialog.show(
              context,
              errorMessage: state.errorMessage!,
              onRetry: () => context.read<SongCreateCubit>().createSong(),
            );

            // Jeśli użytkownik nie chce próbować ponownie, wróć do poprzedniego ekranu
            if (shouldRetry != true && context.mounted) {
              context.read<SongCreateCubit>().clearError();
              Navigator.pop(context);
            } else if (shouldRetry == true) {
              // Spróbuj ponownie - clearError i wywołaj createSong ponownie
              context.read<SongCreateCubit>().clearError();
              context.read<SongCreateCubit>().createSong();
            }
          });
        }

        // Obsługa sukcesu
        if (state.status == SongCreateStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utwór został utworzony pomyślnie!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        // Jeśli jest w trakcie tworzenia, pokaż ekran uploadu
        if (state.isCreating) {
          return _buildUploadingScreen(state.uploadProgress);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(state),
          body: Column(
            children: [
              _buildProgressIndicator(state),
              Expanded(
                child: PageView(
                  controller: context.read<SongCreateCubit>().pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: context.read<SongCreateCubit>().onPageChanged,
                  children: [
                    FilePickerStep(
                      onFileSelected: context
                          .read<SongCreateCubit>()
                          .onFileSelected,
                    ),
                    SongDetailsStep(
                      fileName: state.fileName ?? '',
                      initialTitle: state.songTitle,
                      initialDescription: state.songDescription,
                      onDetailsChanged: context
                          .read<SongCreateCubit>()
                          .onDetailsChanged,
                      onCancel: context
                          .read<SongCreateCubit>()
                          .goToPreviousStep,
                      onCreate: context.read<SongCreateCubit>().createSong,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SongCreateState state) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nowy utwór',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            state.currentStep == 0
                ? 'Wybierz plik audio'
                : 'Uzupełnij szczegóły',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(SongCreateState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: state.currentStep >= 1
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingScreen(double progress) {
    return BlocBuilder<SongCreateCubit, SongCreateState>(
      builder: (context, state) {
        final progressPercentage = (progress * 100).round();

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {},
          canPop: false,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.cloud_upload,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Przesyłanie utworu...',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.songTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$progressPercentage%',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
