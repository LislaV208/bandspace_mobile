import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

/// Dialog błędu podczas tworzenia utworu
class SongCreateErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const SongCreateErrorDialog({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  /// Statyczna metoda do wyświetlania dialogu
  static Future<bool?> show(
    BuildContext context, {
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SongCreateErrorDialog(
        errorMessage: errorMessage,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Błąd przesyłania',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.errorContainer,
                width: 1,
              ),
            ),
            child: Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Możesz spróbować ponownie lub wrócić do poprzedniego ekranu.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        // Przycisk "Wróć"
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // false = nie próbuj ponownie
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Wróć',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Przycisk "Spróbuj ponownie" - tylko jeśli jest callback
        if (onRetry != null) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true); // true = spróbuj ponownie
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Spróbuj ponownie',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
