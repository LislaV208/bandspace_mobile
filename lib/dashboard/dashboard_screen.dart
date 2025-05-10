import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/components/user_drawer.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Pobierz dane użytkownika z AuthState
        final user = state.user;
        final userName = user?.email.split('@').first ?? 'Użytkownik';
        final userEmail = user?.email ?? 'uzytkownik@example.com';

        return Scaffold(
          backgroundColor: AppColors.background,
          endDrawer: UserDrawer(
            userName: userName,
            userEmail: userEmail,
            // Możemy dodać avatarUrl, gdy będzie dostępny w modelu użytkownika
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildHeader(context), Expanded(child: _buildProjectsList())],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('BandSpace', style: AppTextStyles.headlineMedium), _buildUserAvatar(context)],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final userName = user?.email.split('@').first ?? 'U';

        return Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => _openUserDrawer(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(20), child: _buildAvatarContent(userName)),
              ),
            );
          },
        );
      },
    );
  }

  /// Buduje zawartość avatara użytkownika
  Widget _buildAvatarContent(String userName) {
    // Tutaj możemy dodać logikę pobierania avatara z API, gdy będzie dostępna
    // Na razie używamy pierwszej litery nazwy użytkownika
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          userName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  void _openUserDrawer(BuildContext context) {
    // Otwiera drawer z prawej strony ekranu
    Scaffold.of(context).openEndDrawer();
  }

  Widget _buildProjectsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Moje Projekty', style: AppTextStyles.headlineLarge),
          Text('Zarządzaj i organizuj swoje projekty muzyczne', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          _buildNewProjectButton(),
          const SizedBox(height: 16),
          _buildProjectCard(
            name: 'BetaTesters',
            createdTime: '1m temu',
            memberCount: 3,
            members: [
              'https://randomuser.me/api/portraits/men/32.jpg',
              'https://ui-avatars.com/api/?name=G&background=4263EB&color=fff',
              'https://randomuser.me/api/portraits/men/45.jpg',
            ],
          ),
          const SizedBox(height: 16),
          _buildProjectCard(
            name: 'Velow',
            createdTime: '1m temu',
            memberCount: 4,
            members: [
              'https://randomuser.me/api/portraits/men/32.jpg',
              'https://ui-avatars.com/api/?name=S&background=000000&color=fff',
              'https://ui-avatars.com/api/?name=W&background=008000&color=fff',
              'https://ui-avatars.com/api/?name=E&background=9932CC&color=fff',
            ],
          ),
          const SizedBox(height: 16),
          _buildProjectCard(
            name: 'Projekt 3',
            createdTime: '2h temu',
            memberCount: 2,
            members: [
              'https://randomuser.me/api/portraits/men/32.jpg',
              'https://randomuser.me/api/portraits/women/44.jpg',
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNewProjectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nowy Projekt'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB), // Jasny niebieski kolor z zrzutu ekranu
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildProjectCard({
    required String name,
    required String createdTime,
    required int memberCount,
    required List<String> members,
  }) {
    // Funkcja do określenia prawidłowej odmiany słowa "członek"
    String getMemberCountText(int count) {
      if (count == 1) {
        return "członek";
      } else {
        return "członków";
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Dodaj obsługę kliknięcia
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937), // bg-gray-800
            border: Border.all(color: const Color(0xFF374151)), // border-gray-700
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikona muzyczna z gradientem
              Container(
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
              ),
              // Informacje o projekcie
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
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
                      children: [
                        Expanded(child: _buildMemberAvatars(members)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withAlpha(51), // bg-blue-600/20 (0.2 * 255 = 51)
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$memberCount ${getMemberCountText(memberCount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF60A5FA), // text-blue-400
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatars(List<String> avatarUrls) {
    final maxVisibleAvatars = 5;
    final visibleAvatars =
        avatarUrls.length > maxVisibleAvatars ? avatarUrls.sublist(0, maxVisibleAvatars) : avatarUrls;

    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          ...List.generate(
            visibleAvatars.length,
            (index) => Positioned(
              left: index * 20.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1F2937), width: 2), // border-gray-800
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(visibleAvatars[index], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          if (avatarUrls.length > maxVisibleAvatars)
            Positioned(
              left: maxVisibleAvatars * 20.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF374151), // bg-gray-700
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1F2937), width: 2), // border-gray-800
                ),
                child: Center(
                  child: Text(
                    '+${avatarUrls.length - maxVisibleAvatars}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
