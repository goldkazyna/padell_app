import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tournament.dart';
import '../providers/home_provider.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_tab_bar.dart';
import '../widgets/moderation_countdown.dart';
import '../widgets/tournaments/club_section_header.dart';
import '../widgets/tournaments/hero_tournament_card.dart';
import 'club_detail_screen.dart';
import 'tournament_detail_screen.dart';

/// Экран «Мои турниры» — открывается из профиля по кнопке.
/// Показывает турниры на которые пользователь записан и которые ещё не
/// прошли (статусы open / closed / in_progress).
class MyTournamentsScreen extends StatefulWidget {
  const MyTournamentsScreen({super.key});

  @override
  State<MyTournamentsScreen> createState() => _MyTournamentsScreenState();
}

class _MyTournamentsScreenState extends State<MyTournamentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadMyTournaments();
    });
  }

  double? get _userLevel {
    final user = context.read<HomeProvider>().user;
    if (user == null) return null;
    return double.tryParse(user.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text(
          'Мои турниры',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: const MainTabBar(),
      body: Consumer<TournamentProvider>(
        builder: (_, provider, __) {
          if (provider.isLoadingMy && provider.myTournaments.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (provider.myTournaments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Вы не записаны ни на один предстоящий турнир',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
            );
          }

          // Группируем по клубу (как на экране турниров на вкладке «Мои»)
          final byClub = <int, List<Tournament>>{};
          for (final t in provider.myTournaments) {
            byClub.putIfAbsent(t.club.id, () => []).add(t);
          }
          final clubIds = byClub.keys.toList()
            ..sort((a, b) => byClub[a]!.first.club.name
                .compareTo(byClub[b]!.first.club.name));

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () => provider.loadMyTournaments(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                for (final clubId in clubIds) ...[
                  const SizedBox(height: 8),
                  _MyClubBlock(
                    tournaments: byClub[clubId]!..sort(_compareByDate),
                    userLevel: _userLevel,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  static int _compareByDate(Tournament a, Tournament b) {
    return a.datetime.compareTo(b.datetime);
  }
}

class _MyClubBlock extends StatelessWidget {
  final List<Tournament> tournaments;
  final double? userLevel;

  const _MyClubBlock({required this.tournaments, required this.userLevel});

  @override
  Widget build(BuildContext context) {
    final first = tournaments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClubSectionHeader(
          clubName: first.club.name,
          city: first.club.city,
          logoUrl: first.club.logo,
          openCount: tournaments.length,
          totalCount: tournaments.length,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClubDetailScreen(clubId: first.club.id),
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final t in tournaments)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeroTournamentCard(
                  tournament: t,
                  userLevel: userLevel,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TournamentDetailScreen(tournamentId: t.id),
                    ),
                  ),
                ),
                if (t.moderationDeadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ModerationCountdown(deadline: t.moderationDeadline!),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
