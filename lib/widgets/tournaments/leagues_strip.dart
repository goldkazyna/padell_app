import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/league.dart';
import '../../screens/league_detail_screen.dart';
import '../../services/league_service.dart';
import '../../theme/app_theme.dart';
import 'league_card.dart';

/// Секция «Лиги» над списком турниров.
///
/// Оформлена как секции турниров: заголовок со счётчиком и карточки в
/// столбик той же ширины. Лига — не турнир: записываются в неё один раз на
/// всю серию, поэтому она стоит отдельным блоком, а карточка помечена
/// словом «ЛИГА» и шкалой этапов вместо шкалы мест.
class LeaguesStrip extends StatefulWidget {
  const LeaguesStrip({super.key});

  @override
  State<LeaguesStrip> createState() => _LeaguesStripState();
}

class _LeaguesStripState extends State<LeaguesStrip> {
  late Future<List<League>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<LeagueService>().list();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<League>>(
      future: _future,
      builder: (context, snapshot) {
        final leagues = snapshot.data ?? const <League>[];
        // Ни ошибок, ни спиннера: лиги — дополнение к списку турниров, и
        // пустой блок не должен мешать основному экрану.
        if (leagues.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(leagues.length),
            for (final league in leagues)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: LeagueCard(
                  league: league,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeagueDetailScreen(leagueId: league.id),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Заголовок секции — как «Для вас» и «Остальные турниры».
  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Text(
            'Лиги',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'серия турниров',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
