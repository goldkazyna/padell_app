import 'package:flutter/material.dart';
import '../../screens/admin/admin_create_tournament_screen.dart';
import '../../screens/admin/admin_tournaments_screen.dart';
import '../../theme/app_theme.dart';

/// Блок на главной для обычного игрока с грантом can_create_tournaments:
/// создание и управление ЛИЧНЫМИ (приватными) турнирами.
class PersonalCreatorBlock extends StatelessWidget {
  const PersonalCreatorBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withAlpha(60), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sports_tennis_rounded,
                    color: AppTheme.accent, size: 16),
              ),
              const SizedBox(width: 8),
              const Text('МОИ ТУРНИРЫ',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          _Cta(
            icon: Icons.add_circle_outline,
            title: 'Создать турнир',
            subtitle: 'Личный турнир — в общем списке не виден',
            colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminCreateTournamentScreen(
                  clubId: null,
                  clubName: 'Личный турнир',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Cta(
            icon: Icons.list_alt_rounded,
            title: 'Мои турниры',
            subtitle: 'Созданные вами турниры',
            colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminTournamentsScreen(
                  clubId: null,
                  clubName: 'Мои турниры',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _Cta({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
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
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withAlpha(60),
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
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
