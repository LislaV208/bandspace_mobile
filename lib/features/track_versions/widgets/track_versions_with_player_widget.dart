import 'package:flutter/material.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_list_widget.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_player_widget.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionsWithPlayerWidget extends StatelessWidget {
  final TrackVersionsWithData state;
  final VoidCallback onRefresh;

  const TrackVersionsWithPlayerWidget({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: TrackVersionsListWidget(
              versions: state.versions,
              currentVersion: state.versions.isNotEmpty ? state.versions.first : null,
              onVersionSelected: (Version version) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Wybrano wersję: ${version.file?.filename ?? "Nieznany plik"}'),
                  ),
                );
              },
            ),
          ),
        ),

        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),

        TrackVersionsPlayerWidget(
          currentVersion: state.versions.isNotEmpty ? state.versions.first : null,
          isPlaying: false, // TODO: Connect to actual player state
          currentPosition: Duration.zero, // TODO: Connect to actual player state
          totalDuration: const Duration(minutes: 3, seconds: 24), // TODO: Connect to actual file duration
          onPlayPause: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funkcjonalność odtwarzania będzie wkrótce dostępna'),
              ),
            );
          },
          onPrevious: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Poprzednia wersja będzie wkrótce dostępna'),
              ),
            );
          },
          onNext: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Następna wersja będzie wkrótce dostępna'),
              ),
            );
          },
          onSeek: (value) {
            // TODO: Implement seek functionality
          },
        ),
      ],
    );
  }
}