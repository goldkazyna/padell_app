import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../providers/profile_provider.dart';
import '../../screens/player_profile_screen.dart';
import '../../screens/tournament_results_screen.dart';
import '../../theme/app_theme.dart';

class TournamentHistory extends StatelessWidget {
  const TournamentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final tournaments = profile.tournamentHistory;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.tournamentHistory,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tournaments.length > 3 && profile.user != null)
                  GestureDetector(
                    onTap: () {
                      final user = profile.user!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: user.id,
                            playerName: user.name,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.allButton,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.isLoadingHistory && tournaments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              )
            else if (tournaments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF2A2A2A), width: 0.5),
                ),
                child: Text(
                  AppLocalizations.of(context)!.noFinishedTournamentsYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...List.generate(
                tournaments.length > 5 ? 5 : tournaments.length,
                (i) {
                  return _TournamentHistoryCard(tournament: tournaments[i]);
                },
              ),
          ],
        );
      },
    );
  }
}

class _TournamentHistoryCard extends StatelessWidget {
  final Tournament tournament;

  const _TournamentHistoryCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final place = tournament.myResult?.place;
    final ratingChange = tournament.myResult?.ratingChange ?? 0;
    final isPositive = ratingChange >= 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TournamentResultsScreen(
              tournament: tournament,
            ),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Row(
          children: [
            _buildPlaceIcon(place),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    tournament.dateFormatted,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF3F3F46)),
            SizedBox(
              width: 50,
              child: Text(
                '${isPositive ? '+' : ''}$ratingChange',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isPositive ? AppTheme.accent : const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceIcon(int? place) {
    if (place == 1) {
      return const SizedBox(width: 48, height: 48, child: Center(child: Text('🥇', style: TextStyle(fontSize: 32))));
    } else if (place == 2) {
      return const SizedBox(width: 48, height: 48, child: Center(child: Text('🥈', style: TextStyle(fontSize: 32))));
    } else if (place == 3) {
      return const SizedBox(width: 48, height: 48, child: Center(child: Text('🥉', style: TextStyle(fontSize: 32))));
    } else if (place != null && place > 0) {
      return SizedBox(
        width: 48, height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$place',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'место',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.emoji_events, size: 22, color: AppTheme.textSecondary),
        ),
      );
    }
  }
}
