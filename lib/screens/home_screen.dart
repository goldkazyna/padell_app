import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_stats.dart';
import '../widgets/home/nearest_tournament_card.dart';
import '../widgets/home/active_tournament_card.dart';
import '../widgets/home/upcoming_list.dart';
import '../widgets/home/section_title.dart';
import '../theme/app_theme.dart';
import 'tournament_detail_screen.dart';

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
                    child: const Text('Повторить'),
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
                  const SizedBox(height: 20),
                  const HomeStats(),
                  const SizedBox(height: 28),
                  const SectionTitle(title: 'Ближайший турнир'),
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
                  const SectionTitle(title: 'Активный турнир'),
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
                  const SizedBox(height: 28),
                  SectionTitle(
                    title: 'Скоро',
                    trailing: 'Все',
                    onTrailingTap: () {
                      widget.onNavigateToTab?.call(1); // Tournaments tab
                    },
                  ),
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
}
