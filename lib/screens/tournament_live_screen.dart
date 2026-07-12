import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/rating_formatter.dart';
import '../widgets/app_back_button.dart';
import '../widgets/verified_badge.dart';
import 'player_profile_screen.dart';

/// Экран «Идёт сейчас» — детализация активного турнира (только Американо).
/// Группы → таблица лидеров + раунды + матчи. Только чтение.
class TournamentLiveScreen extends StatefulWidget {
  final int tournamentId;

  /// Кого подсвечивать вместо текущего пользователя (при открытии из чужого
  /// профиля). null → подсвечивается авторизованный пользователь.
  final int? highlightPlayerId;

  const TournamentLiveScreen({
    super.key,
    required this.tournamentId,
    this.highlightPlayerId,
  });

  @override
  State<TournamentLiveScreen> createState() => _TournamentLiveScreenState();
}

enum _LiveTab { rounds, table }

final _hdrStyle = TextStyle(
  color: AppTheme.textDim,
  fontSize: 10,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
);

class _TournamentLiveScreenState extends State<TournamentLiveScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  int _selectedGroupIdx = 0;
  _LiveTab _activeTab = _LiveTab.rounds;
  // round_id => isExpanded
  final Map<int, bool> _roundExpanded = {};
  // (group_id) => уже инициализировано (раскрыли «текущий» раунд)
  final Set<int> _initializedGroups = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      // Сбрасываем кэш раскрытия — после новой загрузки данных
      // снова раскроется текущий in_progress раунд (а не старый).
      _initializedGroups.clear();
      _roundExpanded.clear();
    });
    try {
      final token = await StorageService().getToken();
      final q = widget.highlightPlayerId != null
          ? '?player_id=${widget.highlightPlayerId}'
          : '';
      final response = await ApiService()
          .get('/tournaments/${widget.tournamentId}/live$q', token);
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          _data = response;
          _loading = false;
        });
      } else {
        setState(() {
          _error = (response['message'] as String?) ?? 'Ошибка загрузки';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ошибка сети: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Ограничиваем системный масштаб шрифта на этом экране — таблица
    // плотная и при scale > 1.15 верстка ломается.
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(maxScaleFactor: 1.15),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final tournament = _data!['tournament'] as Map<String, dynamic>;
    final groups = (_data!['groups'] as List).cast<Map<String, dynamic>>();
    final playoff = (_data!['playoff'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    if (_selectedGroupIdx >= groups.length) _selectedGroupIdx = 0;
    final group = groups.isNotEmpty ? groups[_selectedGroupIdx] : null;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          _buildHeader(tournament),
          _buildMainTabs(),
          if (groups.length > 1) _buildGroupTabs(groups),
          if (group != null) ...[
            if (_activeTab == _LiveTab.rounds)
              _buildRounds(group)
            else
              _buildLeaderboard(group),
          ],
          if (playoff.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPlayoffSection(playoff),
          ],
        ],
      ),
    );
  }

  // ===== Playoff =====
  Widget _buildPlayoffSection(List<Map<String, dynamic>> playoff) {
    // Делим стадии на основную и нижнюю сетки по суффиксу "(нижняя сетка)".
    final upper = <Map<String, dynamic>>[];
    final lower = <Map<String, dynamic>>[];
    for (final stage in playoff) {
      final name = (stage['stage'] as String?) ?? '';
      if (name.contains('нижняя сетка')) {
        lower.add(stage);
      } else {
        upper.add(stage);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: AppTheme.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Плей-офф',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        if (upper.isNotEmpty) _buildBracketCard(upper, isLower: false),
        if (lower.isNotEmpty) _buildBracketCard(lower, isLower: true),
      ],
    );
  }

  /// Карточка сетки (основная/нижняя) с вертикальным таймлайном стадий.
  Widget _buildBracketCard(List<Map<String, dynamic>> stages,
      {required bool isLower}) {
    int rank(Map<String, dynamic> s) {
      final base = ((s['stage'] as String?) ?? '')
          .replaceAll(' (нижняя сетка)', '')
          .trim();
      if (base == 'Полуфинал') return 1;
      if (base == 'Финал') return 2;
      return 3; // Матч за 3-е место / За 3-е место
    }

    final ordered = [...stages]..sort((a, b) => rank(a).compareTo(rank(b)));

    int total = 0, played = 0;
    for (final s in ordered) {
      for (final m in (s['matches'] as List)) {
        total++;
        if ((m as Map)['status'] == 'completed') played++;
      }
    }

    final title = isLower ? 'Нижняя сетка' : 'Основная сетка';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withAlpha(36),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.emoji_events_rounded,
                      color: AppTheme.amber, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ),
                Text('$played / $total',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final s in ordered) _buildStageBlock(s, isLower: isLower),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBlock(Map<String, dynamic> stage, {required bool isLower}) {
    final base = ((stage['stage'] as String?) ?? '')
        .replaceAll(' (нижняя сетка)', '')
        .trim();
    final matches = (stage['matches'] as List).cast<Map<String, dynamic>>();

    String label;
    String? sub;
    if (base == 'Полуфинал') {
      label = 'ПОЛУФИНАЛ';
    } else if (base == 'Финал') {
      label = 'ФИНАЛ';
      sub = isLower ? null : 'за 1–2 место';
    } else {
      label = 'МАТЧ ЗА 3 МЕСТО';
      sub = isLower ? null : 'за 3 место';
    }

    final allDone = matches.isNotEmpty &&
        matches.every((m) => m['status'] == 'completed');
    final Color dotColor =
        allDone ? AppTheme.accent : const Color(0xFF3F3F46);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              if (sub != null) ...[
                const SizedBox(width: 6),
                Text('· $sub',
                    style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
        for (final m in matches) _buildPlayoffMatchCard(m),
      ],
    );
  }

  Widget _buildPlayoffMatchCard(Map<String, dynamic> m) {
    final completed = m['status'] == 'completed';
    final t1 = m['team1'] as Map<String, dynamic>;
    final t2 = m['team2'] as Map<String, dynamic>;
    final score1 = t1['score'];
    final score2 = t2['score'];
    final hasMe = m['has_me'] == true;
    final myDelta = (m['my_rating_change'] as num?)?.toInt();
    final t1Win = completed && (score1 ?? 0) > (score2 ?? 0);
    final t2Win = completed && (score2 ?? 0) > (score1 ?? 0);

    final cardBg = hasMe
        ? AppTheme.accent.withAlpha(18)
        : AppTheme.cardRaised.withAlpha(90);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (completed)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasMe && myDelta != null) ...[
                    _MatchRatingPill(delta: myDelta),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.check_rounded,
                      color: AppTheme.accent, size: 14),
                  const SizedBox(width: 3),
                  const Text('Завершён',
                      style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            )
          else
            const SizedBox(height: 10),
          _playoffTeamRow(t1,
              isWinner: t1Win, completed: completed, score: score1),
          _playoffTeamRow(t2,
              isWinner: t2Win, completed: completed, score: score2),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _playoffTeamRow(Map<String, dynamic> team,
      {required bool isWinner, required bool completed, dynamic score}) {
    final p1 = team['player1'] as Map<String, dynamic>?;
    final p2 = team['player2'] as Map<String, dynamic>?;
    final names =
        [p1?['name'], p2?['name']].where((e) => e != null).join(' / ');
    final isLoser = completed && !isWinner;
    final noTeam = p1 == null && p2 == null;

    Color nameColor =
        isLoser ? AppTheme.textSecondary : AppTheme.textPrimary;
    if (noTeam) nameColor = AppTheme.textDim;
    final nameWeight = isWinner ? FontWeight.w800 : FontWeight.w600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        children: [
          if (isWinner)
            Container(
              width: 3,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(width: 11),
          Expanded(
            child: Text(
              names.isEmpty ? 'Ожидание…' : names,
              style: TextStyle(
                  color: nameColor, fontSize: 14, fontWeight: nameWeight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _playoffScoreBox(score, isWinner: isWinner, completed: completed),
        ],
      ),
    );
  }

  Widget _playoffScoreBox(dynamic score,
      {required bool isWinner, required bool completed}) {
    final hasScore = score != null;

    Color bg;
    Color fg;
    Border border;
    String text = hasScore ? '$score' : '—';

    if (completed && isWinner) {
      bg = AppTheme.accent.withAlpha(40);
      fg = AppTheme.accent;
      border = Border.all(color: AppTheme.accent.withAlpha(130));
    } else if (completed) {
      bg = Colors.transparent;
      fg = AppTheme.textSecondary;
      border = Border.all(color: const Color(0xFF3F3F46));
    } else {
      bg = Colors.transparent;
      fg = AppTheme.textDim;
      border = Border.all(color: const Color(0xFF3F3F46));
      text = '—';
    }

    return Container(
      width: 46,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w800)),
    );
  }

  // ===== Main tabs (Раунды / Таблица) — стиль рейтинга, на всю ширину =====
  Widget _buildMainTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF27272A), width: 1),
          ),
        ),
        child: Row(
          children: [
            for (final tab in _LiveTab.values)
              Expanded(child: _liveTabBtn(tab)),
          ],
        ),
      ),
    );
  }

  Widget _liveTabBtn(_LiveTab tab) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          tab == _LiveTab.rounds ? 'Раунды' : 'Таблица',
          style: TextStyle(
            color: isActive ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ===== Header =====
  Widget _buildHeader(Map<String, dynamic> t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 12),
              if (t['status'] == 'completed')
                _DatePill(date: t['date'] as String? ?? '')
              else
                const _LivePill(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            t['name'] as String? ?? '',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                t['club_name'] as String? ?? '',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('·',
                    style: TextStyle(
                        color: AppTheme.textDim, fontSize: 13)),
              ),
              Text(
                t['format_name'] as String? ?? '',
                style: TextStyle(
                    color: AppTheme.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Group tabs (pill-кнопки, чтобы не сливались с главными табами) =====
  Widget _buildGroupTabs(List<Map<String, dynamic>> groups) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _groupTabBtn(groups[i]['name'] as String?, i)),
          ],
        ],
      ),
    );
  }

  Widget _groupTabBtn(String? label, int idx) {
    final isActive = _selectedGroupIdx == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedGroupIdx = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent : const Color(0xFF1F1F23),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isActive ? AppTheme.accent : const Color(0xFF2A2A2F),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label ?? 'Группа ${idx + 1}',
          style: TextStyle(
            color: isActive ? Colors.black : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  // ===== Leaderboard =====
  Widget _buildLeaderboard(Map<String, dynamic> group) {
    // Для Americano Flex ранжирование идёт по среднему за матч (очки ÷ игры),
    // т.к. у игроков разное число игр из-за отдыхов. Поэтому показываем
    // таблицу как в админке: Матчи / Отдыхи / Среднее / Очки.
    final format = (_data?['tournament'] as Map?)?['format'] as String?;
    if (format == 'americano_flex') {
      return _buildFlexLeaderboard(group);
    }
    final lb = (group['leaderboard'] as List).cast<Map<String, dynamic>>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    color: AppTheme.amber, size: 16),
                SizedBox(width: 8),
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
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(), // #
                1: IntrinsicColumnWidth(), // avatar
                2: FlexColumnWidth(),       // name (растягивается, wrap при нужде)
                3: IntrinsicColumnWidth(), // В
                4: IntrinsicColumnWidth(), // П
                5: IntrinsicColumnWidth(), // З
                6: IntrinsicColumnWidth(), // РП
                7: IntrinsicColumnWidth(), // %
                8: IntrinsicColumnWidth(), // Очки
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _buildHeaderRow(),
                for (final p in lb) _buildLeaderboardTableRow(p),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    Widget hdr(String text, {bool center = true}) => Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Text(
            text,
            textAlign: center ? TextAlign.center : TextAlign.left,
            style: _hdrStyle,
          ),
        );
    return TableRow(
      children: [
        hdr('#', center: false),
        const SizedBox(),
        hdr('Игрок', center: false),
        hdr('В'),
        hdr('П'),
        hdr('З'),
        hdr('РП'),
        hdr('%'),
        hdr('Очки'),
      ],
    );
  }

  TableRow _buildLeaderboardTableRow(Map<String, dynamic> p) {
    final position = (p['position'] as num).toInt();
    final isMe = p['is_me'] == true;
    Color rankColor = AppTheme.textDim;
    if (position == 1) rankColor = const Color(0xFFFFD700);
    if (position == 2) rankColor = const Color(0xFFC0C0C0);
    if (position == 3) rankColor = const Color(0xFFCD7F32);
    final pointDiff = (p['point_diff'] as num).toInt();
    final draws = (p['draws'] as num?)?.toInt() ?? 0;
    // % забитых мячей от всех мячей (как в админке)
    final ballPercent = (p['ball_percent'] as num?)?.toInt() ?? 0;
    final playerId = p['id'] is num ? (p['id'] as num).toInt() : null;
    final playerName = p['name'] as String?;

    Widget cell(Widget child, {EdgeInsets? padding, AlignmentGeometry alignment = Alignment.center}) {
      return InkWell(
        onTap: () => _openPlayer(playerId, playerName),
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(6, 8, 6, 8),
          alignment: alignment,
          child: child,
        ),
      );
    }

    return TableRow(
      // Подсветка строки моего профиля — на всю высоту строки одновременно,
      // чтобы при переносе имени на 2 строки остальные ячейки тоже были подсвечены.
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(20) : null,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      children: [
        // #
        cell(
          Text(
            '$position',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(2, 8, 6, 8),
          alignment: Alignment.centerLeft,
        ),
        // Avatar
        cell(
          _Avatar(
            url: p['avatar'] as String?,
            name: p['name'] as String? ?? '',
            size: 24,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        // Name (растягивается, может перенестись) + галочка верификации
        cell(
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  playerName ?? '—',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                    fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
              if (p['verified'] == true) ...[
                const SizedBox(width: 5),
                VerifiedBadge(
                  size: 12,
                  userId: playerId,
                  playerName: playerName,
                ),
              ],
            ],
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          alignment: Alignment.centerLeft,
        ),
        // В
        cell(Text('${p['wins']}',
            style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700))),
        // П
        cell(Text('${p['losses']}',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600))),
        // З
        cell(Text('$draws',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600))),
        // РП
        cell(Text(
          pointDiff > 0 ? '+$pointDiff' : '$pointDiff',
          style: TextStyle(
            color: pointDiff > 0
                ? AppTheme.accent
                : (pointDiff < 0
                    ? AppTheme.error
                    : AppTheme.textSecondary),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        )),
        // % (забитых мячей от всех мячей)
        cell(Text('$ballPercent',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600))),
        // Очки
        cell(Text(
          '${p['total_points']}',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        )),
      ],
    );
  }

  // ===== Flex leaderboard (как в админке: М / ОТД / СРЕД / Очки) =====
  Widget _buildFlexLeaderboard(Map<String, dynamic> group) {
    final lb = (group['leaderboard'] as List).cast<Map<String, dynamic>>();
    final totalRounds = (group['rounds'] as List?)?.length ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    color: AppTheme.amber, size: 16),
                SizedBox(width: 8),
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
          // Горизонтальный скролл: на узких/крупномасштабных экранах таблица
          // не сжимается, а скроллится вбок. Имя — фикс. ширина.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: c.maxWidth),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(), // #
                      1: IntrinsicColumnWidth(), // avatar
                      2: IntrinsicColumnWidth(), // name (фикс. по содержимому)
                      3: IntrinsicColumnWidth(), // В
                      4: IntrinsicColumnWidth(), // П
                      5: IntrinsicColumnWidth(), // З
                      6: IntrinsicColumnWidth(), // Пр
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _buildFlexHeaderRow(),
                      for (final p in lb)
                        _buildFlexLeaderboardTableRow(p, totalRounds),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  TableRow _buildFlexHeaderRow() {
    Widget hdr(String text,
            {AlignmentGeometry alignment = Alignment.center,
            EdgeInsets? padding}) =>
        Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Align(
            alignment: alignment,
            child: Text(text, style: _hdrStyle),
          ),
        );
    return TableRow(
      children: [
        hdr('#',
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(2, 8, 6, 6)),
        const SizedBox(),
        hdr('Игрок', alignment: Alignment.centerLeft),
        hdr('В'),
        hdr('П'),
        hdr('З'),
        hdr('Пр'),
      ],
    );
  }

  TableRow _buildFlexLeaderboardTableRow(
      Map<String, dynamic> p, int totalRounds) {
    final position = (p['position'] as num).toInt();
    final isMe = p['is_me'] == true;
    Color rankColor = AppTheme.textDim;
    if (position == 1) rankColor = const Color(0xFFFFD700);
    if (position == 2) rankColor = const Color(0xFFC0C0C0);
    if (position == 3) rankColor = const Color(0xFFCD7F32);

    final wins = (p['wins'] as num?)?.toInt() ?? 0;
    final losses = (p['losses'] as num?)?.toInt() ?? 0;
    final pointsFor = (p['points_for'] as num?)?.toInt() ?? 0;
    final pointsAgainst = (p['points_against'] as num?)?.toInt() ?? 0;
    final playerId = p['id'] is num ? (p['id'] as num).toInt() : null;
    final playerName = p['name'] as String?;

    Widget cell(Widget child,
        {EdgeInsets? padding,
        AlignmentGeometry alignment = Alignment.center}) {
      return InkWell(
        onTap: () => _openPlayer(playerId, playerName),
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(6, 8, 6, 8),
          alignment: alignment,
          child: child,
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(20) : null,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      children: [
        // #
        cell(
          Text(
            '$position',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(2, 8, 6, 8),
          alignment: Alignment.centerLeft,
        ),
        // Avatar
        cell(
          _Avatar(
            url: p['avatar'] as String?,
            name: p['name'] as String? ?? '',
            size: 24,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        // Name + verified
        cell(
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  playerName ?? '—',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                    fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
              if (p['verified'] == true) ...[
                const SizedBox(width: 5),
                VerifiedBadge(
                  size: 12,
                  userId: playerId,
                  playerName: playerName,
                ),
              ],
            ],
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          alignment: Alignment.centerLeft,
        ),
        // В (победы)
        cell(Text('$wins',
            style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 13,
                fontWeight: FontWeight.w700))),
        // П (поражения)
        cell(Text('$losses',
            style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 13,
                fontWeight: FontWeight.w700))),
        // З (забитые мячи)
        cell(Text('$pointsFor',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600))),
        // Пр (пропущенные мячи)
        cell(
          Text(
            '$pointsAgainst',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 4, 8),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }

  void _openPlayer(int? id, String? name) {
    if (id == null || id <= 0) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(
          playerId: id,
          playerName: name ?? '',
        ),
      ),
    );
  }

  // ===== Rounds =====
  Widget _buildRounds(Map<String, dynamic> group) {
    final rounds = (group['rounds'] as List).cast<Map<String, dynamic>>();
    final groupId = (group['id'] as num).toInt();

    // При первом показе группы — раскрываем «текущий» раунд.
    // Если групповой этап завершён И есть плей-офф → все раунды свёрнуты
    // (внимание уходит на плей-офф снизу).
    if (!_initializedGroups.contains(groupId)) {
      _initializedGroups.add(groupId);
      final hasPlayoff =
          ((_data?['playoff'] as List?)?.isNotEmpty ?? false);
      final allCompleted =
          rounds.isNotEmpty && rounds.every((r) => r['status'] == 'completed');

      int? activeIdx;
      if (!(allCompleted && hasPlayoff)) {
        // 1) ищем раунд со статусом in_progress
        for (var i = 0; i < rounds.length; i++) {
          if (rounds[i]['status'] == 'in_progress') {
            activeIdx = i;
            break;
          }
        }
        // 2) иначе — первый не completed
        if (activeIdx == null) {
          final idx = rounds.indexWhere((r) => r['status'] != 'completed');
          if (idx >= 0) activeIdx = idx;
        }
        // 3) иначе — последний (все завершены и плей-оффа нет)
        activeIdx ??= rounds.isNotEmpty ? rounds.length - 1 : -1;
      }
      // если allCompleted && hasPlayoff — activeIdx останется null → все свёрнуты

      for (var i = 0; i < rounds.length; i++) {
        final rid = (rounds[i]['id'] as num).toInt();
        _roundExpanded[rid] = (activeIdx != null && i == activeIdx);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in rounds) _buildRound(r),
      ],
    );
  }

  Widget _buildRound(Map<String, dynamic> round) {
    final matches = (round['matches'] as List).cast<Map<String, dynamic>>();
    final byes = (round['byes'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final roundId = (round['id'] as num).toInt();
    final completedCount = matches.where((m) => m['status'] == 'completed').length;
    final roundStatus = round['status'] as String? ?? 'pending';
    final inProgress = roundStatus == 'in_progress';
    final allCompleted = roundStatus == 'completed';
    final expanded = _roundExpanded[roundId] ?? false;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inProgress
              ? AppTheme.accent.withAlpha(60)
              : const Color(0xFF2A2A2A),
          width: inProgress ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header — тапабельный, переключает expanded
          InkWell(
            onTap: () => setState(() {
              _roundExpanded[roundId] = !expanded;
            }),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Text(
                    'Раунд ${round['round_number']}',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$completedCount / ${matches.length} матчей',
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (inProgress)
                    _RoundStatusPill(
                      text: 'идёт',
                      color: AppTheme.accent,
                      pulse: true,
                    )
                  else if (allCompleted)
                    _RoundStatusPill(
                      text: 'завершён',
                      color: AppTheme.textDim,
                    )
                  else
                    _RoundStatusPill(
                      text: 'ожидание',
                      color: AppTheme.amber,
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            for (var i = 0; i < matches.length; i++)
              _buildMatch(matches[i], isLast: i == matches.length - 1),
            if (byes.isNotEmpty) _buildByes(byes),
          ],
        ],
      ),
    );
  }

  // Блок «Отдыхают» — игроки, пропускающие раунд (Americano Flex).
  Widget _buildByes(List<Map<String, dynamic>> byes) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bedtime_outlined, color: AppTheme.amber, size: 15),
              SizedBox(width: 6),
              Text(
                'Отдыхают',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in byes)
                GestureDetector(
                  onTap: () => _openPlayer(
                    (b['id'] as num?)?.toInt(),
                    b['name'] as String?,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Text(
                      b['name'] as String? ?? '—',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatch(Map<String, dynamic> m, {required bool isLast}) {
    final t1 = m['team1'] as Map<String, dynamic>;
    final t2 = m['team2'] as Map<String, dynamic>;
    final score1 = t1['score'];
    final score2 = t2['score'];
    final completed = m['status'] == 'completed';
    final hasMe = m['has_me'] == true;
    final court = m['court_number'];
    final myDelta = (m['my_rating_change'] as num?)?.toInt();

    final t1Win = completed && (score1 ?? 0) > (score2 ?? 0);
    final t2Win = completed && (score2 ?? 0) > (score1 ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: hasMe ? AppTheme.accent.withAlpha(20) : null,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Строка-заголовок матча: корт (если есть) + «Вы играете» + дельта.
          // Рисуем если есть хоть один из этих элементов.
          if (court != null || hasMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (court != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.cardRaised,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Text(
                        'Корт $court',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (hasMe) ...[
                    if (court != null) const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(38),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Вы играете',
                        style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  if (hasMe && completed && myDelta != null) ...[
                    const SizedBox(width: 6),
                    _MatchRatingPill(delta: myDelta),
                  ],
                ],
              ),
            ),
          // Team 1 — мини-карточка
          _buildTeamCard(t1, isWinner: t1Win, isCompleted: completed, score: score1),
          const SizedBox(height: 6),
          // Team 2 — мини-карточка
          _buildTeamCard(t2, isWinner: t2Win, isCompleted: completed, score: score2),
        ],
      ),
    );
  }

  /// V3 team-card: аватары рядом + имена + крупный счёт справа.
  /// Зелёная заливка карточки — ТОЛЬКО для команды юзера.
  /// Зелёный счёт — у победителя (любой команды).
  Widget _buildTeamCard(Map<String, dynamic> team,
      {required bool isWinner,
      required bool isCompleted,
      dynamic score}) {
    final p1 = team['player1'] as Map<String, dynamic>?;
    final p2 = team['player2'] as Map<String, dynamic>?;
    final hasMe = team['has_me'] == true;
    final isLoser = isCompleted && !isWinner;
    final isPending = !isCompleted;

    // Стили команды — match-контейнер уже подсвечен зелёным если в нём играет
    // юзер. Здесь различаем только проигравшую команду (приглушённая) от
    // ожидания (рамка-пунктир) и обычной (нейтральный фон).
    final Color bg;
    final Border? border;
    if (isPending) {
      bg = Colors.transparent;
      border = Border.all(color: const Color(0xFF2A2A2A));
    } else if (isLoser) {
      bg = AppTheme.cardRaised.withAlpha(120);
      border = null;
    } else {
      // Победитель или ничья (без подсветки команды — победителя видно по счёту)
      bg = AppTheme.cardRaised.withAlpha(120);
      border = null;
    }

    // Имена — приглушённые у проигравшей команды, обычные у остальных
    final nameColor = isLoser ? AppTheme.textSecondary : AppTheme.textPrimary;
    final nameWeight = isWinner ? FontWeight.w700 : FontWeight.w600;

    // Счёт — зелёный у победителя
    Color scoreBg;
    Color scoreColor;
    if (isWinner) {
      scoreBg = AppTheme.accent;
      scoreColor = const Color(0xFF0A0A0D);
    } else if (isLoser) {
      scoreBg = Colors.transparent;
      scoreColor = AppTheme.textSecondary;
    } else {
      scoreBg = Colors.transparent;
      scoreColor = AppTheme.textDim;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Row(
        children: [
          // Аватары рядом (без наложения)
          GestureDetector(
            onTap: () => _openPlayer(
              p1 != null && p1['id'] is num ? (p1['id'] as num).toInt() : null,
              p1?['name'] as String?,
            ),
            child: _Avatar(
              url: p1?['avatar'] as String?,
              name: p1?['name'] as String? ?? '',
              size: 26,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _openPlayer(
              p2 != null && p2['id'] is num ? (p2['id'] as num).toInt() : null,
              p2?['name'] as String?,
            ),
            child: _Avatar(
              url: p2?['avatar'] as String?,
              name: p2?['name'] as String? ?? '',
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // Имена — каждый игрок на своей строке
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openPlayer(
                    p1 != null && p1['id'] is num
                        ? (p1['id'] as num).toInt()
                        : null,
                    p1?['name'] as String?,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    p1?['name'] as String? ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: nameColor,
                      fontWeight: nameWeight,
                      fontSize: 13,
                      letterSpacing: -0.1,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                GestureDetector(
                  onTap: () => _openPlayer(
                    p2 != null && p2['id'] is num
                        ? (p2['id'] as num).toInt()
                        : null,
                    p2?['name'] as String?,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    p2?['name'] as String? ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: nameColor,
                      fontWeight: nameWeight,
                      fontSize: 13,
                      letterSpacing: -0.1,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Score
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scoreBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score == null ? '—' : '$score',
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Helpers =====

/// Маленький бейдж статуса раунда (опционально с пульсирующим кружком).
class _RoundStatusPill extends StatefulWidget {
  final String text;
  final Color color;
  final bool pulse;
  const _RoundStatusPill({
    required this.text,
    required this.color,
    this.pulse = false,
  });

  @override
  State<_RoundStatusPill> createState() => _RoundStatusPillState();
}

class _RoundStatusPillState extends State<_RoundStatusPill>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: widget.color.withAlpha(38),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.pulse && _ctrl != null) ...[
            AnimatedBuilder(
              animation: _ctrl!,
              builder: (_, _2) => Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: (1.0 - 0.55 * _ctrl!.value) * 0.5,
                    child: Transform.scale(
                      scale: 1.0 + 0.5 * _ctrl!.value,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            widget.text,
            style: TextStyle(
              color: widget.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String date;
  const _DatePill({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.amber.withAlpha(30),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.amber.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, color: AppTheme.amber, size: 14),
          const SizedBox(width: 6),
          Text(
            date.isEmpty ? 'Завершён' : date,
            style: TextStyle(
              color: AppTheme.amber,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePill extends StatefulWidget {
  const _LivePill();

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(38),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.accent.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: (1.0 - 0.55 * _ctrl.value) * 0.5,
                  child: Transform.scale(
                    scale: 1.0 + 0.45 * _ctrl.value,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          color: AppTheme.accent, shape: BoxShape.circle),
                    ),
                  ),
                ),
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                      color: AppTheme.accent, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('Идёт сейчас',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  const _Avatar({required this.url, required this.name, this.size = 28});

  String get _initials {
    // Берём только буквенные символы, игнорируем цифры и знаки (#, -, etc).
    final cleaned = name.replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '');
    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

/// Pill с дельтой рейтинга юзера за матч (на карточке матча в Live).
/// Показывается рядом с бейджем «Вы играете» если матч завершён.
class _MatchRatingPill extends StatelessWidget {
  final int delta;
  const _MatchRatingPill({required this.delta});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? AppTheme.accent : AppTheme.error;
    final precise = context.watch<SettingsProvider>().preciseRating;
    final text = RatingFormatter.formatRatingChange(delta, precise, decimals: 4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: color,
            size: 11,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
