import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

/// Step 2: Uzupełnienie szczegółów utworu
class SongDetailsStep extends StatefulWidget {
  final String fileName;
  final String initialTitle;
  final String initialDescription;
  final Function(String title, String description) onDetailsChanged;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const SongDetailsStep({
    super.key,
    required this.fileName,
    required this.initialTitle,
    required this.initialDescription,
    required this.onDetailsChanged,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  State<SongDetailsStep> createState() => _SongDetailsStepState();
}

class _SongDetailsStepState extends State<SongDetailsStep> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );

    // Automatyczne fokusowanie pola tytułu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _titleFocus.requestFocus();
      // Zaznacz cały tekst dla łatwej edycji
      _titleController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _titleController.text.length,
      );
    });

    // Nasłuchiwanie zmian
    _titleController.addListener(_onDetailsChanged);
    _descriptionController.addListener(_onDetailsChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  void _onDetailsChanged() {
    widget.onDetailsChanged(_titleController.text, _descriptionController.text);
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
                Text(
                  widget.fileName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Plik audio',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
          'Nazwa utworu *',
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
              color: AppColors.textSecondary,
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
                    color: AppColors.textSecondary,
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
              color: AppColors.textSecondary,
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
          onSubmitted: (_) =>
              _titleController.text.trim().isNotEmpty ? _onCreate() : null,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
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
                  onPressed: isEnabled ? _onCreate : null,
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

  void _onCreate() {
    if (_titleController.text.trim().isEmpty) return;
    widget.onCreate();
  }
}
