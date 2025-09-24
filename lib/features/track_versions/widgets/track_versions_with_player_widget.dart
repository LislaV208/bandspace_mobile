import 'package:flutter/material.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_list_widget.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_player_widget.dart';
import 'package:bandspace_mobile/shared/models/version.dart';
import 'package:bandspace_mobile/shared/models/audio_file.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

class TrackVersionsWithPlayerWidget extends StatelessWidget {
  final TrackVersionsWithData state;
  final VoidCallback onRefresh;
  final VoidCallback onAddVersion;

  const TrackVersionsWithPlayerWidget({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onAddVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: TrackVersionsListWidget(
              // versions: state.versions,
              // currentVersion: state.versions.isNotEmpty ? state.versions.first : null,
              versions: _generateMockVersions(),
              currentVersion: _generateMockVersions().first,
              onVersionSelected: (Version version) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Wybrano wersję: ${version.file?.filename ?? "Nieznany plik"}'),
                  ),
                );
              },
              onAddVersion: onAddVersion,
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

  List<Version> _generateMockVersions() {
    return List.generate(20, (index) {
      final versionNumber = 20 - index;
      final now = DateTime.now();
      final createdAt = now.subtract(Duration(days: index * 2, hours: index));

      return Version(
        id: index + 1,
        createdAt: createdAt,
        file: AudioFile(
          id: index + 1,
          filename: 'mock_version_$versionNumber.mp3',
          mimeType: 'audio/mpeg',
          size: 3500000 + (index * 200000),
          createdAt: createdAt,
          downloadUrl: 'https://mock.url/version_$versionNumber.mp3',
        ),
        uploader: User(
          id: (index % 3) + 1,
          name: ['Sebastian Lisiecki', 'Jan Kowalski', 'Anna Nowak'][index % 3],
          email: 'user${(index % 3) + 1}@example.com',
          lastLoginAt: createdAt,
          authProviders: ['google'],
        ),
      );
    });
  }
}