import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/models/update_track_data.dart';
import 'package:bandspace_mobile/shared/widgets/bpm_control.dart';

/// Ekran do edycji ścieżki.
///
/// Pozwala użytkownikowi edytować tytuł ścieżki i BPM (tempo).
class EditTrackScreen extends StatefulWidget {
  const EditTrackScreen({
    super.key,
    required this.track,
    required this.cubit,
  });

  final Track track;
  final TrackDetailCubit cubit;

  /// Wyświetla ekran edycji ścieżki.
  ///
  /// Zwraca `true` jeśli użytkownik zapisał zmiany,
  /// `false` jeśli anulował lub zamknął ekran.
  static Future<bool?> push({
    required BuildContext context,
    required Track track,
    required TrackDetailCubit cubit,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrackScreen(
          track: track,
          cubit: cubit,
        ),
      ),
    );
  }

  @override
  State<EditTrackScreen> createState() => _EditTrackScreenState();
}

class _EditTrackScreenState extends State<EditTrackScreen> {
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

  Future<void> _saveChanges() async {
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
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edytuj utwór'),
              actions: [
                if (isUpdating)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: _saveChanges,
                    child: const Text('Zapisz'),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
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

                    BpmControl(
                      initialBpm: int.tryParse(_bpmController.text),
                      onBpmChanged: (value) {
                        _bpmController.text = value.toString();
                      },
                      showRemoveButton: true,
                    ),

                    // Pole BPM
                    // TextFormField(
                    //   controller: _bpmController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Tempo (BPM)',
                    //     suffixIcon: IconButton(
                    //       icon: const Icon(
                    //         Icons.clear,
                    //       ),
                    //       onPressed: () => _bpmController.clear(),
                    //     ),
                    //   ),
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.digitsOnly,
                    //   ],

                    //   validator: (value) {
                    //     if (value != null && value.isNotEmpty) {
                    //       final bpm = int.tryParse(value);
                    //       if (bpm == null) {
                    //         return 'Wprowadź prawidłową liczbę';
                    //       }
                    //       if (bpm <= 0) {
                    //         return 'Tempo musi być liczbą dodatnią';
                    //       }
                    //       if (bpm < 60) {
                    //         return 'Tempo nie może być mniejsze niż 60 BPM';
                    //       }
                    //       if (bpm > 300) {
                    //         return 'Tempo nie może przekraczać 300 BPM';
                    //       }
                    //     }
                    //     return null;
                    //   },
                    //   textInputAction: TextInputAction.done,
                    //   enabled: !isUpdating,
                    // ),

                    // Error message
                    if (state is TrackDetailUpdateFailure) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.3),
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
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
          ),
        );
      },
    );
  }
}
