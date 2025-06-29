import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';

/// Widget odtwarzacza audio
class AudioPlayerWidget extends StatelessWidget {
  final SongFile? currentFile;
  final bool isPlaying;
  final bool isLoading;
  final Duration currentPosition;
  final Duration totalDuration;
  final VoidCallback? onPlayPause;
  final VoidCallback? onStop;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(Duration)? onSeek;

  const AudioPlayerWidget({
    super.key,
    this.currentFile,
    this.isPlaying = false,
    this.isLoading = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.onPlayPause,
    this.onStop,
    this.onNext,
    this.onPrevious,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    if (currentFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        children: [
          _buildFileInfo(),
          const Gap(16),
          _buildProgressBar(),
          const Gap(16),
          _buildControls(),
        ],
      ),
    );
  }

  /// Buduje informacje o aktualnie odtwarzanym pliku
  Widget _buildFileInfo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            LucideIcons.music,
            color: AppColors.onPrimary,
            size: 24,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentFile!.fileInfo.filename,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              Text(
                '${currentFile!.fileInfo.fileExtension.toUpperCase()} • ${currentFile!.formattedSize}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Buduje pasek postępu odtwarzania
  Widget _buildProgressBar() {
    final progress = totalDuration.inMilliseconds > 0
        ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        Builder(
          builder: (context) => SliderTheme(
              data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceMedium,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withAlpha(51),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: onSeek != null
                  ? (value) {
                      final newPosition = Duration(
                        milliseconds: (value * totalDuration.inMilliseconds).round(),
                      );
                      onSeek!(newPosition);
                    }
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(currentPosition),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(totalDuration),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Buduje kontrolki odtwarzacza
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(LucideIcons.skipBack),
          color: AppColors.textSecondary,
          iconSize: 24,
        ),
        const Gap(16),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: isLoading ? null : onPlayPause,
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Icon(
                        isPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: AppColors.onPrimary,
                        size: 28,
                      ),
              ),
            ),
          ),
        ),
        const Gap(16),
        IconButton(
          onPressed: onNext,
          icon: const Icon(LucideIcons.skipForward),
          color: AppColors.textSecondary,
          iconSize: 24,
        ),
      ],
    );
  }

  /// Formatuje czas trwania do formatu MM:SS
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}