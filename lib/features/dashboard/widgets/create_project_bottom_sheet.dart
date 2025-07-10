import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/create_project/create_project_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/create_project/create_project_state.dart';
import 'package:bandspace_mobile/features/project_detail/screens/project_detail_screen.dart';

/// Komponent formularza tworzenia nowego projektu wyświetlany jako bottom sheet.
class CreateProjectBottomSheet extends StatefulWidget {
  const CreateProjectBottomSheet({super.key});

  @override
  State<CreateProjectBottomSheet> createState() =>
      _CreateProjectBottomSheetState();
}

class _CreateProjectBottomSheetState extends State<CreateProjectBottomSheet> {
  /// Kontroler dla pola nazwy projektu
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateProjectCubit, CreateProjectState>(
      listener: (context, state) {
        if (state is CreateProjectSuccess) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProjectDetailScreen.create(state.project),
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            // Dodajemy padding na dole, aby uwzględnić klawiaturę
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildForm(context),
              if (state is CreateProjectFailure) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(state.message),
              ],
              const SizedBox(height: 32),
              _buildButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Buduje nagłówek formularza
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(LucideIcons.folderPlus, size: 24),
        const SizedBox(width: 12),
        Text(
          'Nowy Projekt',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Buduje komunikat błędu
  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Text(message, style: AppTextStyles.error),
    );
  }

  /// Buduje formularz tworzenia projektu
  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nazwa projektu',
            hintText: 'Wprowadź nazwę projektu',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  /// Buduje przyciski akcji
  Widget _buildButtons(BuildContext context, CreateProjectState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: state is CreateProjectLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder(
          valueListenable: nameController,
          builder: (context, nameEditingValue, child) {
            final name = nameEditingValue.text.trim();
            return ElevatedButton(
              onPressed: name.isEmpty || state is CreateProjectLoading
                  ? null
                  : () async {
                      context.read<CreateProjectCubit>().createProject(name);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: Colors.white,
              ),
              child: state is CreateProjectLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Tworzenie...'),
                      ],
                    )
                  : const Text('Utwórz'),
            );
          },
        ),
      ],
    );
  }
}
