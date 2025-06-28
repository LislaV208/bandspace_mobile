import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/models/project.dart';

/// Komponent karty projektu dla ekranu dashboardu.
///
/// Wyświetla informacje o projekcie, takie jak nazwa, czas utworzenia,
/// liczbę członków oraz avatary członków projektu.
class DashboardProjectCard extends StatelessWidget {
  /// Model projektu zawierający wszystkie dane do wyświetlenia
  final Project project;

  /// Czas utworzenia projektu w formie względnej (np. "2h temu")
  final String createdTime;

  /// Funkcja wywoływana po kliknięciu na kartę projektu
  final VoidCallback? onTap;

  const DashboardProjectCard({super.key, required this.project, required this.createdTime, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {}, // Obsługa kliknięcia
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937), // bg-gray-800
            border: Border.all(color: const Color(0xFF374151)), // border-gray-700
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(), _buildContent()]),
        ),
      ),
    );
  }

  /// Buduje nagłówek karty projektu z gradientem i ikoną muzyczną
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 128, // h-32 w Tailwind
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF312E81)], // from-blue-900 to-indigo-900
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Center(
        child: Icon(
          LucideIcons.music,
          size: 48,
          color: const Color(0xFF60A5FA).withAlpha(204), // text-blue-400 opacity-80 (0.8 * 255 = 204)
        ),
      ),
    );
  }

  /// Buduje zawartość karty projektu z informacjami o projekcie
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'Utworzono $createdTime',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF), // text-gray-400
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Expanded(child: _buildMemberAvatars()), _buildMemberCountBadge()],
          ),
        ],
      ),
    );
  }

  /// Buduje badge z informacją o projekcie
  Widget _buildMemberCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withAlpha(51), // bg-blue-600/20 (0.2 * 255 = 51)
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        project.slug,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF60A5FA), // text-blue-400
        ),
      ),
    );
  }

  /// Buduje informacje o utworzeniu projektu
  Widget _buildMemberAvatars() {
    return Text(
      'Slug: ${project.slug}',
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF9CA3AF), // text-gray-400
      ),
    );
  }

}
