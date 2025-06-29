import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Uchwyt do przeciągania arkusza
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}