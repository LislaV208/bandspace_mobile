import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/theme/text_styles.dart';

/// Model opcji w arkuszu dolnym
class BottomSheetOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const BottomSheetOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Uniwersalny widget do tworzenia modal bottom sheetów z opcjami do wyboru
class OptionsBottomSheet extends StatelessWidget {
  final String? title;
  final List<BottomSheetOption> options;

  const OptionsBottomSheet({
    super.key,
    this.title,
    required this.options,
  });

  /// Statyczna metoda do wyświetlania arkusza dolnego
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<BottomSheetOption> options,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.surface,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => OptionsBottomSheet(
        title: title,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Uchwyt do przeciągania
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tytuł (opcjonalny)
          if (title != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title!,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 16),
          ],

          // Lista opcji
          ...options.map((option) => _buildOptionTile(option)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Buduje element opcji w arkuszu
  Widget _buildOptionTile(BottomSheetOption option) {
    return ListTile(
      leading: Icon(
        option.icon,
        color: option.isDestructive ? AppColors.error : AppColors.textPrimary,
        size: 24,
      ),
      title: Text(
        option.title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: option.isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: option.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// Rozszerzenie dla łatwiejszego tworzenia opcji
extension BottomSheetOptionExtension on List<BottomSheetOption> {
  /// Dodaje opcję anulowania na końcu listy
  List<BottomSheetOption> withCancel(BuildContext context) {
    return [
      ...this,
      BottomSheetOption(
        icon: Icons.close,
        title: 'Anuluj',
        onTap: () => Navigator.pop(context),
      ),
    ];
  }
}

/// Helper do szybkiego tworzenia popularnych opcji
class CommonBottomSheetOptions {
  /// Opcja edycji
  static BottomSheetOption edit({
    required VoidCallback onTap,
    String title = 'Edytuj',
    IconData icon = Icons.edit,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }

  /// Opcja usunięcia
  static BottomSheetOption delete({
    required VoidCallback onTap,
    String title = 'Usuń',
    IconData icon = Icons.delete,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      onTap: onTap,
      isDestructive: true,
    );
  }

  /// Opcja udostępnienia
  static BottomSheetOption share({
    required VoidCallback onTap,
    String title = 'Udostępnij',
    IconData icon = Icons.share,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }

  /// Opcja kopiowania
  static BottomSheetOption copy({
    required VoidCallback onTap,
    String title = 'Kopiuj',
    IconData icon = Icons.copy,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }

  /// Opcja anulowania
  static BottomSheetOption cancel({
    required VoidCallback onTap,
    String title = 'Anuluj',
    IconData icon = Icons.close,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }
}
