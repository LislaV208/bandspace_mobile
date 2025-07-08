import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/widgets/member_avatar.dart';

import 'member_info.dart';

/// Element listy członka
class MemberListItem extends StatelessWidget {
  final User member;

  const MemberListItem({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName = member.name?.isNotEmpty == true
        ? member.name!
        : member.email;
    final subtitle = member.name?.isNotEmpty == true ? member.email : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.withAlpha(AppColors.border, 0.1)),
      ),
      child: Row(
        children: [
          UserAvatar(user: member, size: 40, borderWidth: 1),
          const Gap(12),
          Expanded(
            child: MemberInfo(displayName: displayName, subtitle: subtitle),
          ),
        ],
      ),
    );
  }
}
