import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/theme/app_colors.dart';
import 'package:bandspace_mobile/shared/theme/text_styles.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_cubit.dart';

class ProjectTracksSearch extends StatefulWidget {
  const ProjectTracksSearch({super.key});

  @override
  State<ProjectTracksSearch> createState() => _ProjectTracksSearchState();
}

class _ProjectTracksSearchState extends State<ProjectTracksSearch> {
  late final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<ProjectTracksCubit>().filterTracks(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _searchController,
      builder: (context, value, child) {
        return TextField(
          controller: _searchController,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Szukaj',
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
      },
    );
  }
}
