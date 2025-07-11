import 'package:flutter/material.dart';

import 'package:bandspace_mobile/features/project_detail/widgets/project_members/member_info.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/widgets/user_avatar.dart';

class MemberListItem extends StatelessWidget {
  final User member;

  const MemberListItem({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName = member.name?.isNotEmpty == true
        ? member.name!
        : member.email;
    final subtitle = member.name?.isNotEmpty == true ? member.email : null;

    return ListTile(
      leading: UserAvatar(user: member, size: 40),
      title: MemberInfo(displayName: displayName, subtitle: subtitle),
    );
  }
}
