import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/widgets/options_bottom_sheet.dart';

class ManageSongsButton extends StatelessWidget {
  const ManageSongsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      iconAlignment: IconAlignment.end,
      onPressed: () {
        OptionsBottomSheet.show(
          context: context,
          title: 'Zarządzaj utworem',
          options: [
            BottomSheetOption(
              icon: LucideIcons.pencil,
              title: 'Edytuj utwór',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit song
              },
            ),
            BottomSheetOption(
              icon: LucideIcons.trash2,
              title: 'Usuń utwór',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete song
              },
              isDestructive: true,
            ),
          ],
        );
      },
      label: Text(
        'Zarządzaj',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: const Icon(
        LucideIcons.settings2,
        size: 22,
      ),
    );
  }
}
