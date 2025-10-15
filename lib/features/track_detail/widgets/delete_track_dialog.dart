import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

/// Dialog do potwierdzenia usunięcia ścieżki.
///
/// Wyświetla ostrzeżenie o nieodwracalności akcji i pozwala
/// użytkownikowi potwierdzić lub anulować usunięcie.
class DeleteTrackDialog extends StatelessWidget {
  const DeleteTrackDialog({
    super.key,
    required this.track,
    required this.cubit,
  });

  final Track track;
  final TrackDetailCubit cubit;

  /// Wyświetla dialog usunięcia ścieżki.
  ///
  /// Zwraca `true` jeśli użytkownik potwierdził usunięcie,
  /// `false` jeśli anulował lub zamknął dialog.
  static Future<bool?> show({
    required BuildContext context,
    required Track track,
    required TrackDetailCubit cubit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteTrackDialog(
        track: track,
        cubit: cubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackDetailCubit, TrackDetailState>(
      bloc: cubit,
      listener: (context, state) {
        if (state is TrackDetailDeleteSuccess) {
          // Zamknij dialog z wynikiem true
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final isDeleting = state is TrackDetailDeleting;
        
        return PopScope(
          canPop: !isDeleting,
          child: AlertDialog(
            title: const Text('Usuń utwór'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Czy na pewno chcesz usunąć utwór "${track.title}"?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ta akcja jest nieodwracalna. Utwór wraz ze wszystkimi wersjami zostanie trwale usunięty.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Error message
                if (state is TrackDetailDeleteFailure) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
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
            actions: [
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        await cubit.deleteTrack();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  disabledBackgroundColor: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.5),
                  disabledForegroundColor: Theme.of(context)
                      .colorScheme
                      .onErrorContainer
                      .withValues(alpha: 0.5),
                ),
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Usuń'),
              ),
            ],
          ),
        );
      },
    );
  }
}