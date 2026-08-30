import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../screens/admin/admin_create_tournament_screen.dart';
import '../../screens/admin/admin_edit_club_screen.dart';
import '../../screens/admin/admin_moderators_screen.dart';
import '../../screens/admin/admin_tournaments_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../theme/app_theme.dart';
import '../../screens/admin/admin_leagues_screen.dart';

/// Блок «Управление клубом» на главной — показывается админам клуба
/// и модераторам клуба. Кнопка «Создать турнир» прячется если у юзера
/// нет полного доступа к турнирам (обычный модератор).
class AdminClubBlock extends StatelessWidget {
  final List<AdminClubRef> clubs;
  final bool tournamentsFullAccess;
  final bool isModerator;

  const AdminClubBlock({
    super.key,
    required this.clubs,
    this.tournamentsFullAccess = true,
    this.isModerator = false,
  });

  @override
  Widget build(BuildContext context) {
    if (clubs.isEmpty) return const SizedBox.shrink();
    // На MVP — берём первый клуб. Если несколько — добавим выбор позже.
    final club = clubs.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withAlpha(60),
          width: 1,
        ),
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
                  color: const Color(0xFF7C3AED).withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFA78BFA),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isModerator && !tournamentsFullAccess
                    ? 'МОДЕРАЦИЯ КЛУБА'
                    : 'УПРАВЛЕНИЕ КЛУБОМ',
                style: const TextStyle(
                  color: Color(0xFFA78BFA),
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
            style: TextStyle(
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
          if (tournamentsFullAccess) ...[
            const SizedBox(height: 8),
            _AdminCta(
              icon: Icons.emoji_events_outlined,
              title: 'Лиги',
              subtitle: 'Серия турниров с общей таблицей',
              gradientColors: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminLeaguesScreen(clubName: club.name),
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
          if (!isModerator) ...[
            const SizedBox(height: 8),
            _AdminCta(
              icon: Icons.edit_outlined,
              title: AppLocalizations.of(context)!.editClubCard,
              subtitle: AppLocalizations.of(context)!.editClubCardSubtitle,
              gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminEditClubScreen(clubId: club.id),
                ),
              ),
            ),
          ],
          if (!isModerator && club.hasFeature('users')) ...[
            const SizedBox(height: 8),
            _AdminCta(
              icon: Icons.people_outline,
              title: 'Пользователи',
              subtitle: 'Игроки, уровни, верификация',
              gradientColors: const [Color(0xFFF97316), Color(0xFFEA580C)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminUsersScreen(
                    clubId: club.id,
                    clubName: club.name,
                  ),
                ),
              ),
            ),
          ],
          if (!isModerator && club.hasFeature('moderators')) ...[
            const SizedBox(height: 8),
            _AdminCta(
              icon: Icons.shield_outlined,
              title: 'Модераторы',
              subtitle: 'Управление модераторами клуба',
              gradientColors: const [Color(0xFF14B8A6), Color(0xFF0D9488)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminModeratorsScreen(
                    clubId: club.id,
                    clubName: club.name,
                  ),
                ),
              ),
            ),
          ],
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
