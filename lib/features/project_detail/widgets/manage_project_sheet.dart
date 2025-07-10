import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/theme/text_styles.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/delete_project_dialog.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/edit_project_dialog.dart';

class ManageProjectSheet extends StatelessWidget {
  const ManageProjectSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProjectDetailCubit>(),
        child: const ManageProjectSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionTile(
            icon: LucideIcons.pencil,
            title: 'Edytuj projekt',
            onTap: () async {
              Navigator.pop(context);
              EditProjectDialog.show(
                context: context,
                project: context.read<ProjectDetailCubit>().state.project,
              );
            },
          ),
          _buildOptionTile(
            icon: LucideIcons.share,
            title: 'Udostępnij',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share project
            },
          ),
          _buildOptionTile(
            icon: LucideIcons.users,
            title: 'Członkowie',
            onTap: () {
              Navigator.pop(context);
              // _showProjectMembers();
            },
          ),
          _buildOptionTile(
            icon: LucideIcons.trash2,
            title: 'Usuń projekt',
            onTap: () async {
              Navigator.pop(context);
              DeleteProjectDialog.show(
                context: context,
                project: context.read<ProjectDetailCubit>().state.project,
              );
            },
            isDestructive: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Buduje element opcji w arkuszu
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
