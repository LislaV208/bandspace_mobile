import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_track/create_track_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_track/create_track_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_track/track_file_picker_view.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_track/track_details_view.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_track/track_uploading_view.dart';

class NewTrackView extends StatefulWidget {
  const NewTrackView({super.key});

  @override
  State<NewTrackView> createState() => _NewTrackViewState();
}

class _NewTrackViewState extends State<NewTrackView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTrackCubit, CreateTrackState>(
      listener: (context, state) {
        if (state is CreateTrackInitial) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // kolejność jest ważna
        } else if (state is CreateTrackUploading) {
          if (state.hasFile) {
            // Jeśli jest plik → idź do step 3 (upload page)
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          // Jeśli brak pliku → zostań w step 2 z loaderem w przycisku
        } else if (state is CreateTrackFileSelected) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        if (state is CreateTrackUploadSuccess) {
          Navigator.pop(context);
        }

        if (state is CreateTrackUploadFailure) {
          Navigator.pop(context);
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
                  TrackFilePickerView(
                    isPickingFile: state is CreateTrackSelectingFile,
                  ),
                  TrackDetailsView(state: state),
                  TrackUploadingView(state: state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(CreateTrackState state) {
    Color getStepColor(bool isActive) {
      if (isActive) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.surfaceContainerHigh;
    }

    final isStepThree =
        state is CreateTrackUploading ||
        state is CreateTrackUploadFailure ||
        state is CreateTrackUploadSuccess;

    final isStepTwo = state is CreateTrackFileSelected || isStepThree;

    final isStepOne =
        (state is CreateTrackInitial ||
            state is CreateTrackSelectingFile ||
            state is CreateTrackSelectFileFailure) ||
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