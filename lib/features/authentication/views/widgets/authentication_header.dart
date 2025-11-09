import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class AuthenticationHeader extends StatelessWidget {
  const AuthenticationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.music),
          ),
          const SizedBox(width: 16),
          Text(
            "BandSpace",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
