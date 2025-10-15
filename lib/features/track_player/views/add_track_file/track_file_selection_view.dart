import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/add_track_file/add_track_file_cubit.dart';
import 'package:bandspace_mobile/shared/widgets/file_selection_widget.dart';

class TrackFileSelectionView extends StatelessWidget {
  final bool isSelectingFile;

  const TrackFileSelectionView({super.key, required this.isSelectingFile});

  @override
  Widget build(BuildContext context) {
    return FileSelectionWidget(
      isSelecting: isSelectingFile,
      onSelectFile: context.read<AddTrackFileCubit>().selectFile,
      onSkipFile: null,
    );
  }
}