import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/song_detail.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';

/// Karta z informacjami o utworze
class SongInfoCard extends StatelessWidget {
  final SongDetail songDetail;
  final VoidCallback? onEdit;

  const SongInfoCard({
    super.key,
    required this.songDetail,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (_hasMetadata()) ...[
            const Gap(16),
            _buildMetadataRow(),
          ],
          if (songDetail.notes != null) ...[
            const Gap(16),
            _buildNotesSection(),
          ],
          if (songDetail.lyrics != null) ...[
            const Gap(16),
            _buildLyricsSection(),
          ],
        ],
      ),
    );
  }

  /// Buduje nagłówek karty z tytułem i przyciskiem edycji
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                songDetail.title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(4),
              Text(
                'Utworzono ${_formatDate(songDetail.createdAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(LucideIcons.pencil),
            color: AppColors.textSecondary,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  /// Buduje wiersz z metadanymi (BPM, tonacja, czas trwania)
  Widget _buildMetadataRow() {
    final metadata = <Widget>[];

    if (songDetail.bpm != null) {
      metadata.add(_buildMetadataItem(
        icon: LucideIcons.activity,
        label: 'BPM',
        value: songDetail.bpm.toString(),
      ));
    }

    if (songDetail.key != null) {
      metadata.add(_buildMetadataItem(
        icon: LucideIcons.music,
        label: 'Tonacja',
        value: songDetail.key!,
      ));
    }

    if (songDetail.duration != null) {
      metadata.add(_buildMetadataItem(
        icon: LucideIcons.clock,
        label: 'Czas',
        value: songDetail.formattedDuration,
      ));
    }

    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: metadata,
    );
  }

  /// Buduje pojedynczy element metadanych
  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const Gap(6),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Buduje sekcję z notatkami
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.fileText,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const Gap(6),
            Text(
              'Notatki',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            songDetail.notes!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Buduje sekcję z tekstem utworu
  Widget _buildLyricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.mic,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const Gap(6),
            Text(
              'Tekst utworu',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            songDetail.lyrics!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Sprawdza czy utwór ma jakiekolwiek metadane do wyświetlenia
  bool _hasMetadata() {
    return songDetail.bpm != null || 
           songDetail.key != null || 
           songDetail.duration != null;
  }

  /// Formatuje datę w czytelnym formacie
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'dzisiaj';
    } else if (difference.inDays == 1) {
      return 'wczoraj';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dni temu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'tydzień' : 'tygodnie'} temu';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'miesiąc' : 'miesięcy'} temu';
    }
  }
}