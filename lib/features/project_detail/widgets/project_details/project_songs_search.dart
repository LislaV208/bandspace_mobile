import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/core/theme/text_styles.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';

class ProjectSongsSearch extends StatefulWidget {
  const ProjectSongsSearch({super.key});

  @override
  State<ProjectSongsSearch> createState() => _ProjectSongsSearchState();
}

class _ProjectSongsSearchState extends State<ProjectSongsSearch> {
  late final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<ProjectSongsCubit>().filterSongs(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Szukaj utworów...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          LucideIcons.search,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
