import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/league.dart';
import '../providers/home_provider.dart';
import '../services/league_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../utils/tournament_navigation.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/club_logo.dart';
import '../widgets/flex_standings_table.dart';
import '../widgets/profile/medal.dart';
import 'tournament_detail_screen.dart';

/// Экран лиги: сводная таблица, этапы, запись.
///
/// Этап открывается обычным экраном турнира — лига ничего в его проведении
/// не меняет.
class LeagueDetailScreen extends StatefulWidget {
  final int leagueId;

  const LeagueDetailScreen({super.key, required this.leagueId});

  @override
  State<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<LeagueDetailScreen> {
  League? _league;
  bool _loading = true;
  bool _acting = false;
  String? _error;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final league = await context.read<LeagueService>().details(widget.leagueId);
      if (!mounted) return;
      setState(() {
        _league = league;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleRegistration() async {
    final league = _league;
    if (league == null) return;

    setState(() => _acting = true);
    try {
      final service = context.read<LeagueService>();
      if (league.isRegistered) {
        await service.cancel(league.id);
      } else {
        await service.register(league.id);
      }
      await _load();
      if (!mounted) return;
      await showAppAlert(
        context,
        league.isRegistered ? 'Запись отменена' : 'Вы записаны в лигу',
      );
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final league = _league;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: AppBackButton(),
        ),
        centerTitle: true,
        title: Text(
          league?.name ?? 'Лига',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.accent,
                  // Отступы у блоков, а не у списка: таблице нужна вся
                  // ширина — иначе имена в ней стоят слишком тесно.
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
                    children: [
                      _side(_buildHeader(league!)),
                      const SizedBox(height: 16),
                      _side(_buildTabs()),
                      const SizedBox(height: 12),
                      if (_tab == 0) ..._buildStandings(league),
                      if (_tab == 1) ..._buildStages(league).map(_side),
                    ],
                  ),
                ),
      bottomNavigationBar: (league != null && (league.canRegister || league.isRegistered))
          ? _buildBottomBar(league)
          : null,
    );
  }

  /// Боковой отступ блока: у списка его нет, чтобы таблица шла во всю ширину.
  Widget _side(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: child);

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Не удалось загрузить лигу',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 6),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );

  Widget _buildHeader(League league) {
    final dates = _period(league);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Логотип клуба — как в карточке лиги в списке турниров.
              ClubLogoTile(
                url: league.clubLogo,
                name: league.clubName ?? 'Лига',
                size: 44,
                radius: 11,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [league.clubName, league.clubCity]
                          .whereType<String>()
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      league.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    if (league.formatName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              league.formatName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                // Тот же синий, что у формата в карточке турнира.
                                color: Color(0xFF3B82F6),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if ((league.price ?? 0) > 0) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text('·',
                                  style: TextStyle(color: AppTheme.textDim, fontSize: 12.5)),
                            ),
                            Text(
                              '${league.price} ₸',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  league.statusName,
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (dates != null) ...[
            const SizedBox(height: 8),
            Text(dates, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
          if ((league.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(league.description!,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: league.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF2A3330),
              valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Этапов сыграно: ${league.stagesDone} из ${league.stagesTotal}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
              ),
              const Spacer(),
              Text(
                '${league.players} ${_playersWord(league.players)}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
          if (league.myPlace != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: AppTheme.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ваше место в лиге: ${league.myPlace}',
                    style: const TextStyle(
                        color: AppTheme.accent, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['Таблица', 'Этапы'];

    return Row(
      children: List.generate(labels.length, (i) {
        final active = _tab == i;
        return Padding(
          padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
          child: GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppTheme.accent.withValues(alpha: 0.14) : AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active
                      ? AppTheme.accent.withValues(alpha: 0.35)
                      : const Color(0xFF2A3330),
                  width: 0.5,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: active ? AppTheme.accent : AppTheme.textSecondary,
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildStandings(League league) {
    if (league.standings.isEmpty) {
      return [
        _side(_emptyCard('Таблица появится, когда завершится первый этап')),
      ];
    }

    return [
      // Карточка ровно как таблица лидеров в этапе: заголовок, рамка,
      // внутри — горизонтальный скролл, снизу легенда. Отличает лигу
      // только колонка «Э» — сколько этапов игрок сыграл.
      _side(Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A3330)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: AppTheme.amber, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Таблица лидеров',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: FlexStandingsTable(
                leaderboard: league.standings.map(_toRow).toList(),
                currentUserId: context.read<HomeProvider>().user?.id,
                nameMinWidth: 112,
                extraColumn: ('Э', 'этапов сыграно', (row) => '${row['stages'] ?? 0}'),
              ),
            ),
          ],
        ),
      )),
      const SizedBox(height: 10),
      _side(Text(
        'Места — по сумме очков за все этапы. При равенстве выше тот, у кого '
        'больше процент побед, затем — личные встречи.',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
      )),
    ];
  }

  /// Строка лиги в формате общей таблицы Flex.
  Map<String, dynamic> _toRow(LeagueStandingRow row) => {
    'position': row.position,
    'id': row.userId,
    'name': row.name,
    'avatar': row.avatar,
    'wins': row.wins,
    'losses': row.losses,
    'draws': row.draws,
    'points_for': row.pointsFor,
    'points_against': row.pointsAgainst,
    'matches_played': row.wins + row.losses + row.draws,
    'stages': row.stages,
    'verified': row.verified,
    'is_me': row.isMe,
  };
  List<Widget> _buildStages(League league) {
    if (league.stages.isEmpty) {
      return [_emptyCard('Этапы ещё не назначены')];
    }

    return [
      for (final stage in league.stages) ...[
        _stageCard(stage),
        const SizedBox(height: 8),
      ],
    ];
  }

  Widget _stageCard(LeagueStage stage) {
    final date = stage.startDate;

    return GestureDetector(
      // Сыгранный этап открываем как турнир из истории: таблица, раунды и
      // разбор AI. Несыгранный — обычными деталями с записью и составом.
      onTap: () => stage.isFinished
          ? openTournamentLiveByType(
              context,
              tournamentId: stage.id,
              tournamentType: 'americano_flex',
            )
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TournamentDetailScreen(tournamentId: stage.id),
              ),
            ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: stage.isFinished
                    ? AppTheme.accent.withValues(alpha: 0.14)
                    : const Color(0xFF2A3330),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              // Как в истории турниров: 1–3 медаль, дальше номер места.
              // Номер этапа сюда не ставим — его читали как место.
              child: stage.myPlace == null
                  ? Icon(
                      Icons.emoji_events_outlined,
                      size: 17,
                      color: AppTheme.textSecondary,
                    )
                  : stage.myPlace! <= 3
                      ? Medal(place: stage.myPlace!, size: 24)
                      : Text(
                          '${stage.myPlace}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      'этап ${stage.stage}',
                      if (date != null) DateFormat('d MMM, HH:mm', 'ru').format(date),
                      stage.statusName,
                      if (stage.myPlace != null) 'моё место ${stage.myPlace}',
                      if (stage.myPoints != null) '${stage.myPoints} очк.',
                      if (stage.myPlace == null)
                        '${stage.participants}${stage.maxParticipants != null ? '/${stage.maxParticipants}' : ''}',
                    ].join(' · '),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
          ),
        ),
      );

  Widget _buildBottomBar(League league) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _acting ? null : _toggleRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  league.isRegistered ? AppTheme.card : AppTheme.accent,
              foregroundColor: league.isRegistered ? AppTheme.textSecondary : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _acting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                  )
                : Text(
                    league.isRegistered ? 'Отменить запись в лигу' : 'Записаться в лигу',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }

  String? _period(League league) {
    final start = league.startDate;
    if (start == null) return null;

    final from = DateFormat('d MMMM', 'ru').format(start);
    final end = league.endDate;
    if (end == null) return 'Старт $from';

    return '$from — ${DateFormat('d MMMM y', 'ru').format(end)}';
  }

  String _playersWord(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'участник';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'участника';
    return 'участников';
  }
}
