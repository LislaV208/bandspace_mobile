import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/project/components/create_song_bottom_sheet.dart';
import 'package:bandspace_mobile/project/components/song_list_item.dart';

/// Ekran szczegółów projektu z listą utworów
class ProjectScreen extends StatefulWidget {
  final Project project;

  const ProjectScreen({super.key, required this.project});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  List<Song> _allSongs = [];

  @override
  void initState() {
    super.initState();
    _loadMockSongs();
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Ładuje przykładowe dane utworów
  void _loadMockSongs() {
    _allSongs = [
      Song(id: 1, title: 'velow park', createdAt: DateTime.now().subtract(const Duration(days: 60)), fileCount: 1),
      Song(
        id: 2,
        title: 'Velow - Czekając aż przestaniesz istnieć',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        fileCount: 1,
      ),
      Song(
        id: 3,
        title: 'Velow - Między wierszami',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        fileCount: 1,
      ),
      Song(
        id: 4,
        title: 'mimo zysków (new velow)',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        fileCount: 1,
      ),
      Song(
        id: 5,
        title: 'imagine być gitem',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        fileCount: 1,
      ),
      Song(id: 6, title: 'SKACZ', createdAt: DateTime.now().subtract(const Duration(days: 90)), fileCount: 1),
      Song(
        id: 7,
        title: 'TUTAJ TYLKO ZWROTKA, RESZTĘ JEBAĆ',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        fileCount: 1,
      ),
      Song(id: 8, title: 'Oh My Me (God)', createdAt: DateTime.now().subtract(const Duration(days: 90)), fileCount: 1),
    ];
    _filteredSongs = List.from(_allSongs);
  }

  /// Filtruje utwory na podstawie wyszukiwanej frazy
  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = List.from(_allSongs);
      } else {
        _filteredSongs = _allSongs.where((song) => song.title.toLowerCase().contains(query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          //  ProjectHeader(project: widget.project),
          _buildSongsList(),
        ],
      ),
      floatingActionButton: _buildCreateSongFab(),
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
      child:
          _filteredSongs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = _filteredSongs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SongListItem(song: song, onTap: () => _openSong(song), onDelete: () => _deleteSong(song)),
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

  /// Buduje przycisk dodawania nowego utworu
  Widget _buildCreateSongFab() {
    return FloatingActionButton.extended(
      onPressed: _showCreateSongSheet,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(LucideIcons.plus),
      label: const Text('Nowy utwór'),
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
          (context) => CreateSongBottomSheet(
            projectId: widget.project.id,
            onSongCreated: (songTitle) {
              // TODO: Implement song creation
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utworzono utwór: $songTitle')));
            },
          ),
    );
  }

  /// Otwiera szczegóły utworu
  void _openSong(Song song) {
    // TODO: Navigate to song detail screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Otwieranie utworu: ${song.title}')));
  }

  /// Usuwa utwór
  void _deleteSong(Song song) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Usuń utwór', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
            content: Text(
              'Czy na pewno chcesz usunąć utwór "${song.title}"? Ta operacja jest nieodwracalna.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Anuluj', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _allSongs.remove(song);
                    _filteredSongs.remove(song);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usunięto utwór: ${song.title}')));
                },
                child: Text('Usuń', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }
}
