import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/project/components/create_song_bottom_sheet.dart';
import 'package:bandspace_mobile/project/components/song_list_item.dart';
import 'package:bandspace_mobile/project/cubit/project_songs_cubit.dart';
import 'package:bandspace_mobile/project/cubit/project_songs_state.dart';
import 'package:bandspace_mobile/song_detail/song_detail_screen.dart';

/// Ekran szczegółów projektu z listą utworów
class ProjectScreen extends StatefulWidget {
  final Project project;

  const ProjectScreen({super.key, required this.project});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();

  /// Statyczna metoda do tworzenia ekranu z odpowiednim providerem
  static Widget create(Project project) {
    return BlocProvider(
      create:
          (context) => ProjectSongsCubit(projectRepository: ProjectRepository(), projectId: project.id)..loadSongs(),
      child: ProjectScreen(project: project),
    );
  }
}

class _ProjectScreenState extends State<ProjectScreen> {
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
    return BlocListener<ProjectSongsCubit, ProjectSongsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error));
          context.read<ProjectSongsCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(children: [_buildSearchBar(), const SizedBox(height: 16), _buildSongsList()]),
        floatingActionButton: _buildCreateSongFab(),
      ),
    );
  }

  /// Buduje app bar z tytułem projektu
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      title: Text(widget.project.name, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
      actions: [IconButton(icon: const Icon(LucideIcons.ellipsisVertical), onPressed: _showProjectOptions)],
    );
  }

  /// Buduje pasek wyszukiwania
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Szukaj utworów...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(LucideIcons.search, color: AppColors.textSecondary),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// Buduje listę utworów
  Widget _buildSongsList() {
    return Expanded(
      child: BlocBuilder<ProjectSongsCubit, ProjectSongsState>(
        builder: (context, state) {
          if (state.status == ProjectSongsStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.status == ProjectSongsStatus.error) {
            return _buildErrorState();
          }

          final cubit = context.read<ProjectSongsCubit>();
          final filteredSongs = cubit.getFilteredSongs(_searchQuery);

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
                child: SongListItem(song: song, onTap: () => _openSong(song), onDelete: () => _deleteSong(song)),
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
          Icon(hasSearchQuery ? LucideIcons.searchX : LucideIcons.music, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? 'Brak utworów pasujących do wyszukiwania' : 'Brak utworów w projekcie',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery ? 'Spróbuj zmienić frazę wyszukiwania' : 'Dodaj pierwszy utwór, aby rozpocząć pracę',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Buduje stan błędu
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.x, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Wystąpił błąd podczas ładowania utworów',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProjectSongsCubit>().loadSongs(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  /// Buduje przycisk dodawania nowego utworu
  Widget _buildCreateSongFab() {
    return BlocBuilder<ProjectSongsCubit, ProjectSongsState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          onPressed: state.isCreatingSong ? null : _showCreateSongSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon:
              state.isCreatingSong
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
            decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          _buildOptionTile(
            icon: LucideIcons.pencil,
            title: 'Edytuj projekt',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit project
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
              // TODO: Implement manage members
            },
          ),
          _buildOptionTile(
            icon: LucideIcons.trash2,
            title: 'Usuń projekt',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement delete project
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
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary),
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
      builder:
          (context) => BlocProvider.value(
            value: this.context.read<ProjectSongsCubit>(),
            child: CreateSongBottomSheet(
              projectId: widget.project.id,
              onSongCreated: (songTitle) {
                this.context.read<ProjectSongsCubit>().createSong(songTitle);
              },
            ),
          ),
    );
  }

  /// Otwiera szczegóły utworu
  void _openSong(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongDetailScreen.fromSong(
          projectId: widget.project.id,
          song: song,
        ),
      ),
    );
  }

  /// Usuwa utwór
  void _deleteSong(Song song) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Usuń utwór', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
            content: Text(
              'Czy na pewno chcesz usunąć utwór "${song.title}"? Ta operacja jest nieodwracalna.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Anuluj', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ProjectSongsCubit>().deleteSong(song);
                },
                child: Text('Usuń', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }
}
