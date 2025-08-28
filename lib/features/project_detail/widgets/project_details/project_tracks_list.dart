import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_track_list_item.dart';
// import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_tracks_search.dart'; // TODO

class ProjectTracksList extends StatelessWidget {
  final ProjectTracksReady state;

  const ProjectTracksList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tracks = state is ProjectTracksFiltered
        ? (state as ProjectTracksFiltered).filteredTracks
        : state.tracks;

    if (tracks.isEmpty) {
      return Center(child: Text('Brak ścieżek w projekcie.')); // Uproszczony widok
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 56.0),
      children: [
        // TODO: Dodać wyszukiwarkę i odświeżanie
        ...tracks.map(
          (track) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ProjectTrackListItem(
                tracksList: state.tracks,
                track: track,
              ),
            );
          },
        ),
      ],
    );
  }
}
