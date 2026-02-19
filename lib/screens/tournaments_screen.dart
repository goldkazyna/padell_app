import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournaments/tournament_card.dart';
import '../widgets/tournaments/tournament_archive_card.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Турниры',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Открытые'),
                  Tab(text: 'Мои'),
                  Tab(text: 'Архив'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _OpenTab(),
                  _MyTab(),
                  _ArchiveTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openTournamentDetail(BuildContext context, int tournamentId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TournamentDetailScreen(tournamentId: tournamentId),
    ),
  );
}

class _OpenTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingOpen) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.openTournaments.isEmpty) {
          return const Center(
            child: Text(
              'Нет открытых турниров',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadOpenTournaments(),
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.openTournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final t = provider.openTournaments[index];
              return GestureDetector(
                onTap: () => _openTournamentDetail(context, t.id),
                child: TournamentCard.fromTournament(t),
              );
            },
          ),
        );
      },
    );
  }
}

class _MyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingMy) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.myTournaments.isEmpty) {
          return const Center(
            child: Text(
              'Вы не записаны на турниры',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMyTournaments(),
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.myTournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final t = provider.myTournaments[index];
              return GestureDetector(
                onTap: () => _openTournamentDetail(context, t.id),
                child: TournamentCard.fromTournament(t),
              );
            },
          ),
        );
      },
    );
  }
}

class _ArchiveTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingArchive) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.archiveTournaments.isEmpty) {
          return const Center(
            child: Text(
              'Нет завершённых турниров',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadArchiveTournaments(),
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.archiveTournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final t = provider.archiveTournaments[index];
              return GestureDetector(
                onTap: () => _openTournamentDetail(context, t.id),
                child: TournamentArchiveCard.fromTournament(t),
              );
            },
          ),
        );
      },
    );
  }
}
