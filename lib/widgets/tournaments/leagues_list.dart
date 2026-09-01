import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/league.dart';
import '../../screens/league_detail_screen.dart';
import '../../services/league_service.dart';
import '../../theme/app_theme.dart';
import 'league_card.dart';

/// Список лиг — содержимое раздела «Лиги».
///
/// Раньше лиги висели полосой над турнирами, и лига читалась как турнир,
/// хотя записываются в неё один раз на всю серию. Теперь это отдельный
/// раздел: и на экране турниров под переключателем, и как самостоятельный
/// экран с главной.
class LeaguesList extends StatefulWidget {
  const LeaguesList({super.key});

  @override
  State<LeaguesList> createState() => _LeaguesListState();
}

class _LeaguesListState extends State<LeaguesList> {
  List<League> _leagues = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_loading) setState(() => _loading = true);

    try {
      final leagues = await context.read<LeagueService>().list();
      if (!mounted) return;
      setState(() {
        _leagues = leagues;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.error, style: TextStyle(color: AppTheme.textSecondary)),
            TextButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    // Пустой список всё равно прокручиваем: иначе «потяните, чтобы
    // обновить» не работает там, где оно нужнее всего.
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: _leagues.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                _empty(l10n),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
              itemCount: _leagues.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => LeagueCard(
                league: _leagues[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeagueDetailScreen(leagueId: _leagues[i].id),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _empty(AppLocalizations l10n) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 42, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Text(
              l10n.leaguesEmpty,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.5),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.leaguesEmptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
}
