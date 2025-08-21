import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/song_create_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_song/file_picker_view.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_song/song_details_view.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_song/song_uploading_view.dart';

class NewSongView extends StatefulWidget {
  const NewSongView({super.key});

  @override
  State<NewSongView> createState() => _NewSongViewState();
}

class _NewSongViewState extends State<NewSongView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewSongCubit, NewSongState>(
      listener: (context, state) {
        if (state is NewSongInitial) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // kolejność jest ważna
        } else if (state is NewSongUploading) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is NewSongFileSelected) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        if (state is NewSongUploadSuccess) {
          Navigator.pop(context);
        }

        if (state is NewSongUploadFailure) {
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
                  FilePickerView(
                    isPickingFile: state is NewSongSelectingFile,
                  ),
                  SongDetailsView(state: state),
                  SongUploadingView(state: state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(NewSongState state) {
    Color getStepColor(bool isActive) {
      if (isActive) return Theme.of(context).colorScheme.primary;
      return Theme.of(context).colorScheme.surfaceContainerHigh;
    }

    final isStepThree =
        state is NewSongUploading ||
        state is NewSongUploadFailure ||
        state is NewSongUploadSuccess;

    final isStepTwo = state is NewSongFileSelected || isStepThree;

    final isStepOne =
        (state is NewSongInitial ||
            state is NewSongSelectingFile ||
            state is NewSongSelectFileFailure) ||
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
