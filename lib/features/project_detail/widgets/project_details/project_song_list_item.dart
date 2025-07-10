import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

/// Komponent elementu listy utworów
class ProjectSongListItem extends StatelessWidget {
  final Song song;

  const ProjectSongListItem({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: AppColors.surface,
      onTap: () {},
      leading: _buildSongIcon(),
      title: Text(
        song.title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.timeAgo,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
      ),
    );
  }

  /// Buduje ikonę utworu
  Widget _buildSongIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha((255 * 0.15).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        song.isPrivate ? LucideIcons.lock : LucideIcons.music,
        size: 20,
        color: AppColors.accent,
      ),
    );
  }

  /// Buduje badge z liczbą plików
  // Widget _buildFileCount() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
  //     child: Text(
  //       '${song.fileCount}',
  //       style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
  //     ),
  //   );
  // }

  /// Pokazuje opcje utworu
  // void _showSongOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColors.surface,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) => _buildSongOptionsSheet(context),
  //   );
  // }

  /// Buduje arkusz opcji utworu
  // Widget _buildSongOptionsSheet(BuildContext context) {
  //   return SafeArea(
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         const SizedBox(height: 12),
  //         Container(
  //           width: 40,
  //           height: 4,
  //           decoration: BoxDecoration(
  //             color: AppColors.textSecondary,
  //             borderRadius: BorderRadius.circular(2),
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           child: Row(
  //             children: [
  //               _buildSongIcon(),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       song.title,
  //                       style: AppTextStyles.titleMedium.copyWith(
  //                         color: AppColors.textPrimary,
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       '${song.fileCount} ${_getFileText(song.fileCount)} • ${song.timeAgo}',
  //                       style: AppTextStyles.bodySmall.copyWith(
  //                         color: AppColors.textSecondary,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 24),
  //         _buildOptionTile(
  //           context: context,
  //           icon: LucideIcons.play,
  //           title: 'Odtwórz',
  //           onTap: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //         _buildOptionTile(
  //           context: context,
  //           icon: LucideIcons.pencil,
  //           title: 'Edytuj',
  //           onTap: () {
  //             Navigator.pop(context);
  //             // TODO: Implement edit song
  //           },
  //         ),
  //         _buildOptionTile(
  //           context: context,
  //           icon: LucideIcons.share,
  //           title: 'Udostępnij',
  //           onTap: () {
  //             Navigator.pop(context);
  //             // TODO: Implement share song
  //           },
  //         ),
  //         _buildOptionTile(
  //           context: context,
  //           icon: LucideIcons.download,
  //           title: 'Pobierz',
  //           onTap: () {
  //             Navigator.pop(context);
  //             // TODO: Implement download song
  //           },
  //         ),
  //         const Divider(color: AppColors.divider, height: 1),
  //         _buildOptionTile(
  //           context: context,
  //           icon: LucideIcons.trash2,
  //           title: 'Usuń',
  //           onTap: () {
  //             Navigator.pop(context);
  //           },
  //           isDestructive: true,
  //         ),
  //         const SizedBox(height: 20),
  //       ],
  //     ),
  //   );
  // }

  /// Buduje element opcji w arkuszu
  // Widget _buildOptionTile({
  //   required BuildContext context,
  //   required IconData icon,
  //   required String title,
  //   required VoidCallback onTap,
  //   bool isDestructive = false,
  // }) {
  //   return ListTile(
  //     leading: Icon(
  //       icon,
  //       color: isDestructive ? AppColors.error : AppColors.textPrimary,
  //     ),
  //     title: Text(
  //       title,
  //       style: AppTextStyles.bodyLarge.copyWith(
  //         color: isDestructive ? AppColors.error : AppColors.textPrimary,
  //       ),
  //     ),
  //     onTap: onTap,
  //   );
  // }

  // /// Zwraca prawidłową odmianę słowa "plik"
  // String _getFileText(int count) {
  //   if (count == 1) return 'plik';
  //   if (count >= 2 && count <= 4) return 'pliki';
  //   return 'plików';
  // }
}
