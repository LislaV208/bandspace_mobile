import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'members_count_badge.dart';

/// Tytuł arkusza z licznikiem członków
class SheetTitle extends StatelessWidget {
  final int membersCount;

  const SheetTitle({
    super.key,
    required this.membersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            LucideIcons.users, 
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const Gap(12),
          Text(
            'Członkowie projektu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          MembersCountBadge(count: membersCount),
        ],
      ),
    );
  }
}