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
import '../court_menu_panel.dart';

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
      child: CourtMenuPanel(
        rows: [
              CourtMenuRow(
                left: CourtMenuZone(
                  icon: Icons.event_available_outlined,
                  accent: true,
                  title: l10n.profileMyTournaments,
                  subtitle: l10n.profileMyTournamentsSub,
                  value: myTournaments > 0 ? '$myTournaments' : null,
                  valueColor: AppTheme.accent,
                  onTap: () => _open(const MyTournamentsScreen()),
                ),
                right: CourtMenuZone(
                  icon: Icons.mail_outline,
                  alert: true,
                  title: l10n.profileInvitations,
                  subtitle: l10n.profileInvitationsSub,
                  badge: _invitations,
                  onTap: () => _open(const TournamentInvitationsScreen()),
                ),
                divider: true,
              ),
              CourtMenuRow(
                left: CourtMenuZone(
                  icon: Icons.sports_tennis_outlined,
                  title: l10n.profileMyTrainings,
                  subtitle: l10n.profileMyTrainingsSub,
                  value: _trainings > 0 ? '$_trainings' : null,
                  onTap: () => _open(const MyTrainingsScreen()),
                ),
                right: CourtMenuZone(
                  icon: Icons.emoji_events_outlined,
                  title: l10n.profileMyLeagues,
                  subtitle: l10n.profileMyLeaguesSub,
                  value: _leagues > 0 ? '$_leagues' : null,
                  onTap: () => _open(const MyLeaguesScreen()),
                ),
                divider: true,
              ),
              CourtMenuRow(
                left: CourtMenuZone(
                  icon: Icons.history,
                  title: l10n.profileHistory,
                  subtitle: l10n.profileHistorySub,
                  value: played > 0 ? '$played' : null,
                  onTap: () => _open(const MyTournamentsHistoryScreen()),
                ),
                right: CourtMenuZone(
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
    );
  }
}
