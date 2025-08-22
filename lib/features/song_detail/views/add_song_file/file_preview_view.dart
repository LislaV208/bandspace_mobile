import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/audio_preview_player.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_state.dart';

/// Step 2: Podgląd wybranego pliku i potwierdzenie uploadu
class FilePreviewView extends StatelessWidget {
  final AddSongFileState state;

  const FilePreviewView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! AddSongFileSelected) {
      return const Center(child: Text('Nie wybrano pliku'));
    }

    final selectedState = state as AddSongFileSelected;

    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: AudioPreviewPlayer(audioFile: selectedState.file),
          ),
        ),

        // Sticky bottom buttons (identyczny wzór jak SongDetailsView)
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: _buildButtons(context),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AddSongFileCubit>().reset();
              },
              icon: const Icon(LucideIcons.arrowLeft),
              label: const Text('Wstecz'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AddSongFileCubit>().uploadFile();
              },
              icon: const Icon(LucideIcons.upload, size: 20),
              label: Text(
                'Prześlij plik',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
