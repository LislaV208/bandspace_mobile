import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/theme/theme.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_state.dart';

class VersionUploadingView extends StatelessWidget {
  final AddTrackVersionState state;

  const VersionUploadingView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state is AddTrackVersionUploading) {
      return _buildUploadingState(context, state as AddTrackVersionUploading);
    } else if (state is AddTrackVersionSuccess) {
      return _buildSuccessState(context, state as AddTrackVersionSuccess);
    }

    return const Center(
      child: Text('Nieprawidłowy stan uploadu'),
    );
  }

  Widget _buildUploadingState(
    BuildContext context,
    AddTrackVersionUploading state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.upload,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Dodawanie wersji...',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.fileName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: AppColors.textHint.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(state.progress * 100).toInt()}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Przesyłanie...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    AddTrackVersionSuccess state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 60,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Wersja została dodana!',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Nowa wersja utworu jest już dostępna',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, state.newVersion);
              },
              icon: const Icon(LucideIcons.check, size: 20),
              label: Text(
                'Gotowe',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
