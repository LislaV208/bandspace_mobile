import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/widgets/options_bottom_sheet.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/delete_song_dialog.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/edit_song_dialog.dart';

class ManageSongsButton extends StatelessWidget {
  const ManageSongsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongDetailCubit, SongDetailState>(
      builder: (context, state) {
        return TextButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: () {
            _showManageSongOptions(context, state);
          },
          label: Text(
            'Zarządzaj',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(
            LucideIcons.settings2,
            size: 22,
          ),
        );
      },
    );
  }

  /// Pokazuje opcje zarządzania utworem
  void _showManageSongOptions(BuildContext context, SongDetailState state) {
    final cubit = context.read<SongDetailCubit>();

    OptionsBottomSheet.show(
      context: context,
      title: 'Zarządzaj utworem',
      options: [
        BottomSheetOption(
          icon: LucideIcons.pencil,
          title: 'Edytuj utwór',
          onTap: () async {
            final cubit = context.read<SongDetailCubit>();
            Navigator.pop(context);

            final editedSong = await EditSongDialog.show(
              context: context,
              song: state.currentSong,
              projectId: cubit.projectId,
            );

            if (editedSong is Song) {
              cubit.updateSong(editedSong);
            }
          },
        ),
        // BottomSheetOption(
        //   icon: LucideIcons.share,
        //   title: 'Udostępnij',
        //   onTap: () {
        //     Navigator.pop(context);
        //     // TODO: Implement share song
        //   },
        // ),
        BottomSheetOption(
          icon: LucideIcons.trash2,
          title: 'Usuń utwór',
          onTap: () async {
            Navigator.pop(context);

            DeleteSongDialog.show(
              context: context,
              song: state.currentSong,
              projectId: cubit.projectId,
            );
          },
          isDestructive: true,
        ),
      ],
    );
  }
}
