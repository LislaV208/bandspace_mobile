import 'package:flutter/material.dart';

import 'package:bandspace_mobile/shared/models/song.dart';

import 'animated_music_icon.dart';

class SongListItemWidget extends StatelessWidget {
  final Song song;
  final bool isCurrentSong;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongListItemWidget({
    super.key,
    required this.song,
    required this.isCurrentSong,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrentSong
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(100),
        highlightColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(100),
        // splashColor: Theme.of(
        //   context,
        // ).colorScheme.primary.withValues(alpha: 0.1),
        // highlightColor: Theme.of(
        //   context,
        // ).colorScheme.primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(12),
          //   border: Border.all(
          //     color: isCurrentSong
          //         ? Theme.of(context).colorScheme.primary
          //         : Colors.transparent,
          //     width: 2,
          //   ),
          // ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrentSong
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedMusicIcon(
                  isPlaying: isPlaying,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
