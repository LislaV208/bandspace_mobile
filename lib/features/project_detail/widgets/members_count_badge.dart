import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/theme/text_styles.dart';

/// Znaczek z liczbą członków
class MembersCountBadge extends StatelessWidget {
  final int count;

  const MembersCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: Text('$count', style: AppTextStyles.caption.copyWith(color: AppColors.onPrimary)),
    );
  }
}
