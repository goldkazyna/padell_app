import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../screens/my_leagues_screen.dart';
import '../../screens/my_tournaments_history_screen.dart';
import '../../screens/my_tournaments_screen.dart';
import '../../screens/my_trainings_screen.dart';
import '../../screens/support_tickets_screen.dart';
import '../../screens/tournament_invitations_screen.dart';
import '../../services/invitation_service.dart';
import '../../services/league_service.dart';
import '../../services/support_service.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';
import '../court_grid_background.dart';

/// Меню профиля: шесть зон на корте.
///
/// Заменило шесть цветных карточек во всю ширину. Они кричали одинаково
/// громко — «Служба поддержки» выглядела так же важно, как приглашение, на
/// которое ждут ответа. Здесь всё в одном блоке вдвое меньшей высоты, а
/// цветом выделена ровно одна зона: та, где нужен ты.
class ProfileCourtMenu extends StatefulWidget {
  const ProfileCourtMenu({super.key});

  @override
  State<ProfileCourtMenu> createState() => _ProfileCourtMenuState();
}

class _ProfileCourtMenuState extends State<ProfileCourtMenu> {
  int _invitations = 0;
  int _trainings = 0;
  int _leagues = 0;
  int _support = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  /// Счётчики тянем по отдельности: любой из них может не ответить, и это
  /// не повод оставлять весь блок без цифр.
  Future<void> _loadCounts() async {
    // Сервисы забираем до первого await: после него трогать context нельзя.
    final invitations = context.read<InvitationService>();
    final trainings = context.read<TrainingService>();
    final leagues = context.read<LeagueService>();
    final support = context.read<SupportService>();

    try {
      final count = await invitations.getCount();
      if (mounted) setState(() => _invitations = count);
    } catch (_) {}

    try {
      final counts = await trainings.getCounts();
      if (mounted) setState(() => _trainings = counts.upcoming);
    } catch (_) {}

    try {
      // Считаем только идущие: завершённые лиги живут в истории и цифру
      // в меню бы только раздували.
      final mine = await leagues.mine();
      final running = mine.where((l) => l.isRunning).length;
      if (mounted) setState(() => _leagues = running);
    } catch (_) {}

    try {
      final count = await support.getUnreadCount();
      if (mounted) setState(() => _support = count);
    } catch (_) {}
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final played = context.watch<ProfileProvider>().statistics?.tournamentsCount ?? 0;
    final myTournaments = context.watch<TournamentProvider>().myTournaments.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.42),
              width: 1.5,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF16281F), Color(0xFF12211C), Color(0xFF0D1714)],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: CourtGridBackground()),
              Column(
                children: [
                  _zoneRow(
                    left: _Zone(
                      icon: Icons.event_available_outlined,
                      accent: true,
                      title: l10n.profileMyTournaments,
                      subtitle: l10n.profileMyTournamentsSub,
                      value: myTournaments > 0 ? '$myTournaments' : null,
                      valueColor: AppTheme.accent,
                      onTap: () => _open(const MyTournamentsScreen()),
                    ),
                    right: _Zone(
                      icon: Icons.mail_outline,
                      warn: true,
                      hot: true,
                      title: l10n.profileInvitations,
                      subtitle: l10n.profileInvitationsSub,
                      badge: _invitations,
                      onTap: () => _open(const TournamentInvitationsScreen()),
                    ),
                    divider: true,
                  ),
                  _zoneRow(
                    left: _Zone(
                      icon: Icons.sports_tennis_outlined,
                      title: l10n.profileMyTrainings,
                      subtitle: l10n.profileMyTrainingsSub,
                      value: _trainings > 0 ? '$_trainings' : null,
                      onTap: () => _open(const MyTrainingsScreen()),
                    ),
                    right: _Zone(
                      icon: Icons.emoji_events_outlined,
                      title: l10n.profileMyLeagues,
                      subtitle: l10n.profileMyLeaguesSub,
                      value: _leagues > 0 ? '$_leagues' : null,
                      onTap: () => _open(const MyLeaguesScreen()),
                    ),
                    divider: true,
                  ),
                  _zoneRow(
                    left: _Zone(
                      icon: Icons.history,
                      title: l10n.profileHistory,
                      subtitle: l10n.profileHistorySub,
                      value: played > 0 ? '$played' : null,
                      onTap: () => _open(const MyTournamentsHistoryScreen()),
                    ),
                    right: _Zone(
                      icon: Icons.headset_mic_outlined,
                      title: l10n.profileSupport,
                      subtitle: l10n.profileSupportSub,
                      badge: _support,
                      onTap: () => _open(const SupportTicketsScreen()),
                    ),
                    divider: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ряд из двух зон: вертикальная линия между ними — как разметка корта,
  /// горизонтальная снизу — акцентная, она же граница половин.
  Widget _zoneRow({
    required Widget left,
    required Widget right,
    required bool divider,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.accent.withValues(alpha: 0.26),
                  width: 1.5,
                ),
              )
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0x1AFFFFFF), width: 1.5),
                  ),
                ),
                child: left,
              ),
            ),
            Expanded(child: right),
          ],
        ),
      ),
    );
  }
}

/// Одна зона корта: иконка, число или бейдж, название и подпись.
class _Zone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Число справа сверху (сколько турниров, сыграно и так далее).
  final String? value;
  final Color? valueColor;

  /// Красный кружок с числом — там, где ждут ответа.
  final int badge;

  /// Акцентная иконка (свои ближайшие турниры).
  final bool accent;

  /// Красная иконка (приглашения).
  final bool warn;

  /// Подсветка всей зоны — только у той, где нужен человек.
  final bool hot;

  final VoidCallback onTap;

  const _Zone({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
    this.valueColor,
    this.badge = 0,
    this.accent = false,
    this.warn = false,
    this.hot = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = warn
        ? AppTheme.error
        : (accent ? AppTheme.accent : AppTheme.textPrimary);
    final iconBg = warn
        ? AppTheme.error.withValues(alpha: 0.16)
        : (accent
            ? AppTheme.accent.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.06));
    final iconBorder = warn
        ? AppTheme.error.withValues(alpha: 0.32)
        : (accent
            ? AppTheme.accent.withValues(alpha: 0.32)
            : Colors.white.withValues(alpha: 0.08));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        color: hot ? AppTheme.error.withValues(alpha: 0.10) : null,
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: iconBorder),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const Spacer(),
                if (badge > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (value != null)
                  Text(
                    value!,
                    style: TextStyle(
                      color: valueColor ?? AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  )
                else
                  Icon(Icons.chevron_right, size: 16, color: AppTheme.textDim),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
