import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_state.dart';
import 'package:bandspace_mobile/features/track_versions/views/add_track_version/version_file_selection_view.dart';
import 'package:bandspace_mobile/features/track_versions/views/add_track_version/version_metadata_view.dart';
import 'package:bandspace_mobile/features/track_versions/views/add_track_version/version_uploading_view.dart';
import 'package:bandspace_mobile/shared/models/version.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

class AddTrackVersionView extends StatefulWidget {
  final Track track;
  final int projectId;
  final Function(Version newVersion) onUploadSuccess;
  final VoidCallback onBack;

  const AddTrackVersionView({
    super.key,
    required this.track,
    required this.projectId,
    required this.onUploadSuccess,
    required this.onBack,
  });

  @override
  State<AddTrackVersionView> createState() => _AddTrackVersionViewState();
}

class _AddTrackVersionViewState extends State<AddTrackVersionView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddTrackVersionCubit(
        repository: context.read(),
        wakelockService: context.read(),
        projectId: widget.projectId,
        trackId: widget.track.id,
        track: widget.track,
      ),
      child: BlocConsumer<AddTrackVersionCubit, AddTrackVersionState>(
      listener: (context, state) {
        // Handle page navigation based on state
        if (state is AddTrackVersionInitial) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is AddTrackVersionFileSelected) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is AddTrackVersionReadyToUpload) {
          // Proceed directly to upload
          context.read<AddTrackVersionCubit>().uploadVersion();
        } else if (state is AddTrackVersionUploading || state is AddTrackVersionSuccess) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // Handle success callback
        if (state is AddTrackVersionSuccess) {
          if (context.mounted) {
            widget.onUploadSuccess(state.newVersion);
          }
        }

        // Handle errors
        if (state is AddTrackVersionFailure) {
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
                  VersionFileSelectionView(
                    isSelectingFile: state is AddTrackVersionSelecting,
                  ),
                  VersionMetadataView(state: state),
                  VersionUploadingView(state: state),
                ],
              ),
            ),
          ],
        );
      },
      )
    );
  }

  Widget _buildProgressIndicator(AddTrackVersionState state) {
    Color getStepColor(bool isActive) {
      if (isActive) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.surfaceContainerHigh;
    }

    final isStepThree =
        state is AddTrackVersionReadyToUpload ||
        state is AddTrackVersionUploading ||
        state is AddTrackVersionSuccess ||
        state is AddTrackVersionFailure;

    final isStepTwo = state is AddTrackVersionFileSelected || isStepThree;

    final isStepOne =
        (state is AddTrackVersionInitial || state is AddTrackVersionSelecting) ||
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