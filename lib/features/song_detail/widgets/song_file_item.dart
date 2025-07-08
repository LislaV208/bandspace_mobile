import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/models/song_file.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';

/// Element listy plików utworu
class SongFileItem extends StatelessWidget {
  final SongFile songFile;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final bool isPlaying;
  final bool isLoading;
  final bool isSelected;

  const SongFileItem({
    super.key,
    required this.songFile,
    this.onPlay,
    this.onDownload,
    this.onDelete,
    this.isPlaying = false,
    this.isLoading = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildPlayButton(),
                const Gap(12),
                Expanded(child: _buildFileInfo()),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Buduje ikonę muzyki
  Widget _buildPlayButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceMedium,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        LucideIcons.music,
        color: AppColors.textPrimary,
        size: 20,
      ),
    );
  }

  /// Buduje informacje o pliku
  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          songFile.fileInfo.filename,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(4),
        Row(
          children: [
            _buildFileMetadata(
              icon: LucideIcons.clock,
              text: songFile.formattedDuration,
            ),
            const Gap(16),
            _buildFileMetadata(
              icon: LucideIcons.hardDrive,
              text: songFile.formattedSize,
            ),
            const Gap(16),
            _buildFileMetadata(
              icon: LucideIcons.fileAudio,
              text: songFile.fileInfo.fileExtension.toUpperCase(),
            ),
          ],
        ),
      ],
    );
  }

  /// Buduje element metadanych pliku
  Widget _buildFileMetadata({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors.textSecondary,
        ),
        const Gap(4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Buduje akcje dla pliku
  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDownload != null)
          IconButton(
            onPressed: onDownload,
            icon: const Icon(LucideIcons.download),
            color: AppColors.textSecondary,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(LucideIcons.trash2),
            color: AppColors.error,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
      ],
    );
  }
}