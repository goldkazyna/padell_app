import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/home_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/home/notification_bell.dart';
import '../widgets/profile/profile_hero.dart';
import '../widgets/home/nearest_tournament_card.dart';
import '../widgets/home/active_tournament_card.dart';
import '../widgets/home/upcoming_list.dart';
import '../widgets/home/section_title.dart';
import '../widgets/home/court_booking_banner.dart';
import '../widgets/home/clubs_banner.dart';
import 'clubs_list_screen.dart';
import '../widgets/home/profile_incomplete_banner.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'tournament_detail_screen.dart';
import 'tournament_live_screen.dart';
import 'tournament_live_mexicano_screen.dart';
import 'tournament_live_team_screen.dart';
import 'tournament_live_kingofcourt_screen.dart';
import 'club_select_screen.dart';
import 'create_challenge_screen.dart';
import 'challenges_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<HomeProvider>(
        builder: (context, home, _) {
          if (home.isLoading && home.user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }

          if (home.error != null && home.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    home.error!,
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => home.loadHomeData(),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                home.refresh(),
                context.read<ProfileProvider>().loadProfile(),
              ]);
            },
            color: AppTheme.accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHero(trailing: NotificationBell()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  const ProfileIncompleteBanner(),
                  CourtBookingBanner(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClubSelectScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ClubsBanner(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClubsListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _CreateTournamentBanner(
                    onTap: () => _showAccreditationDialog(context),
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(title: AppLocalizations.of(context)!.nearestTournament),
                  const SizedBox(height: 12),
                  NearestTournamentCard(
                    tournament: home.nearestTournament,
                    onRegister: () {
                      if (home.nearestTournament != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TournamentDetailScreen(
                              tournamentId: home.nearestTournament!.id,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(title: AppLocalizations.of(context)!.activeTournament),
                  const SizedBox(height: 12),
                  ActiveTournamentCard(
                    tournament: home.activeTournament,
                    onTap: () {
                      final t = home.activeTournament;
                      if (t == null) return;
                      final isLive = t.status == 'in_progress';
                      Widget target;
                      if (isLive && t.type == 'americano') {
                        target = TournamentLiveScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'mexicano') {
                        target = TournamentLiveMexicanoScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'team') {
                        target = TournamentLiveTeamScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'king_of_court') {
                        target =
                            TournamentLiveKingOfCourtScreen(tournamentId: t.id);
                      } else {
                        target = TournamentDetailScreen(tournamentId: t.id);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => target),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Игры: создать + список
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: AppLocalizations.of(context)!.challengeCreateButton,
                          subtitle: 'Вызвать на игру',
                          icon: Icons.add_circle_outline,
                          gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          shadowColor: const Color(0xFF3B82F6),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateChallengeScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionCard(
                          title: 'Игры',
                          subtitle: 'Все вызовы',
                          icon: Icons.sports_tennis,
                          gradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
                          shadowColor: const Color(0xFFF97316),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(title: AppLocalizations.of(context)!.upcoming),
                  const SizedBox(height: 12),
                  UpcomingList(
                    tournaments: home.upcomingTournaments,
                    onTap: (tournament) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TournamentDetailScreen(
                            tournamentId: tournament.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withAlpha(30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAccreditationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: Color(0xFFF97316),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Аккредитация',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Чтобы вы могли создавать турниры, вам необходимо получить аккредитацию.\n\nНапишите в Telegram:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://t.me/mdlabkz');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF229ED9).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF229ED9).withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.send_rounded,
                        color: Color(0xFF229ED9),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '@mdlabkz',
                        style: TextStyle(
                          color: Color(0xFF229ED9),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Понятно',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CreateTournamentBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateTournamentBanner({required this.onTap});

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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF97316), Color(0xFFEA580C)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Создать турнир',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Организуй своё событие',
                      style: TextStyle(
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
