import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

/// Dialog do edycji projektu.
///
/// Pozwala użytkownikowi edytować nazwę i opis projektu.
class ProjectEditDialog extends StatefulWidget {
  const ProjectEditDialog({
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
      builder: (_) => BlocProvider.value(
        value: context.read<ProjectDetailCubit>(),
        child: ProjectEditDialog(
          project: project,
        ),
      ),
    );
  }

  @override
  State<ProjectEditDialog> createState() => _ProjectEditDialogState();
}

class _ProjectEditDialogState extends State<ProjectEditDialog> {
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
    return BlocSelector<ProjectDetailCubit, ProjectDetailState, bool>(
      selector: (state) => state.status == ProjectDetailStatus.updating,
      builder: (context, isUpdating) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {},
          canPop: !isUpdating,
          child: AlertDialog(
            title: const Text('Edytuj projekt'),
            content: Form(
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
                      if (value.trim().length < 3) {
                        return 'Nazwa projektu musi mieć co najmniej 3 znaki';
                      }
                      if (value.trim().length > 100) {
                        return 'Nazwa projektu nie może przekraczać 100 znaków';
                      }
                      return null;
                    },
                    maxLength: 100,
                    textInputAction: TextInputAction.done,
                    enabled: !isUpdating,
                  ),
                ],
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
                          final updated = await context
                              .read<ProjectDetailCubit>()
                              .updateProject(
                                name: _nameController.text.trim(),
                              );

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.of(context).pop(updated);
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
