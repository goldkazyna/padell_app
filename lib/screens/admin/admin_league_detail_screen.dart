import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/league.dart';
import '../../services/admin_league_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/flex_standings_table.dart';
import '../../widgets/player_avatar.dart';
import 'admin_tournament_detail_screen.dart';

/// Лига в админке: таблица, этапы и состав — всё с телефона.
class AdminLeagueDetailScreen extends StatefulWidget {
  final int leagueId;

  const AdminLeagueDetailScreen({super.key, required this.leagueId});

  @override
  State<AdminLeagueDetailScreen> createState() => _AdminLeagueDetailScreenState();
}

class _AdminLeagueDetailScreenState extends State<AdminLeagueDetailScreen> {
  League? _league;
  bool _loading = true;
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
      final league = await context.read<AdminLeagueService>().details(widget.leagueId);

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

  Future<void> _addStage() async {
    final league = _league;
    if (league == null) return;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddStageSheet(
        league: league,
        onCreated: (tournamentId) async {
          Navigator.pop(context, true);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminTournamentDetailScreen(
                tournamentId: tournamentId,
                tournamentName: league.name,
              ),
            ),
          );
        },
      ),
    );

    if (created == true) _load();
  }

  Future<void> _addPlayer() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPlayerSheet(leagueId: widget.leagueId),
    );

    if (added == true) _load();
  }

  /// Удалить этап можно, только пока он не сыгран: очки завершённого этапа
  /// уже стоят в таблице лиги.
  Future<void> _removeStage(LeagueStage stage) async {
    final ok = await _confirm(
      title: 'Удалить этап?',
      message: '«${stage.name}» удалится вместе с раундами и матчами. Это нельзя отменить.',
      okText: 'Удалить',
    );
    if (!ok || !mounted) return;

    try {
      await context.read<AdminLeagueService>().removeStage(widget.leagueId, stage.id);
      await _load();
      if (!mounted) return;
      await showAppAlert(context, 'Этап удалён');
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String okText,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title,
            style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(message,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(okText, style: const TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    return res == true;
  }

  Future<void> _removePlayer(LeagueMember member) async {
    try {
      await context.read<AdminLeagueService>().removePlayer(widget.leagueId, member.userId);
      await _load();
      if (!mounted) return;
      await showAppAlert(context, '${member.name} убран из состава');
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
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
      floatingActionButton: league == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _tab == 2 ? _addPlayer : _addStage,
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              icon: Icon(_tab == 2 ? Icons.person_add_alt : Icons.add),
              label: Text(
                _tab == 2 ? 'Игрок' : 'Этап',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Не удалось загрузить лигу',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      TextButton(onPressed: _load, child: const Text('Повторить')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.accent,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    children: [
                      _buildSummary(league!),
                      const SizedBox(height: 14),
                      _buildTabs(),
                      const SizedBox(height: 12),
                      if (_tab == 0) ..._buildStandings(league),
                      if (_tab == 1) ..._buildStages(league),
                      if (_tab == 2) ..._buildPlayers(league),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummary(League league) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  league.statusName,
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${league.players} в составе',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          Text(
            'Этапов сыграно: ${league.stagesDone} из ${league.stagesTotal}',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['Таблица', 'Этапы', 'Состав'];

    return Row(
      children: List.generate(labels.length, (i) {
        final active = _tab == i;
        return Padding(
          padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
          child: GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
      return [_empty('Таблица появится, когда завершится первый этап')];
    }

    return [
      // Карточка ровно как таблица лидеров в этапе: заголовок, рамка,
      // внутри — горизонтальный скролл, снизу легенда. Отличает лигу
      // только колонка «Э» — сколько этапов игрок сыграл.
      (Container(
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
                currentUserId: null,
                nameMinWidth: 112,
                extraColumn: ('Э', 'этапов сыграно', (row) => '${row['stages'] ?? 0}'),
              ),
            ),
          ],
        ),
      )),
      const SizedBox(height: 10),
      Text(
        'Места — по сумме очков за все этапы; при равенстве выше процент побед, '
        'затем личные встречи.',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
      ),
    ];
  }

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
  };
  List<Widget> _buildStages(League league) {
    if (league.stages.isEmpty) {
      return [_empty('Этапов ещё нет. Добавьте первый — состав лиги запишется сам')];
    }

    return [
      for (final stage in league.stages) ...[
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminTournamentDetailScreen(
                  tournamentId: stage.id,
                  tournamentName: stage.name,
                ),
              ),
            );
            _load();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: stage.isFinished
                        ? AppTheme.accent.withValues(alpha: 0.14)
                        : const Color(0xFF2A3330),
                    shape: BoxShape.circle,
                  ),
                  child: Text('${stage.stage}',
                      style: TextStyle(
                        color: stage.isFinished ? AppTheme.accent : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stage.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600)),
                      Text(
                        [
                          if (stage.startDate != null)
                            DateFormat('d MMM, HH:mm', 'ru').format(stage.startDate!),
                          stage.statusName,
                          '${stage.participants}${stage.maxParticipants != null ? '/${stage.maxParticipants}' : ''}',
                        ].join(' · '),
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!stage.isFinished)
                  IconButton(
                    onPressed: () => _removeStage(stage),
                    icon: Icon(Icons.delete_outline, size: 19, color: AppTheme.textSecondary),
                  )
                else
                  Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildPlayers(League league) {
    if (league.roster.isEmpty) {
      return [_empty('Состав пуст. Добавьте игроков — они попадут во все этапы')];
    }

    return [
      for (final member in league.roster)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
          ),
          child: Opacity(
            opacity: member.isActive ? 1 : 0.45,
            child: Row(
              children: [
                PlayerAvatar(name: member.name, avatarUrl: member.avatar, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600)),
                      Text(
                        [
                          if (member.level != null) 'L${member.level!.toStringAsFixed(2)}',
                          '${member.rating}',
                          if (!member.isActive) 'выбыл',
                        ].join(' · '),
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (member.isActive)
                  IconButton(
                    onPressed: () => _removePlayer(member),
                    icon: Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _empty(String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5)),
        ),
      );
}

/// Добавление этапа: дата, мест, кортов.
class _AddStageSheet extends StatefulWidget {
  final League league;
  final Future<void> Function(int tournamentId) onCreated;

  const _AddStageSheet({required this.league, required this.onCreated});

  @override
  State<_AddStageSheet> createState() => _AddStageSheetState();
}

class _AddStageSheetState extends State<_AddStageSheet> {
  final _name = TextEditingController();
  late final TextEditingController _players =
      TextEditingController(text: '${widget.league.maxPlayers ?? 12}');
  late final TextEditingController _courts =
      TextEditingController(text: '${widget.league.courtsCount}');
  DateTime? _when;
  bool _saving = false;

  /// По умолчанию — как в лиге, но конкретный вечер можно сыграть иначе.
  late bool _paired = widget.league.isPaired;

  @override
  void dispose() {
    _name.dispose();
    _players.dispose();
    _courts.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_when == null) {
      await showAppAlert(context, 'Выберите дату и время этапа');
      return;
    }

    setState(() => _saving = true);
    try {
      final id = await context.read<AdminLeagueService>().addStage(
            widget.league.id,
            startDate: _when!,
            maxParticipants: int.tryParse(_players.text.trim()) ?? 12,
            name: _name.text.trim(),
            courtsCount: int.tryParse(_courts.text.trim()),
            isPaired: _paired,
          );
      if (!mounted) return;
      await widget.onCreated(id);
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextStage = widget.league.stagesDone + 1;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3330),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Новый этап',
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Создастся турнир Americano Flex, состав лиги запишется в него сразу.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 16),
            _input(_name, 'Название', hint: '${widget.league.name} — этап $nextStage'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickWhen,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _when == null
                          ? 'Дата и время'
                          : DateFormat('d MMMM, HH:mm', 'ru').format(_when!),
                      style: TextStyle(
                        color: _when == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _input(_players, 'Мест', number: true)),
                const SizedBox(width: 10),
                Expanded(child: _input(_courts, 'Кортов', number: true)),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _paired = !_paired),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCheckbox(checked: _paired),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Парный этап',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          'Фиксированные пары, партнёр не меняется весь вечер. Пары собирает админ.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Создать этап',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label,
      {String? hint, bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13),
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Добавление игрока в состав: поиск умный, как везде.
class _AddPlayerSheet extends StatefulWidget {
  final int leagueId;

  const _AddPlayerSheet({required this.leagueId});

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() => _results = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() => _searching = true);
    try {
      final players = await context.read<AdminLeagueService>().searchPlayers(widget.leagueId, q);
      if (!mounted) return;
      setState(() {
        _results = players;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _searching = false);
    }
  }

  Future<void> _add(Map<String, dynamic> player) async {
    try {
      await context.read<AdminLeagueService>().addPlayer(widget.leagueId, player['id'] as int);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3330),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Добавить в лигу',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Имя или телефон',
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_searching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final player = _results[i];
                    return GestureDetector(
                      onTap: () => _add(player),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            PlayerAvatar(
                              name: player['name'] as String? ?? '',
                              avatarUrl: player['avatar'] as String?,
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(player['name'] as String? ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    '${player['phone'] ?? ''}',
                                    style:
                                        TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle_outline,
                                color: AppTheme.accent, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
