import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/utils/formatters.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionsListWidget extends StatelessWidget {
  final List<Version> versions;
  final Version? currentVersion;
  final PlayerUiStatus playerUiStatus;
  final ValueChanged<Version> onVersionSelected;
  final VoidCallback onAddVersion;

  const TrackVersionsListWidget({
    super.key,
    required this.versions,
    this.currentVersion,
    required this.playerUiStatus,
    required this.onVersionSelected,
    required this.onAddVersion,
  });

  @override
  Widget build(BuildContext context) {
    if (versions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.layers,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Brak wersji',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodaj pierwszą wersję tego utworu',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: versions.length,
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    final versionNumber = versions.length - index;
                    final isSelected = currentVersion?.id == version.id;
                    final isPlaying = isSelected && playerUiStatus == PlayerUiStatus.playing;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => onVersionSelected(version),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? LucideIcons.pause
                                      : LucideIcons.play,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Wersja $versionNumber',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    Row(
                                      children: [
                                        Text(
                                          Formatters.formatDateTime(
                                            version.createdAt,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),

                                        if (version.uploader != null) ...[
                                          Text(
                                            ' • ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          Text(
                                            version.uploader!.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        // Floating Add Button
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: onAddVersion,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              LucideIcons.plus,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
