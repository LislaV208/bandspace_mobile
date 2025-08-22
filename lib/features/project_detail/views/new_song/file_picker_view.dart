import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_song/song_create_cubit.dart';
import 'package:bandspace_mobile/shared/widgets/file_selection_widget.dart';

/// Step 1: Wybór pliku audio (dla nowego utworu)
class FilePickerView extends StatelessWidget {
  final bool isPickingFile;

  const FilePickerView({super.key, required this.isPickingFile});

  @override
  Widget build(BuildContext context) {
    return FileSelectionWidget(
      isSelecting: isPickingFile,
      onSelectFile: context.read<NewSongCubit>().selectFile,
      onSkipFile: context.read<NewSongCubit>().skipFileSelection, // ma przycisk pominięcia
    );
  }
}
