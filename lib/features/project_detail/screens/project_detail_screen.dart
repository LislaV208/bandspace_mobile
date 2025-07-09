import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_state.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_detail_repository.dart';
import 'package:bandspace_mobile/features/project_detail/screens/project_members_screen.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/create_song_bottom_sheet.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_delete_dialog.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_edit_dialog.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_list_item.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

/// Ekran szczegółów projektu z listą utworów
class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => ProjectDetailCubit(
        projectRepository: context.read<ProjectDetailRepository>(),
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildSongsList(),
        ],
      ),
      floatingActionButton: _buildCreateSongFab(),
    );
  }

  /// Buduje app bar z tytułem projektu
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: BlocSelector<ProjectDetailCubit, ProjectDetailState, Project?>(
        selector: (state) {
          return state.project;
        },
        builder: (context, project) {
          return Text(
            project?.name ?? 'Projekt',
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton.icon(
            iconAlignment: IconAlignment.end,
            onPressed: _showProjectOptions,
            label: const Text('Więcej'),
            icon: const Icon(LucideIcons.ellipsisVertical),
          ),
        ),
      ],
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

  /// Buduje listę utworów
  Widget _buildSongsList() {
    return Expanded(
      child: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
        builder: (context, state) {
          if (state.status == ProjectDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state.status == ProjectDetailStatus.error) {
            return _buildErrorState(state.errorMessage);
          }

          // final cubit = context.read<ProjectDetailCubit>();
          // final filteredSongs = cubit.getFilteredSongs(_searchQuery);
          final filteredSongs = [];

          if (filteredSongs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: filteredSongs.length,
            itemBuilder: (context, index) {
              final song = filteredSongs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SongListItem(
                  song: song,
                  onTap: () => _openSong(song),
                  onDelete: () => _deleteSong(song),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Buduje stan pustej listy
  Widget _buildEmptyState() {
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? LucideIcons.searchX : LucideIcons.music,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'Brak utworów pasujących do wyszukiwania'
                : 'Brak utworów w projekcie',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Spróbuj zmienić frazę wyszukiwania'
                : 'Dodaj pierwszy utwór, aby rozpocząć pracę',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Buduje stan błędu
  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.x, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Wystąpił błąd podczas ładowania utworów',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            // onPressed: () => context.read<ProjectDetailCubit>().loadSongs(),
            onPressed: () => {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  /// Buduje przycisk dodawania nowego utworu
  Widget _buildCreateSongFab() {
    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          onPressed: state.status == ProjectDetailStatus.creating
              ? null
              : _showCreateSongSheet,
          icon: state.status == ProjectDetailStatus.creating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Icon(LucideIcons.plus),
          label: const Text('Nowy utwór'),
        );
      },
    );
  }

  /// Pokazuje opcje projektu
  void _showProjectOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildProjectOptionsSheet(),
    );
  }

  /// Buduje arkusz opcji projektu
  Widget _buildProjectOptionsSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildOptionTile(
            icon: LucideIcons.pencil,
            title: 'Edytuj projekt',
            onTap: () async {
              Navigator.pop(context);
              await ProjectEditDialog.show(
                context: context,
                project: context.read<ProjectDetailCubit>().state.project!,
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
              _showProjectMembers();
            },
          ),
          _buildOptionTile(
            icon: LucideIcons.trash2,
            title: 'Usuń projekt',
            onTap: () async {
              Navigator.pop(context);
              final deleted = await ProjectDeleteDialog.show(
                context: context,
                project: context.read<ProjectDetailCubit>().state.project!,
              );

              if (!mounted) {
                return;
              }

              if (deleted == true) {
                Navigator.pop(context, true);
              }
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

  /// Pokazuje arkusz tworzenia nowego utworu
  void _showCreateSongSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: this.context.read<ProjectDetailCubit>(),
        child: CreateSongBottomSheet(
          projectId: context.read<ProjectDetailCubit>().state.project!.id,
          onSongCreated: (songTitle) {
            // this.context.read<ProjectDetailCubit>().createSong(
            //   songTitle,
            // );
          },
        ),
      ),
    );
  }

  /// Otwiera szczegóły utworu
  void _openSong(Song song) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SongDetailScreen.fromSong(
    //       projectId: widget.project.id,
    //       song: song,
    //     ),
    //   ),
    // );
  }

  /// Usuwa utwór
  void _deleteSong(Song song) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Usuń utwór',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Czy na pewno chcesz usunąć utwór "${song.title}"? Ta operacja jest nieodwracalna.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Anuluj',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // context.read<ProjectDetailCubit>().deleteSong(song);
            },
            child: Text(
              'Usuń',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Pokazuje ekran z członkami projektu
  void _showProjectMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectMembersScreen.create(
          context.read<ProjectDetailCubit>().state.project!,
        ),
      ),
    );
  }
}
