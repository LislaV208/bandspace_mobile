import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/theme/text_styles.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';

class SongUploadingView extends StatelessWidget {
  final NewSongState state;

  const SongUploadingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state is NewSongUploading
        ? (state as NewSongUploading).uploadProgress
        : state is NewSongUploadSuccess
        ? 1.0
        : 0.0;
    final progressPercentage = (progress * 100).round();

    return PopScope(
      canPop: false,
      child: Center(
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
                state is NewSongUploading
                    ? (state as NewSongUploading).songName
                    : 'Wybierz plik audio',
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
    );
  }
}
