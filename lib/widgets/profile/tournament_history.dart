import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tournament.dart';
import '../../providers/profile_provider.dart';
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
                const Text(
                  'История турниров',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tournaments.length > 3)
                  GestureDetector(
                    onTap: () {
                      // TODO: показать все турниры
                    },
                    child: const Text(
                      'Все',
                      style: TextStyle(
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
                child: const Text(
                  'Пока нет завершённых турниров',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...List.generate(
                tournaments.length > 5 ? 5 : tournaments.length,
                (i) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: i < tournaments.length - 1 && i < 4 ? 8 : 0),
                    child: _TournamentHistoryCard(tournament: tournaments[i]),
                  );
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
    final placeColor = _placeColor(place);

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    tournament.dayOfMonth,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tournament.monthShort,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tournament.club.name,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (place != null && place >= 1 && place <= 2)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: placeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: placeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$place место',
                      style: TextStyle(
                        color: placeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _placeColor(int? place) {
    switch (place) {
      case 1:
        return const Color(0xFFFBBF24); // золото
      case 2:
        return const Color(0xFF9CA3AF); // серебро
      case 3:
        return const Color(0xFFCD7C32); // бронза
      default:
        return const Color(0xFF6B7280);
    }
  }
}
