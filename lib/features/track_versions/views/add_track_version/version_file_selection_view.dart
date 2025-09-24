import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_cubit.dart';
import 'package:bandspace_mobile/shared/widgets/file_selection_widget.dart';

class VersionFileSelectionView extends StatelessWidget {
  final bool isSelectingFile;

  const VersionFileSelectionView({
    super.key,
    required this.isSelectingFile,
  });

  @override
  Widget build(BuildContext context) {
    return FileSelectionWidget(
      isSelecting: isSelectingFile,
      onSelectFile: context.read<AddTrackVersionCubit>().selectFile,
      onSkipFile: null, // Plik jest wymagany dla wersji
      title: 'Wybierz plik audio',
      subtitle: 'Dotknij aby wybrać nową wersję utworu',
      buttonText: 'Przeglądaj pliki',
      showSupportedFormats: true,
    );
  }
}