import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/theme/text_styles.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/edit_song/edit_song_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/edit_song/edit_song_state.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/models/update_song_data.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/widgets/bpm_control.dart';

/// Dialog do edycji utworu
class EditSongDialog extends StatefulWidget {
  final Song song;
  final int projectId;

  const EditSongDialog({
    super.key,
    required this.song,
    required this.projectId,
  });

  /// Statyczna metoda do wyświetlania dialogu edycji utworu
  static Future<Song?> show({
    required BuildContext context,
    required Song song,
    required int projectId,
  }) {
    return showDialog<Song>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => EditSongCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          projectId: projectId,
          songId: song.id,
        ),
        child: EditSongDialog(
          song: song,
          projectId: projectId,
        ),
      ),
    );
  }

  @override
  State<EditSongDialog> createState() => _EditSongDialogState();
}

class _EditSongDialogState extends State<EditSongDialog> {
  late TextEditingController _titleController;
  late FocusNode _titleFocusNode;
  int? _bpm;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _titleFocusNode = FocusNode();
    _bpm = widget.song.bpm;

    // Automatycznie zaznacz cały tekst po otwarciu dialogu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
      _titleController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _titleController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditSongCubit, EditSongState>(
      listener: (context, state) {
        if (state is EditSongSuccess) {
          Navigator.of(context).pop(state.song);
        }
      },
      builder: (context, state) {
        final isLoading = state is EditSongLoading || state is EditSongSuccess;

        return PopScope(
          canPop: !isLoading,
          child: AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Edytuj utwór',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nazwa utworu',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  enabled: !isLoading,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Wprowadź nazwę utworu',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: isLoading ? null : (_) => _saveChanges(),
                ),
                const SizedBox(height: 16),
                BpmControl(
                  initialBpm: _bpm,
                  onBpmChanged: (newBpm) {
                    setState(() {
                      _bpm = newBpm;
                    });
                  },
                  showRemoveButton: true,
                ),

                if (state is EditSongFailure) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.message,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              // Przycisk Anuluj
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Anuluj',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Przycisk Zapisz
              ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Zapisz',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveChanges() {
    final newTitle = _titleController.text.trim();

    final updateData = UpdateSongData(title: newTitle, bpm: _bpm);
    context.read<EditSongCubit>().updateSong(updateData);
  }
}
