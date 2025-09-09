import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/models/update_track_data.dart';

/// Dialog do edycji ścieżki.
///
/// Pozwala użytkownikowi edytować tytuł ścieżki i BPM (tempo).
class EditTrackDialog extends StatefulWidget {
  const EditTrackDialog({
    super.key,
    required this.track,
    required this.cubit,
  });

  final Track track;
  final TrackDetailCubit cubit;

  /// Wyświetla dialog edycji ścieżki.
  ///
  /// Zwraca `true` jeśli użytkownik zapisał zmiany,
  /// `false` jeśli anulował lub zamknął dialog.
  static Future<bool?> show({
    required BuildContext context,
    required Track track,
    required TrackDetailCubit cubit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditTrackDialog(
        track: track,
        cubit: cubit,
      ),
    );
  }

  @override
  State<EditTrackDialog> createState() => _EditTrackDialogState();
}

class _EditTrackDialogState extends State<EditTrackDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bpmController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track.title);
    _bpmController = TextEditingController(
      text: widget.track.mainVersion?.bpm?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bpmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackDetailCubit, TrackDetailState>(
      bloc: widget.cubit,
      listener: (context, state) {
        if (state is TrackDetailUpdateSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final isUpdating = state is TrackDetailUpdating;

        return PopScope(
          canPop: !isUpdating,
          child: AlertDialog(
            title: const Text('Edytuj utwór'),
            content: SizedBox(
              width: 600,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pole tytułu
                    TextFormField(
                      autofocus: true,
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tytuł utworu',
                        hintText: 'Wprowadź tytuł utworu',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tytuł utworu jest wymagany';
                        }

                        if (value.trim().length > 255) {
                          return 'Tytuł jest za długi (maksymalnie 255 znaków)';
                        }
                        
                        // Sprawdź niedozwolone znaki
                        if (value.contains(RegExp(r'[<>:"/\\|?*]'))) {
                          return 'Tytuł zawiera niedozwolone znaki';
                        }
                        
                        return null;
                      },
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      enabled: !isUpdating,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pole BPM
                    TextFormField(
                      controller: _bpmController,
                      decoration: const InputDecoration(
                        labelText: 'Tempo (BPM)',
                        hintText: 'Wprowadź tempo utworu (opcjonalne)',
                        suffixText: 'BPM',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final bpm = int.tryParse(value);
                          if (bpm == null) {
                            return 'Wprowadź prawidłową liczbę';
                          }
                          if (bpm <= 0) {
                            return 'Tempo musi być liczbą dodatnią';
                          }
                          if (bpm < 60) {
                            return 'Tempo nie może być mniejsze niż 60 BPM';
                          }
                          if (bpm > 300) {
                            return 'Tempo nie może przekraczać 300 BPM';
                          }
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      enabled: !isUpdating,
                    ),
                    
                    // Error message
                    if (state is TrackDetailUpdateFailure) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_rounded,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.message,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ),
                          ],
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
                          final title = _titleController.text.trim();
                          final bpmText = _bpmController.text.trim();
                          final bpm = bpmText.isNotEmpty ? int.tryParse(bpmText) : null;

                          final updateData = UpdateTrackData(
                            title: title != widget.track.title ? title : null,
                            bpm: bpm != widget.track.mainVersion?.bpm ? bpm : null,
                          );

                          await widget.cubit.updateTrack(updateData);
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