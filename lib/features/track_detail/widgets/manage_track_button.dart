import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/widgets/options_bottom_sheet.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/features/track_detail/widgets/delete_track_dialog.dart';
import 'package:bandspace_mobile/features/track_detail/widgets/edit_track_dialog.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/screens/track_versions_screen.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class ManageTrackButton extends StatelessWidget {
  const ManageTrackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackDetailCubit, TrackDetailState>(
      builder: (context, state) {
        final cubit = context.read<TrackDetailCubit>();

        // Jeśli wystąpił błąd ładowania, pokaż ikonę błędu zamiast przycisku zarządzania
        if (state is TrackDetailError) {
          return IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  action: SnackBarAction(
                    label: 'Spróbuj ponownie',
                    onPressed: () {
                      cubit.refreshTrack();
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.error_outline),
            tooltip: 'Błąd ładowania danych utworu',
          );
        }

        // Pokaż przycisk tylko gdy mamy załadowaną ścieżkę
        if (state is! TrackDetailWithData) {
          return const SizedBox.shrink();
        }

        final track = state.track;
        final isOperationInProgress =
            state is TrackDetailUpdating || state is TrackDetailDeleting;

        return TextButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: isOperationInProgress
              ? null
              : () {
                  OptionsBottomSheet.show(
                    context: context,
                    title: 'Zarządzaj utworem',
                    options: [
                      BottomSheetOption(
                        icon: LucideIcons.pencil,
                        title: 'Edytuj utwór',
                        subtitle: 'Zmień tytuł i tempo',
                        onTap: () {
                          Navigator.pop(context);
                          _showEditDialog(context, track, cubit);
                        },
                      ),
                      BottomSheetOption(
                        icon: LucideIcons.layers,
                        title: 'Zarządzaj wersjami',
                        subtitle: 'Wyświetl i dodaj wersje utworu',
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToVersions(context, track);
                        },
                      ),
                      BottomSheetOption(
                        icon: LucideIcons.trash2,
                        title: 'Usuń utwór',
                        subtitle: 'Usuwa utwór wraz z wersjami',
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteDialog(context, track, cubit);
                        },
                        isDestructive: true,
                      ),
                    ],
                  );
                },
          label: Text(
            'Zarządzaj',
            style: TextStyle(
              color: isOperationInProgress
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: Icon(
            LucideIcons.settings2,
            size: 22,
            color: isOperationInProgress
                ? AppColors.textSecondary.withValues(alpha: 0.5)
                : AppColors.textSecondary,
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, track, TrackDetailCubit cubit) {
    EditTrackDialog.show(
      context: context,
      track: track,
      cubit: cubit,
    );
  }

  void _showDeleteDialog(BuildContext context, track, TrackDetailCubit cubit) {
    DeleteTrackDialog.show(
      context: context,
      track: track,
      cubit: cubit,
    );
  }

  void _navigateToVersions(BuildContext context, track) async {
    // Sprawdź czy mamy dostęp do projectId w kontekście
    final cubit = context.read<TrackDetailCubit>();
    if (cubit.projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak informacji o projekcie'),
        ),
      );
      return;
    }

    // Zatrzymaj odtwarzanie w TrackPlayerCubit przed przejściem do wersji
    try {
      await context.read<TrackPlayerCubit>().pausePlayback();
    } catch (e) {
      // TrackPlayerCubit może nie być dostępny w niektórych kontekstach - ignoruj błąd
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => TrackVersionsCubit(
            repository: context.read<ProjectsRepository>(),
          ),
          child: TrackVersionsScreen(
            track: track,
            projectId: cubit.projectId!,
          ),
        ),
      ),
    );
  }
}
