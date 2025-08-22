import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/views/add_song_file_view.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class AddSongFileScreen extends StatelessWidget {
  final Project project;
  final int projectId;
  final int songId;
  final Function(Song updatedSong) onSongUpdated;

  const AddSongFileScreen({
    super.key,
    required this.project,
    required this.projectId,
    required this.songId,
    required this.onSongUpdated,
  });

  static Widget create(Project project, int projectId, int songId, Function(Song updatedSong) onSongUpdated) {
    return BlocProvider(
      create: (context) {
        return AddSongFileCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          projectId: projectId,
          songId: songId,
        );
      },
      child: AddSongFileScreen(
        project: project,
        projectId: projectId,
        songId: songId,
        onSongUpdated: onSongUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj plik audio'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: AddSongFileView(
        onUploadSuccess: (Song updatedSong) {
          // Powrót do głównego ekranu z zaktualizowanym utworem
          Navigator.of(context).pop(updatedSong);
          
          // Pokaż komunikat o sukcesie
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plik został pomyślnie dodany'),
            ),
          );
        },
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}