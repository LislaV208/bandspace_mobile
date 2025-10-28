import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bandspace_mobile/shared/theme/app_colors.dart';
import 'package:bandspace_mobile/shared/theme/text_styles.dart';

/// Model opcji w arkuszu dolnym
class BottomSheetOption {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? customColor;
  final Widget? badge;

  const BottomSheetOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.customColor,
    this.badge,
  });
}

/// Uniwersalny widget do tworzenia modal bottom sheetów z opcjami do wyboru
class OptionsBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<BottomSheetOption> options;
  final EdgeInsets? padding;

  /// Statyczna metoda do wyświetlania arkusza dolnego
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? subtitle,
    required List<BottomSheetOption> options,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) => OptionsBottomSheet(
        title: title,
        subtitle: subtitle,
        options: options,
        padding: padding,
      ),
    );
  }

  const OptionsBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.options,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Elegancki uchwyt do przeciągania z efektem świetlnym
              const SizedBox(height: 16),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Header z tytułem i podtytułem
              if (title != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        title!,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 20),
              ],

              // Lista opcji z animacjami
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return _buildFancyOptionTile(option, index);
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Buduje fancy element opcji z animacjami i efektami
  Widget _buildFancyOptionTile(BottomSheetOption option, int index) {
    final isDestructive = option.isDestructive;
    final color =
        option.customColor ??
        (isDestructive ? AppColors.error : AppColors.textPrimary);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        color: isDestructive
            ? AppColors.error.withOpacity(0.1)
            : AppColors.surface,
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withOpacity(0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            option.onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
            child: Row(
              children: [
                // Ikona z efektem świetlnym
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    // grad
                    // borderRadius: BorderRadius.circular(12),
                    // // border: Border.all(
                    // //   color: color.withOpacity(0.3),
                    // //   width: 1,
                    // // ),
                  ),
                  child: Icon(
                    option.icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Tekst
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (option.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          option.subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Badge (opcjonalny)
                if (option.badge != null) ...[
                  const SizedBox(width: 8),
                  option.badge!,
                ],

                // Strzałka (jeśli nie jest destrukcyjna)
                if (!isDestructive) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
    String? subtitle,
    IconData icon = Icons.edit,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  /// Opcja usunięcia
  static BottomSheetOption delete({
    required VoidCallback onTap,
    String title = 'Usuń',
    String? subtitle,
    IconData icon = Icons.delete,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      isDestructive: true,
    );
  }

  /// Opcja udostępnienia
  static BottomSheetOption share({
    required VoidCallback onTap,
    String title = 'Udostępnij',
    String? subtitle,
    IconData icon = Icons.share,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  /// Opcja kopiowania
  static BottomSheetOption copy({
    required VoidCallback onTap,
    String title = 'Kopiuj',
    String? subtitle,
    IconData icon = Icons.copy,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
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

  /// Opcja z niestandardowym kolorem
  static BottomSheetOption custom({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color color,
    Widget? badge,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      customColor: color,
      badge: badge,
    );
  }

  /// Opcja z badge'em
  static BottomSheetOption withBadge({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Widget badge,
  }) {
    return BottomSheetOption(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      badge: badge,
    );
  }
}

/// Helper do tworzenia popularnych badge'ów
class BottomSheetBadges {
  /// Czerwony badge z liczbą
  static Widget count(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Zielony badge "NOWE"
  static Widget newBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'NOWE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Niebieski badge "PRO"
  static Widget proBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
