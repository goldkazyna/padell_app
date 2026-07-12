import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';
import '../utils/tournament_navigation.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/tournament_row_v2.dart';

/// Прошедшие (завершённые) турниры конкретного клуба/сообщества.
/// Список — как во вкладке «Архив». Тап по турниру открывает таблицу и
/// матчи (Live-экран по типу турнира), как в истории профиля.
class ClubPastTournamentsScreen extends StatefulWidget {
  final int clubId;
  final String clubName;

  const ClubPastTournamentsScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<ClubPastTournamentsScreen> createState() =>
      _ClubPastTournamentsScreenState();
}

class _ClubPastTournamentsScreenState extends State<ClubPastTournamentsScreen> {
  bool _loading = true;
  List<Tournament> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await context
        .read<TournamentProvider>()
        .fetchClubPastTournaments(widget.clubId);
    if (!mounted) return;
    setState(() {
      _tournaments = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Прошедшие турниры',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.clubName,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }
    if (_tournaments.isEmpty) {
      return Center(
        child: Text(
          'Здесь пока нет прошедших турниров',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _tournaments.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: i == _tournaments.length - 1
                              ? Colors.transparent
                              : AppTheme.divider,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: TournamentRowV2(
                      tournament: _tournaments[i],
                      userLevel: null,
                      showStatusChip: false,
                      onTap: () =>
                          openTournamentLive(context, _tournaments[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
