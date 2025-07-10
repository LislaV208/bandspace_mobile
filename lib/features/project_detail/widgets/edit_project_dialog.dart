import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/update_project/update_project_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/update_project/update_project_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Dialog do edycji projektu.
///
/// Pozwala użytkownikowi edytować nazwę i opis projektu.
class EditProjectDialog extends StatefulWidget {
  const EditProjectDialog({
    super.key,
    required this.project,
  });

  final Project project;

  /// Wyświetla dialog edycji projektu.
  ///
  /// Zwraca `true` jeśli użytkownik zapisał zmiany,
  /// `false` jeśli anulował lub zamknął dialog.
  static Future<bool?> show({
    required BuildContext context,
    required Project project,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => UpdateProjectCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          projectId: project.id,
        ),
        child: EditProjectDialog(
          project: project,
        ),
      ),
    );
  }

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateProjectCubit, UpdateProjectState>(
      listener: (context, state) {
        if (state is UpdateProjectSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final isUpdating =
            state is UpdateProjectLoading || state is UpdateProjectSuccess;

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {},
          canPop: !isUpdating,
          child: AlertDialog(
            title: const Text('Edytuj projekt'),
            content: SizedBox(
              width: 600,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nazwa projektu',
                        hintText: 'Wprowadź nazwę projektu',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nazwa projektu jest wymagana';
                        }

                        if (value.trim().length > 100) {
                          return 'Nazwa jest za długa';
                        }
                        return null;
                      },
                      maxLength: 100,
                      textInputAction: TextInputAction.done,
                      enabled: !isUpdating,
                    ),
                    if (state is UpdateProjectFailure) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUpdating
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: isUpdating
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await context
                              .read<UpdateProjectCubit>()
                              .updateProject(
                                _nameController.text.trim(),
                              );
                        }
                      },
                child: isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Zapisz'),
              ),
            ],
          ),
        );
      },
    );
  }
}
