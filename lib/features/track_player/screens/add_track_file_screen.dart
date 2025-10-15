import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/track_player/cubit/add_track_file/add_track_file_cubit.dart';
import 'package:bandspace_mobile/features/track_player/views/add_track_file/add_track_file_view.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class AddTrackFileScreen extends StatelessWidget {
  final int projectId;
  final int trackId;
  final String trackName;
  final Function(Track updatedTrack) onTrackUpdated;

  const AddTrackFileScreen({
    super.key,
    required this.projectId,
    required this.trackId,
    required this.trackName,
    required this.onTrackUpdated,
  });

  static Widget create(
    int projectId,
    int trackId,
    String trackName,
    Function(Track updatedTrack) onTrackUpdated,
  ) {
    return BlocProvider(
      create: (context) {
        return AddTrackFileCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          wakelockService: context.read(),
          projectId: projectId,
          trackId: trackId,
        );
      },
      child: AddTrackFileScreen(
        projectId: projectId,
        trackId: trackId,
        trackName: trackName,
        onTrackUpdated: onTrackUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Dodaj plik audio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Text(trackName),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: AddTrackFileView(
        onUploadSuccess: (Track updatedTrack) {
          Navigator.of(context).pop(updatedTrack);
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