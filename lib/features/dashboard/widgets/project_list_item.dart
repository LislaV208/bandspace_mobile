import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/utils/date_format_utils.dart';
import 'package:bandspace_mobile/features/project_detail/screens/project_detail_screen.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/widgets/user_avatar.dart';

/// Komponent karty projektu dla ekranu dashboardu.
class ProjectListItem extends StatelessWidget {
  final Project project;

  const ProjectListItem({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () => _navigateToProject(context), // Obsługa kliknięcia
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  /// Buduje zawartość karty projektu z informacjami o projekcie
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 16,
            children: [
              Container(
                width: 48,
                height: 48, // h-32 w Tailwind
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ], // from-blue-900 to-indigo-900
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Icon(
                    Icons.library_music,
                    size: 28,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Utworzono ${DateFormatUtils.formatRelativeTime(project.createdAt)}',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildMemberAvatars()),
              _buildMemberCountBadge(context),
            ],
          ),
        ],
      ),
    );
  }

  /// Buduje badge z liczbą członków projektu
  Widget _buildMemberCountBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${project.users.length} ${_getMemberCountText(project.users.length)}',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  /// Buduje awatary członków projektu
  Widget _buildMemberAvatars() {
    const maxVisibleAvatars = 5;
    final members = project.users;
    final visibleMembers = members.length > maxVisibleAvatars
        ? members.sublist(0, maxVisibleAvatars)
        : members;

    if (members.isEmpty) {
      return const Text(
        'Brak członków',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF), // text-gray-400
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          ...List.generate(
            visibleMembers.length,
            (index) => Positioned(
              left: index * 24.0,
              child: UserAvatar(
                user: visibleMembers[index],
                size: 30,
              ),
            ),
          ),
          if (members.length > maxVisibleAvatars)
            Positioned(
              left: maxVisibleAvatars * 24.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF374151), // bg-gray-700
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1F2937), // border-gray-800
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+${members.length - maxVisibleAvatars}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Zwraca prawidłową odmianę słowa "osoba" w zależności od liczby
  String _getMemberCountText(int count) {
    if (count == 1) {
      return 'osoba';
    } else if (count >= 2 && count <= 4) {
      return 'osoby';
    } else {
      return 'osób';
    }
  }

  /// Nawiguje do ekranu szczegółów projektu
  void _navigateToProject(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen.create(project),
      ),
    );
  }
}
