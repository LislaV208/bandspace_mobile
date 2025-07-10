import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_state.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_files/song_files_list.dart';

class SongFilesView extends StatelessWidget {
  const SongFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongFilesCubit, SongFilesState>(
      builder: (context, state) {
        return switch (state) {
          SongFilesInitial() => const SizedBox(),
          SongFilesLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SongFilesLoadSuccess() => SongFilesList(
            files: state.files,
            selectedFile: state.selectedFile,
          ),
          SongFilesLoadFailure() => _buildErrorState(
            context,
            state.message,
          ),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.x,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Wystąpił błąd podczas ładowania plików',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
