import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../screens/admin/admin_create_tournament_screen.dart';
import '../../screens/admin/admin_tournaments_screen.dart';
import '../../theme/app_theme.dart';

/// Блок «Управление клубом» на главной — показывается только если у user
/// `isClubAdmin == true` (есть админский доступ хотя бы к одному клубу).
class AdminClubBlock extends StatelessWidget {
  final List<AdminClubRef> adminClubs;

  const AdminClubBlock({super.key, required this.adminClubs});

  @override
  Widget build(BuildContext context) {
    if (adminClubs.isEmpty) return const SizedBox.shrink();
    // На MVP считаем что админ одного клуба. Если их несколько —
    // берём первый, дальше в Этапе 2 добавим выбор.
    final club = adminClubs.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF7C3AED),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'УПРАВЛЕНИЕ КЛУБОМ',
                style: TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            club.name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _AdminCta(
            icon: Icons.list_alt_rounded,
            title: 'Мои турниры',
            subtitle: 'Все турниры клуба и их статусы',
            gradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminTournamentsScreen(
                  clubId: club.id,
                  clubName: club.name,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _AdminCta(
            icon: Icons.add_circle_outline,
            title: 'Создать турнир',
            subtitle: 'Новый турнир в клубе',
            gradientColors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminCreateTournamentScreen(
                  clubId: club.id,
                  clubName: club.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCta extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _AdminCta({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withAlpha(60),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
