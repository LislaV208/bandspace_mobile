import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/screens/create_song_screen.dart';
import 'package:bandspace_mobile/features/project_detail/views/project_details_view.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/manage_project_sheet.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Ekran szczegółów projektu z listą utworów
class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => ProjectDetailCubit(
        projectsRepository: context.read<ProjectsRepository>(),
        projectId: project.id,
        initialProject: project,
      ),
      child: ProjectDetailScreen(),
    );
  }

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocSelector<ProjectDetailCubit, ProjectDetailState, Project>(
          selector: (state) => state.project,
          builder: (context, project) {
            return Text(project.name);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              iconAlignment: IconAlignment.end,
              onPressed: () => ManageProjectSheet.show(context),
              label: const Text('Więcej'),
              icon: const Icon(LucideIcons.ellipsisVertical),
            ),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => ProjectSongsCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          projectId: context.read<ProjectDetailCubit>().state.project.id,
        ),
        child: const ProjectDetailsView(),
      ),
      // body: Column(
      //   children: [
      //     _buildSearchBar(),
      //     const SizedBox(height: 16),
      //     Expanded(
      //       child: BlocProvider(
      //         create: (_) => ProjectSongsCubit(
      //           projectsRepository: context.read<ProjectsRepository>(),
      //           projectId: context.read<ProjectDetailCubit>().state.project.id,
      //         ),
      //         child: const ProjectSongsList(),
      //       ),
      //     ),
      //   ],
      // ),
      floatingActionButton: _buildCreateSongFab(),
    );
  }

  /// Buduje pasek wyszukiwania
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: TextField(
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
      ),
    );
  }

  /// Buduje przycisk dodawania nowego utworu
  Widget _buildCreateSongFab() {
    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          onPressed: _showCreateSongSheet,
          icon: const Icon(LucideIcons.plus),
          label: const Text('Nowy utwór'),
        );
      },
    );
  }

  /// Pokazuje arkusz tworzenia nowego utworu
  void _showCreateSongSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateSongScreen(
          projectId: context.read<ProjectDetailCubit>().state.project.id,
          projectName: context.read<ProjectDetailCubit>().state.project.name,
        ),
      ),
    );

    // showModalBottomSheet(
    //   context: context,
    //   backgroundColor: Colors.transparent,
    //   isScrollControlled: true,
    //   builder: (_) => BlocProvider.value(
    //     value: context.read<ProjectDetailCubit>(),
    //     child: CreateSongBottomSheet(
    //       projectId: context.read<ProjectDetailCubit>().state.project!.id,
    //       onSongCreated: (songTitle) {
    //         // this.context.read<ProjectDetailCubit>().createSong(
    //         //   songTitle,
    //         // );
    //       },
    //     ),
    //   ),
    // );
  }
}
