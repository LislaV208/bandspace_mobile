import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

/// Dialog potwierdzający usunięcie utworu z projektu
class ProjectSongDeleteDialog extends StatelessWidget {
  final Song song;

  const ProjectSongDeleteDialog({
    super.key,
    required this.song,
  });

  /// Statyczna metoda do wyświetlania dialogu
  static Future<bool?> show(
    BuildContext context, {
    required Song song,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ProjectSongDeleteDialog(
        song: song,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Usuń utwór',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Czy na pewno chcesz usunąć utwór "${song.title}"? Ta operacja jest nieodwracalna.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Anuluj',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            // TODO: Integracja z cubit - zostaw zakomentowane
            // context.read<ProjectDetailCubit>().deleteSong(song);
          },
          child: Text(
            'Usuń',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}