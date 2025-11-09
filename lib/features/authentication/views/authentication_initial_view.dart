import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class AuthenticationInitialView extends StatelessWidget {
  const AuthenticationInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.music,
            color: Theme.of(context).colorScheme.primary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'BandSpace',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 32),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
