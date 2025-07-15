import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoadFailureView extends StatelessWidget {
  final String title;
  final String errorMessage;
  final VoidCallback? onRetry;

  const LoadFailureView({
    super.key,
    required this.title,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.x,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Spróbuj ponownie'),
              ),
          ],
        ),
      ),
    );
  }
}
