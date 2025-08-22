import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_state.dart';
import 'package:bandspace_mobile/features/song_detail/views/add_song_file/file_preview_view.dart';
import 'package:bandspace_mobile/features/song_detail/views/add_song_file/file_selection_view.dart';
import 'package:bandspace_mobile/features/song_detail/views/add_song_file/file_uploading_view.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class AddSongFileView extends StatefulWidget {
  final Function(Song updatedSong) onUploadSuccess;
  final VoidCallback onBack;

  const AddSongFileView({
    super.key,
    required this.onUploadSuccess,
    required this.onBack,
  });

  @override
  State<AddSongFileView> createState() => _AddSongFileViewState();
}

class _AddSongFileViewState extends State<AddSongFileView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSongFileCubit, AddSongFileState>(
      listener: (context, state) {
        // Navigation between steps
        if (state is AddSongFileInitial) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is AddSongFileSelected) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is AddSongFileUploading) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // Success handling
        if (state is AddSongFileSuccess) {
          // Załaduj nowy plik do odtwarzacza
          final audioUrl = state.updatedSong.file != null
              ? state.updatedSong.file!.fileKey ?? ''
              : '';

          if (audioUrl.isNotEmpty) {
            context.read<AudioPlayerCubit>().loadUrl(audioUrl);
          }

          // Od razu wracamy do ekranu utworu z zaktualizowanym utworem
          if (context.mounted) {
            widget.onUploadSuccess(state.updatedSong);
          }
        }

        // Error handling
        if (state is AddSongFileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildProgressIndicator(state),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  FileSelectionView(
                    isSelectingFile: state is AddSongFileSelecting,
                  ),
                  FilePreviewView(state: state),
                  FileUploadingView(state: state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(AddSongFileState state) {
    Color getStepColor(bool isActive) {
      if (isActive) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.surfaceContainerHigh;
    }

    final isStepThree =
        state is AddSongFileUploading ||
        state is AddSongFileSuccess ||
        state is AddSongFileFailure;

    final isStepTwo = state is AddSongFileSelected || isStepThree;

    final isStepOne =
        (state is AddSongFileInitial || state is AddSongFileSelecting) ||
        isStepTwo ||
        isStepThree;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: getStepColor(isStepOne),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: getStepColor(isStepTwo),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: getStepColor(isStepThree),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
