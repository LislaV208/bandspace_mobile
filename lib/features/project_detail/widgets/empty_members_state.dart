import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Stan pustej listy członków
class EmptyMembersState extends StatelessWidget {
  const EmptyMembersState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Icon(
            LucideIcons.userX,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(127),
          ),
          const Gap(16),
          Text(
            'Brak członków',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          Text(
            'Ten projekt nie ma jeszcze żadnych członków',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}