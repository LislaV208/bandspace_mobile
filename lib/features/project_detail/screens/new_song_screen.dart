import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_song/song_create_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/views/new_song/new_song_view.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class NewSongScreen extends StatelessWidget {
  final Project project;

  const NewSongScreen({super.key, required this.project});

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => NewSongCubit(
        projectId: project.id,
        projectsRepository: context.read<ProjectsRepository>(),
      ),
      child: NewSongScreen(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Nowy utwór',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Text(
            project.name,
          ),
        ),
      ),
      body: const NewSongView(),
    );
  }
}
