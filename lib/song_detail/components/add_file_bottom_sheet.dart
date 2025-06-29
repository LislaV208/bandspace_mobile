import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/song_detail/cubit/song_detail_cubit.dart';
import 'package:bandspace_mobile/song_detail/cubit/song_detail_state.dart';

/// Bottom sheet do dodawania plików do utworu
class AddFileBottomSheet extends StatefulWidget {
  const AddFileBottomSheet({super.key});

  @override
  State<AddFileBottomSheet> createState() => _AddFileBottomSheetState();
}

class _AddFileBottomSheetState extends State<AddFileBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongDetailCubit, SongDetailState>(
      listener: (context, state) {
        if (state.uploadStatus == FileUploadStatus.success) {
          // Zresetuj stan uploadu
          context.read<SongDetailCubit>().resetUploadStatus();

          // Zamknij modal jeśli widget jest nadal mounted
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }

        if (state.uploadError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.uploadError!), backgroundColor: AppColors.error));
          context.read<SongDetailCubit>().clearUploadError();
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const Gap(24),
                  if (state.isPicking || state.isUploading) _buildUploadProgress(state) else _buildForm(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Buduje nagłówek bottom sheet
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(2)),
        ),
        const Gap(16),
        Row(
          children: [
            Icon(LucideIcons.upload, color: AppColors.textPrimary, size: 24),
            const Gap(12),
            Text('Dodaj plik audio', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  /// Buduje formularz do wprowadzania metadanych
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wybierz plik audio z urządzenia i opcjonalnie dodaj dodatkowe informacje.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const Gap(24),
        _buildDescriptionField(),
        const Gap(16),
        _buildDurationField(),
        const Gap(32),
        _buildActionButtons(),
      ],
    );
  }

  /// Buduje pole opisu
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opis pliku (opcjonalnie)',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        TextField(
          controller: _descriptionController,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'np. Demo nagranie, Wersja finalna...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  /// Buduje pole czasu trwania
  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Czas trwania w sekundach (opcjonalnie)',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        TextField(
          controller: _durationController,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'np. 180 (3 minuty)',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Buduje przyciski akcji
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              context.read<SongDetailCubit>().resetUploadStatus();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Anuluj', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ),
        ),
        const Gap(16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.upload, size: 18),
                const Gap(8),
                Text('Wybierz plik', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Buduje widok postępu uploadu
  Widget _buildUploadProgress(SongDetailState state) {
    return Column(
      children: [
        if (state.isPicking) ...[
          const CircularProgressIndicator(color: AppColors.primary),
          const Gap(16),
          Text('Wybieranie pliku...', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
        ] else if (state.isUploading) ...[
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: state.uploadProgress,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceMedium,
                  strokeWidth: 6,
                ),
              ),
              Text(
                '${(state.uploadProgress * 100).round()}%',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(16),
          Text('Przesyłanie pliku...', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(8),
          LinearProgressIndicator(
            value: state.uploadProgress,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceMedium,
          ),
        ],
        const Gap(24),
        TextButton(
          onPressed: () {
            context.read<SongDetailCubit>().resetUploadStatus();
            Navigator.pop(context);
          },
          child: Text('Anuluj', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  /// Obsługuje rozpoczęcie uploadu
  void _handleUpload() {
    final description = _descriptionController.text.trim();
    final durationText = _durationController.text.trim();

    int? duration;
    if (durationText.isNotEmpty) {
      duration = int.tryParse(durationText);
      if (duration == null || duration < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Czas trwania musi być liczbą większą lub równą 0'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    context.read<SongDetailCubit>().pickAndUploadFile(
      description: description.isEmpty ? null : description,
      duration: duration,
    );
  }
}
