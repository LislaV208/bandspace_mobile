import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_track/create_track_cubit.dart';
import 'package:bandspace_mobile/shared/widgets/file_selection_widget.dart';

/// Step 1: Wybór pliku audio (dla nowego utworu)
class TrackFilePickerView extends StatelessWidget {
  final bool isPickingFile;

  const TrackFilePickerView({super.key, required this.isPickingFile});

  @override
  Widget build(BuildContext context) {
    return FileSelectionWidget(
      isSelecting: isPickingFile,
      onSelectFile: context.read<CreateTrackCubit>().selectFile,
      onSkipFile: context.read<CreateTrackCubit>().skipFileSelection, // ma przycisk pominięcia
    );
  }
}