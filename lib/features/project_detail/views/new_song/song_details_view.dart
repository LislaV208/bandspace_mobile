import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/song_create_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/audio_preview_player.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/bpm_control.dart';
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
  final _titleFocus = FocusNode();
  final _scrollController = ScrollController();
  late KeyboardVisibilityController _keyboardVisibilityController;
  int? _bpm;

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardVisibilityController.onChange.listen((isVisible) {
      log('Keyboard visibility changed: $isVisible');
      if (isVisible) {
        Future.delayed(const Duration(milliseconds: 500), () {
          log('Scrolling to bottom after keyboard shown');
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFileInfo(),
                const SizedBox(height: 24),
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildBpmSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Sticky bottom buttons
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: _buildButtons(),
        ),
      ],
    );
  }

  Widget _buildBpmSection() {
    if (_bpm == null) {
      return _buildAddBpmButton();
    } else {
      return _buildBpmControl();
    }
  }

  Widget _buildAddBpmButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tempo (opcjonalnie)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _bpm = 120;
              });
            },
            icon: Icon(
              LucideIcons.music,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(
              'Ustaw tempo (BPM)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBpmControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tempo (BPM)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _bpm = null;
                });
              },
              child: Text(
                'Usuń',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BpmControl(
          initialBpm: _bpm!,
          onBpmChanged: (newBpm) {
            setState(() {
              _bpm = newBpm;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    return BlocBuilder<NewSongCubit, NewSongState>(
      builder: (context, state) {
        if (state is NewSongFileSelected) {
          return AudioPreviewPlayer(
            audioFile: state.file,
            onRemoveFile: () {
              context.read<NewSongCubit>().goToInitialStep();
            },
          );
        }

        // Fallback - nie powinno się zdarzyć w tym kroku
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                      'Brak pliku audio',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wróć do poprzedniego kroku',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _titleController.text.trim().isNotEmpty
              ? context.read<NewSongCubit>().uploadFile(
                  CreateSongData(
                    title: _titleController.text.trim(),
                    bpm: _bpm,
                  ),
                )
              : null,
          maxLength: 100,
          buildCounter:
              (
                context, {
                required int currentLength,
                required bool isFocused,
                int? maxLength,
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
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                              bpm: _bpm,
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
