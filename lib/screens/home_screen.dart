import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_stats.dart';
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
            onRefresh: () => home.refresh(),
            color: AppTheme.accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHeader(),
                  const ProfileIncompleteBanner(),
                  const SizedBox(height: 20),
                  const HomeStats(),
                  const SizedBox(height: 20),
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
                      if (home.activeTournament != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TournamentDetailScreen(
                              tournamentId: home.activeTournament!.id,
                            ),
                          ),
                        );
                      }
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
