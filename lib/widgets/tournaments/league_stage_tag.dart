import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/league.dart';
import '../../theme/app_theme.dart';

/// Метка «Лига · Этап 3» в строке турнира.
///
/// Этап лиги — обычный турнир, и в общем списке он ничем не отличался от
/// остальных: человек записывался в лигу, не понимая этого. Золотым, а не
/// зелёным: зелёный в списке уже занят временем начала.
class LeagueStageTag extends StatelessWidget {
  final TournamentLeagueRef league;

  /// Компактный вид для узкой строки: только «Лига · 3».
  final bool short;

  const LeagueStageTag({super.key, required this.league, this.short = false});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final text = short
        ? '${l.leagueTagShort} ${league.stage}'
        : l.leagueStageTag(league.stage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.4)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppTheme.amber,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          height: 1.25,
        ),
      ),
    );
  }
}
