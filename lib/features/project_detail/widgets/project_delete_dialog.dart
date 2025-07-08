import 'package:flutter/material.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

/// Dialog do potwierdzenia usunięcia projektu.
///
/// Wyświetla ostrzeżenie o nieodwracalności akcji i pozwala
/// użytkownikowi potwierdzić lub anulować usunięcie.
class ProjectDeleteDialog extends StatelessWidget {
  const ProjectDeleteDialog({
    super.key,
    required this.project,
    this.onDelete,
  });

  final Project project;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Usuń projekt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Czy na pewno chcesz usunąć projekt "${project.name}"?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ta akcja jest nieodwracalna. Wszystkie dane projektu zostaną trwale usunięte.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onDelete?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Usuń'),
        ),
      ],
    );
  }

  /// Wyświetla dialog usunięcia projektu.
  ///
  /// Zwraca `true` jeśli użytkownik potwierdził usunięcie,
  /// `false` jeśli anulował lub zamknął dialog.
  static Future<bool?> show({
    required BuildContext context,
    required Project project,
    VoidCallback? onDelete,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ProjectDeleteDialog(
        project: project,
        onDelete: onDelete,
      ),
    );
  }
}