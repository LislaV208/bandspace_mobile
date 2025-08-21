import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/Delete_project/Delete_project_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/delete_project/delete_project_cubit.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Dialog do potwierdzenia usunięcia projektu.
///
/// Wyświetla ostrzeżenie o nieodwracalności akcji i pozwala
/// użytkownikowi potwierdzić lub anulować usunięcie.
class DeleteProjectDialog extends StatelessWidget {
  const DeleteProjectDialog({
    super.key,
    required this.project,
  });

  final Project project;

  /// Wyświetla dialog usunięcia projektu.
  static Future<bool?> show({
    required BuildContext context,
    required Project project,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => DeleteProjectCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          projectId: project.id,
        ),
        child: DeleteProjectDialog(
          project: project,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteProjectCubit, DeleteProjectState>(
      listener: (context, state) {
        if (state is DeleteProjectSuccess) {
          // Zamknij dialog
          Navigator.of(context).pop();
          // Powrót do poprzedniego ekranu
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isDeleting =
            state is DeleteProjectLoading || state is DeleteProjectSuccess;
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
                    : () {
                        context.read<DeleteProjectCubit>().deleteProject();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.5),
                  disabledForegroundColor: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer.withValues(alpha: 0.5),
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
}
