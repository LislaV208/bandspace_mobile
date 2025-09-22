import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/add_track_file/add_track_file_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/add_track_file/add_track_file_state.dart';
import 'package:bandspace_mobile/features/track_player/views/add_track_file/track_file_selection_view.dart';
import 'package:bandspace_mobile/features/track_player/views/add_track_file/track_file_preview_view.dart';
import 'package:bandspace_mobile/features/track_player/views/add_track_file/track_file_uploading_view.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

class AddTrackFileView extends StatefulWidget {
  final Function(Track updatedTrack) onUploadSuccess;
  final VoidCallback onBack;

  const AddTrackFileView({
    super.key,
    required this.onUploadSuccess,
    required this.onBack,
  });

  @override
  State<AddTrackFileView> createState() => _AddTrackFileViewState();
}

class _AddTrackFileViewState extends State<AddTrackFileView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddTrackFileCubit, AddTrackFileState>(
      listener: (context, state) {
        if (state is AddTrackFileInitial) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is AddTrackFileSelected) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is AddTrackFileUploading) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        if (state is AddTrackFileSuccess) {
          if (context.mounted) {
            widget.onUploadSuccess(state.updatedTrack);
          }
        }

        if (state is AddTrackFileFailure) {
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
                  TrackFileSelectionView(
                    isSelectingFile: state is AddTrackFileSelecting,
                  ),
                  TrackFilePreviewView(state: state),
                  TrackFileUploadingView(state: state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(AddTrackFileState state) {
    Color getStepColor(bool isActive) {
      if (isActive) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.surfaceContainerHigh;
    }

    final isStepThree =
        state is AddTrackFileUploading ||
        state is AddTrackFileSuccess ||
        state is AddTrackFileFailure;

    final isStepTwo = state is AddTrackFileSelected || isStepThree;

    final isStepOne =
        (state is AddTrackFileInitial || state is AddTrackFileSelecting) ||
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