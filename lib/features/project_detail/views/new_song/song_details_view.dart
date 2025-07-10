import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/song_create_cubit.dart';
import 'package:bandspace_mobile/shared/models/song_create_data.dart';

/// Step 2: Uzupełnienie szczegółów utworu
class SongDetailsView extends StatefulWidget {
  final NewSongState state;

  const SongDetailsView({
    super.key,
    required this.state,
  });

  @override
  State<SongDetailsView> createState() => _SongDetailsViewState();
}

class _SongDetailsViewState extends State<SongDetailsView> {
  late final _titleController = TextEditingController(
    text: widget.state is NewSongFileSelected
        ? (widget.state as NewSongFileSelected).songInitialName
        : '',
  );
  final _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom -
              200, // Wysokość nagłówka i progress bar
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFileInfo(),
              const SizedBox(height: 24),
              _buildTitleField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const Spacer(),
              const SizedBox(height: 20),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    // Pobierz rozmiar pliku (w przyszłości)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.music,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<NewSongCubit, NewSongState>(
                  builder: (context, state) {
                    return Text(
                      state is NewSongFileSelected
                          ? state.file.path.split('/').last
                          : 'Wybierz plik audio',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Plik audio',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.check, size: 20, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nazwa utworu',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Wprowadź nazwę utworu...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _descriptionFocus.requestFocus(),
          maxLength: 100,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Text(
                  '$currentLength/${maxLength ?? 0}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opis (opcjonalnie)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          focusNode: _descriptionFocus,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Dodaj opis utworu...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _titleController.text.trim().isNotEmpty
              ? context.read<NewSongCubit>().uploadFile(
                  CreateSongData(
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                  ),
                )
              : null,
          maxLines: 3,
          maxLength: 500,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Text(
                  '$currentLength/${maxLength ?? 0}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                context.read<NewSongCubit>().goToInitialStep();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Wstecz',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ValueListenableBuilder(
              valueListenable: _titleController,
              builder: (context, value, child) {
                final isEnabled = value.text.trim().isNotEmpty;

                return ElevatedButton.icon(
                  onPressed: isEnabled
                      ? () {
                          context.read<NewSongCubit>().uploadFile(
                            CreateSongData(
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(LucideIcons.plus, size: 20),
                  label: Text(
                    'Utwórz utwór',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
