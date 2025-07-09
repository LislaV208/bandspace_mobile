import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

/// Dialog do potwierdzenia usunięcia projektu.
///
/// Wyświetla ostrzeżenie o nieodwracalności akcji i pozwala
/// użytkownikowi potwierdzić lub anulować usunięcie.
class ProjectDeleteDialog extends StatelessWidget {
  const ProjectDeleteDialog({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProjectDetailCubit, ProjectDetailState, bool>(
      selector: (state) => state.status == ProjectDetailStatus.deleting,
      builder: (context, isDeleting) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {},
          canPop: !isDeleting,
          child: AlertDialog(
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
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
                onPressed: isDeleting
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        final deleted = await context
                            .read<ProjectDetailCubit>()
                            .deleteProject();

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.of(context).pop(deleted);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.5),
                  disabledForegroundColor: Theme.of(
                    context,
                  ).colorScheme.onError,
                ),
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Usuń'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Wyświetla dialog usunięcia projektu.
  ///
  /// Zwraca `true` jeśli użytkownik potwierdził usunięcie,
  /// `false` jeśli anulował lub zamknął dialog.
  static Future<bool?> show({
    required BuildContext context,
    required Project project,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProjectDetailCubit>(),
        child: ProjectDeleteDialog(
          project: project,
        ),
      ),
    );
  }
}
