// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart';

// import 'package:bandspace_mobile/shared/models/project.dart';
// import 'invite_user_sheet.dart';
// import 'widgets/empty_members_state.dart';
// import 'widgets/member_list_item.dart';
// import 'widgets/sheet_handle.dart';
// import 'widgets/sheet_title.dart';

// /// Arkusz wyświetlający członków projektu
// class ProjectMembersSheet extends StatelessWidget {
//   final Project project;

//   const ProjectMembersSheet({super.key, required this.project});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildHeader(),
//             const Gap(16),
//             _buildInviteButton(context),
//             const Gap(16),
//             _buildMembersList(),
//             const Gap(20),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Buduje nagłówek arkusza
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         const SheetHandle(),
//         const Gap(20),
//         SheetTitle(membersCount: project.membersCount),
//       ],
//     );
//   }

//   /// Buduje listę członków
//   Widget _buildMembersList() {
//     if (project.members.isEmpty) {
//       return _buildEmptyState();
//     }

//     return ConstrainedBox(
//       constraints: const BoxConstraints(maxHeight: 400),
//       child: ListView.separated(
//         shrinkWrap: true,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: project.members.length,
//         separatorBuilder: (context, index) => const Gap(8),
//         itemBuilder: (context, index) {
//           final member = project.members[index];
//           return _buildMemberItem(member);
//         },
//       ),
//     );
//   }

//   /// Buduje element członka projektu
//   Widget _buildMemberItem(member) {
//     return MemberListItem(member: member);
//   }

//   /// Buduje stan pustej listy
//   Widget _buildEmptyState() {
//     return const EmptyMembersState();
//   }

//   /// Buduje przycisk zapraszania użytkowników
//   Widget _buildInviteButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           onPressed: () => _showInviteUserSheet(context),
//           icon: const Icon(LucideIcons.userPlus),
//           label: const Text('Zaproś użytkownika'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             foregroundColor: Theme.of(context).colorScheme.onPrimary,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Pokazuje arkusz zapraszania użytkowników
//   void _showInviteUserSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       useSafeArea: true,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: InviteUserSheet.create(project),
//       ),
//     );
//   }
// }
