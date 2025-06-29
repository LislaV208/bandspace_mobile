import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';

/// Komponent nagłówka projektu wyświetlający informacje podstawowe
class ProjectHeader extends StatelessWidget {
  final Project project;

  const ProjectHeader({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: _buildProjectStats(),
    );
  }

  /// Buduje podstawowe informacje o projekcie

  /// Buduje statystyki projektu
  Widget _buildProjectStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: LucideIcons.music,
          label: 'Utwory',
          value: '8', // Mock data
        ),
        const SizedBox(width: 24),
        _buildStatItem(icon: LucideIcons.users, label: 'Członkowie', value: project.membersCount.toString()),
        const SizedBox(width: 24),
        _buildStatItem(icon: LucideIcons.calendar, label: 'Utworzono', value: _formatDate(project.createdAt)),
      ],
    );
  }

  /// Buduje pojedynczy element statystyki
  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  /// Formatuje datę do czytelnej formy
  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${_getMonthText(months)} temu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${_getDayText(difference.inDays)} temu';
    } else {
      return 'dziś';
    }
  }

  String _getMonthText(int count) {
    if (count == 1) return 'miesiąc';
    if (count >= 2 && count <= 4) return 'miesiące';
    return 'miesięcy';
  }

  String _getDayText(int count) {
    if (count == 1) return 'dzień';
    return 'dni';
  }
}
