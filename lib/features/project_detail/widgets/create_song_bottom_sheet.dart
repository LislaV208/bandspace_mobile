import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

/// Arkusz tworzenia nowego utworu
class CreateSongBottomSheet extends StatefulWidget {
  final int projectId;
  final Function(String) onSongCreated;

  const CreateSongBottomSheet({super.key, required this.projectId, required this.onSongCreated});

  @override
  State<CreateSongBottomSheet> createState() => _CreateSongBottomSheetState();
}

class _CreateSongBottomSheetState extends State<CreateSongBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatyczne fokusowanie pola tytułu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 32),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  /// Buduje nagłówek arkusza
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.music, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nowy utwór',
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dodaj nowy utwór do projektu',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  /// Buduje pole tytułu utworu
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tytuł utworu',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Wprowadź tytuł utworu...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          textCapitalization: TextCapitalization.words,
          maxLength: 100,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            return Text(
              '$currentLength/${maxLength ?? 0}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            );
          },
        ),
      ],
    );
  }

  /// Buduje przycisk tworzenia utworu
  Widget _buildCreateButton() {
    return SizedBox(
      height: 56,
      child: ValueListenableBuilder(
        valueListenable: _titleController,
        builder: (context, value, child) {
          return ElevatedButton(
            onPressed: value.text.isEmpty ? null : _createSong,

            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.plus, size: 20),
                        const SizedBox(width: 8),
                        Text('Utwórz utwór', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
          );
        },
      ),
    );
  }

  /// Tworzy nowy utwór
  void _createSong() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Symulacja tworzenia utworu
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Wywołanie callback
    widget.onSongCreated(_titleController.text.trim());

    // Zamknięcie arkusza
    Navigator.pop(context);
  }
}
