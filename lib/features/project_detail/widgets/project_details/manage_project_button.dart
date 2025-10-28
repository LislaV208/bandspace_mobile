import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/theme/app_colors.dart';
import 'package:bandspace_mobile/shared/widgets/options_bottom_sheet.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/screens/project_members_screen.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/delete_project_dialog.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/edit_project_dialog.dart';

class ManageProjectButton extends StatelessWidget {
  const ManageProjectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      iconAlignment: IconAlignment.end,
      onPressed: () {
        final cubit = context.read<ProjectDetailCubit>();

        OptionsBottomSheet.show(
          context: context,
          title: 'Zarządzaj projektem',
          options: [
            BottomSheetOption(
              icon: LucideIcons.users,
              title: 'Członkowie',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProjectMembersScreen.create(cubit.state.project),
                  ),
                );
              },
            ),
            BottomSheetOption(
              icon: LucideIcons.pencil,
              title: 'Edytuj projekt',
              onTap: () async {
                Navigator.pop(context);
                EditProjectDialog.show(
                  context: context,
                  project: cubit.state.project,
                );
              },
            ),

            // BottomSheetOption(
            //   icon: LucideIcons.share,
            //   title: 'Udostępnij',
            //   onTap: () {
            //     Navigator.pop(context);
            //     // TODO: Implement share project
            //   },
            // ),
            BottomSheetOption(
              icon: LucideIcons.trash2,
              title: 'Usuń projekt',
              onTap: () async {
                Navigator.pop(context);
                DeleteProjectDialog.show(
                  context: context,
                  project: cubit.state.project,
                );
              },
              isDestructive: true,
            ),
          ],
        );
      },
      label: const Text(
        'Zarządzaj',
        style: TextStyle(
          color: AppColors.textSecondary,
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
