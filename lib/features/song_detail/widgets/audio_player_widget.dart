import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/models/song_file.dart';
import 'package:bandspace_mobile/shared/models/cached_audio_file.dart';
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
  
  // Offline-related properties
  final bool isPlayingOffline;
  final CacheStatus? cacheStatus;
  final DownloadProgress? downloadProgress;
  final VoidCallback? onDownload;
  final VoidCallback? onCancelDownload;
  final VoidCallback? onRemoveFromCache;
  
  // UI behavior settings
  final bool showManualControls;
  final bool showDetailedStatus;

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
    this.isPlayingOffline = false,
    this.cacheStatus,
    this.downloadProgress,
    this.onDownload,
    this.onCancelDownload,
    this.onRemoveFromCache,
    this.showManualControls = false, // Domyślnie ukryte dla smart caching
    this.showDetailedStatus = true,  // Pokazuj status cache
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      currentFile!.fileInfo.filename,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPlayingOffline) ...[
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.wifiOff,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const Gap(4),
                          Text(
                            'Offline',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  Text(
                    '${currentFile!.fileInfo.fileExtension.toUpperCase()} • ${currentFile!.formattedSize}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (showDetailedStatus && cacheStatus != null) ...[
                    Text(
                      ' • ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _buildCacheStatusIndicator(),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showManualControls && cacheStatus != null) ...[
          const Gap(12),
          _buildCacheActionButton(),
        ],
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

  // =============== OFFLINE INDICATORS ===============

  /// Buduje wskaźnik statusu cache
  Widget _buildCacheStatusIndicator() {
    if (cacheStatus == null) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (cacheStatus!) {
      case CacheStatus.cached:
        statusColor = Colors.green;
        statusIcon = LucideIcons.download;
        statusText = showDetailedStatus ? 'Cached' : 'C';
        break;
      case CacheStatus.downloading:
        if (!showDetailedStatus) {
          // Dyskretny indicator podczas smart caching
          statusColor = AppColors.primary.withAlpha(128);
          statusIcon = LucideIcons.loader;
          statusText = '...';
        } else {
          statusColor = AppColors.primary;
          statusIcon = LucideIcons.cloud;
          statusText = downloadProgress?.progressPercentage ?? 'Pobieranie...';
        }
        break;
      case CacheStatus.error:
        statusColor = AppColors.error;
        statusIcon = LucideIcons.info;
        statusText = showDetailedStatus ? 'Błąd' : '!';
        break;
      case CacheStatus.queued:
        statusColor = AppColors.textSecondary;
        statusIcon = LucideIcons.clock;
        statusText = showDetailedStatus ? 'W kolejce' : 'Q';
        break;
      case CacheStatus.notCached:
        // W smart caching mode nie pokazuj "Online" - to domyślny stan
        if (!showDetailedStatus) return const SizedBox.shrink();
        statusColor = AppColors.textSecondary;
        statusIcon = LucideIcons.cloud;
        statusText = 'Online';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          statusIcon,
          size: 12,
          color: statusColor,
        ),
        if (statusText.isNotEmpty) ...[
          const Gap(4),
          Text(
            statusText,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusColor,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  /// Buduje przycisk akcji cache
  Widget _buildCacheActionButton() {
    if (cacheStatus == null) return const SizedBox.shrink();

    switch (cacheStatus!) {
      case CacheStatus.notCached:
        return _buildActionButton(
          icon: LucideIcons.download,
          label: 'Pobierz',
          onTap: onDownload,
          color: AppColors.primary,
        );
      
      case CacheStatus.downloading:
        return _buildDownloadProgress();
      
      case CacheStatus.cached:
        return _buildActionButton(
          icon: LucideIcons.trash,
          label: 'Usuń',
          onTap: onRemoveFromCache,
          color: AppColors.error,
        );
      
      case CacheStatus.error:
        return _buildActionButton(
          icon: LucideIcons.rotateCcw,
          label: 'Ponów',
          onTap: onDownload,
          color: AppColors.primary,
        );
      
      case CacheStatus.queued:
        return _buildActionButton(
          icon: LucideIcons.x,
          label: 'Anuluj',
          onTap: onCancelDownload,
          color: AppColors.error,
        );
    }
  }

  /// Buduje przycisk akcji
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: onTap != null ? color : AppColors.textSecondary,
              ),
              const Gap(2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: onTap != null ? color : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Buduje wskaźnik postępu pobierania
  Widget _buildDownloadProgress() {
    final progress = downloadProgress;
    if (progress == null) {
      return _buildActionButton(
        icon: LucideIcons.loader,
        label: 'Pobieranie...',
        onTap: onCancelDownload,
        color: AppColors.primary,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCancelDownload,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: progress.progress,
                      strokeWidth: 2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceMedium,
                    ),
                    Center(
                      child: Icon(
                        LucideIcons.x,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(2),
              Text(
                progress.progressPercentage,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}