import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_cubit.dart';
import 'package:bandspace_mobile/shared/widgets/file_selection_widget.dart';

/// Step 1: Wybór pliku audio (dla dodania do utworu)
class FileSelectionView extends StatelessWidget {
  final bool isSelectingFile;

  const FileSelectionView({super.key, required this.isSelectingFile});

  @override
  Widget build(BuildContext context) {
    return FileSelectionWidget(
      isSelecting: isSelectingFile,
      onSelectFile: context.read<AddSongFileCubit>().selectFile,
      onSkipFile: null, // BRAK przycisku pominięcia
    );
  }
}