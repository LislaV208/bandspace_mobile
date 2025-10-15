import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlbumArtWidget extends StatelessWidget {
  final double size;
  final double borderRadius;
  final double iconSize;

  const AlbumArtWidget({
    super.key,
    required this.size,
    this.borderRadius = 20,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Icon(
        LucideIcons.music,
        size: iconSize,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}
