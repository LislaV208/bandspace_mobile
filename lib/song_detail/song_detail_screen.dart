import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/repositories/song_repository.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/song_detail/components/add_file_bottom_sheet.dart';
import 'package:bandspace_mobile/song_detail/components/audio_player_widget.dart';
import 'package:bandspace_mobile/song_detail/components/song_file_item.dart';
import 'package:bandspace_mobile/song_detail/cubit/audio_player_cubit.dart';
import 'package:bandspace_mobile/song_detail/cubit/audio_player_state.dart';
import 'package:bandspace_mobile/song_detail/cubit/song_detail_cubit.dart';
import 'package:bandspace_mobile/song_detail/cubit/song_detail_state.dart';

/// Ekran szczegółów utworu z listą plików i odtwarzaczem
class SongDetailScreen extends StatefulWidget {
  final int projectId;
  final int songId;
  final String songTitle;

  const SongDetailScreen({super.key, required this.projectId, required this.songId, required this.songTitle});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();

  /// Statyczna metoda do tworzenia ekranu z odpowiednim providerem
  static Widget create({required int projectId, required int songId, required String songTitle}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  SongDetailCubit(songRepository: SongRepository(), projectId: projectId, songId: songId)
                    ..loadSongDetail(),
        ),
        BlocProvider(create: (context) => AudioPlayerCubit(songRepository: SongRepository(), songId: songId)),
      ],
      child: SongDetailScreen(projectId: projectId, songId: songId, songTitle: songTitle),
    );
  }

  /// Factory konstruktor z Song obiektem
  static Widget fromSong({required int projectId, required Song song}) {
    return create(projectId: projectId, songId: song.id, songTitle: song.title);
  }
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SongDetailCubit, SongDetailState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error));
              context.read<SongDetailCubit>().clearError();
            }

            if (state.fileOperationError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.fileOperationError!), backgroundColor: AppColors.error));
              context.read<SongDetailCubit>().clearFileOperationError();
            }

            if (state.uploadError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.uploadError!), backgroundColor: AppColors.error));
              context.read<SongDetailCubit>().clearUploadError();
            }

            // Aktualizuj playlistę w audio playerze gdy pliki się zmienią
            if (state.hasAudioFiles) {
              context.read<AudioPlayerCubit>().setPlaylist(state.files);
              // Auto-wybierz pierwszy plik (bez odtwarzania)
              final playerState = context.read<AudioPlayerCubit>().state;
              if (playerState.currentFile == null && state.files.isNotEmpty) {
                context.read<AudioPlayerCubit>().selectFile(state.files.first);
              }
            }
          },
        ),
        BlocListener<AudioPlayerCubit, AudioPlayerState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error));
              context.read<AudioPlayerCubit>().clearError();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocBuilder<SongDetailCubit, SongDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (state.hasError) {
              return _buildErrorState();
            }

            if (state.songDetail == null) {
              return const SizedBox.shrink();
            }

            if (!state.hasAudioFiles) {
              return _buildEmptyFilesState();
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFilesList(state.files),
                        // Add bottom padding for player
                        const Gap(16),
                      ],
                    ),
                  ),
                ),
                // Audio player at the bottom
                BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                  builder: (context, playerState) {
                    return AudioPlayerWidget(
                      currentFile: playerState.currentFile,
                      isPlaying: playerState.isPlaying,
                      isLoading: playerState.isLoading,
                      currentPosition: playerState.currentPosition,
                      totalDuration: playerState.totalDuration,
                      onPlayPause: () => context.read<AudioPlayerCubit>().playPause(),
                      onStop: () => context.read<AudioPlayerCubit>().stop(),
                      onNext: () => context.read<AudioPlayerCubit>().next(),
                      onPrevious: () => context.read<AudioPlayerCubit>().previous(),
                      onSeek: (position) => context.read<AudioPlayerCubit>().seek(position),
                      // Offline-related parameters
                      isPlayingOffline: playerState.isPlayingOffline,
                      cacheStatus: playerState.currentFileCacheStatus,
                      downloadProgress: playerState.currentFileDownloadProgress,
                      onDownload: playerState.currentFile != null 
                          ? () => context.read<AudioPlayerCubit>().downloadForOffline(playerState.currentFile!)
                          : null,
                      onCancelDownload: playerState.currentFile != null 
                          ? () => context.read<AudioPlayerCubit>().cancelDownload(playerState.currentFile!.fileId)
                          : null,
                      onRemoveFromCache: playerState.currentFile != null 
                          ? () => context.read<AudioPlayerCubit>().removeFromCache(playerState.currentFile!)
                          : null,
                      // Smart caching mode - transparentne cache'owanie
                      showManualControls: false, // Ukryj manual download controls
                      showDetailedStatus: false, // Dyskretne status indicators
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Buduje app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      title: Text(widget.songTitle, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
      actions: [IconButton(icon: const Icon(LucideIcons.ellipsisVertical), onPressed: _showSongOptions)],
    );
  }

  /// Buduje stan błędu
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.x, size: 64, color: AppColors.error),
          const Gap(16),
          Text(
            'Wystąpił błąd podczas ładowania utworu',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () => context.read<SongDetailCubit>().loadSongDetail(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  /// Buduje listę plików
  Widget _buildFilesList(List<SongFile> files) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.files, size: 20, color: AppColors.textSecondary),
              const Gap(8),
              Text(
                'Pliki audio (${files.length})',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              BlocBuilder<SongDetailCubit, SongDetailState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: state.isUploading || state.isPicking ? null : _showAddFileDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              state.isUploading || state.isPicking
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                                  )
                                  : const Icon(LucideIcons.plus, size: 16, color: AppColors.onPrimary),
                              const Gap(6),
                              Text(
                                state.isUploading
                                    ? 'Dodawanie...'
                                    : state.isPicking
                                    ? 'Wybieranie...'
                                    : 'Dodaj',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Gap(16),
          ...files.map(
            (file) => BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
              builder: (context, playerState) {
                return SongFileItem(
                  songFile: file,
                  isSelected: playerState.currentFile?.id == file.id,
                  onPlay: () => context.read<AudioPlayerCubit>().selectFile(file),
                  onDownload: () => _downloadFile(file),
                  onDelete: () => _deleteFile(file),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Buduje stan pustej listy plików
  Widget _buildEmptyFilesState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileAudio, size: 64, color: AppColors.textSecondary),
            const Gap(16),
            Text('Brak plików audio', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
            const Gap(8),
            Text(
              'Dodaj pierwszy plik audio, aby móc odtwarzać utwór',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            BlocBuilder<SongDetailCubit, SongDetailState>(
              builder: (context, state) {
                return ElevatedButton.icon(
                  onPressed: state.isUploading || state.isPicking ? null : _showAddFileDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon:
                      state.isUploading || state.isPicking
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                          : const Icon(LucideIcons.plus),
                  label: Text(
                    state.isUploading
                        ? 'Przesyłanie...'
                        : state.isPicking
                        ? 'Wybieranie...'
                        : 'Dodaj plik',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Pobiera plik
  void _downloadFile(SongFile file) {
    // TODO: Implementacja pobierania pliku
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pobieranie: ${file.fileInfo.filename}')));
  }

  /// Usuwa plik
  void _deleteFile(SongFile file) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Usuń plik', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
            content: Text(
              'Czy na pewno chcesz usunąć plik "${file.fileInfo.filename}"? Ta operacja jest nieodwracalna.',
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
                  context.read<SongDetailCubit>().deleteFile(file.fileId);

                  // Zatrzymaj odtwarzanie jeśli usuwany plik jest aktualnie odtwarzany
                  final playerState = context.read<AudioPlayerCubit>().state;
                  if (playerState.currentFile?.id == file.id) {
                    context.read<AudioPlayerCubit>().stop();
                  }
                },
                child: Text('Usuń', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  /// Pokazuje opcje utworu
  void _showSongOptions() {
    // TODO: Implementacja opcji utworu
  }

  /// Pokazuje bottom sheet dodawania pliku
  void _showAddFileDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) =>
              BlocProvider.value(value: this.context.read<SongDetailCubit>(), child: const AddFileBottomSheet()),
    );
  }
}
