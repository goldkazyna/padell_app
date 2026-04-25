import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'player_profile_screen.dart';

/// Экран «Идёт сейчас» — детализация активного турнира (только Американо).
/// Группы → таблица лидеров + раунды + матчи. Только чтение.
class TournamentLiveScreen extends StatefulWidget {
  final int tournamentId;
  const TournamentLiveScreen({super.key, required this.tournamentId});

  @override
  State<TournamentLiveScreen> createState() => _TournamentLiveScreenState();
}

enum _LiveTab { rounds, table }

const _hdrStyle = TextStyle(
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
      final response = await ApiService()
          .get('/tournaments/${widget.tournamentId}/live', token);
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: _buildBody()),
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
              const Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textPrimary)),
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
        ],
      ),
    );
  }

  // ===== Main tabs (Раунды / Таблица) =====
  Widget _buildMainTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          for (final tab in _LiveTab.values)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _activeTab == tab
                        ? AppTheme.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab == _LiveTab.rounds
                            ? Icons.sports_tennis
                            : Icons.emoji_events_outlined,
                        size: 16,
                        color: _activeTab == tab
                            ? const Color(0xFF0A0A0D)
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab == _LiveTab.rounds ? 'Раунды' : 'Таблица',
                        style: TextStyle(
                          color: _activeTab == tab
                              ? const Color(0xFF0A0A0D)
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: const Icon(Icons.chevron_left,
                      color: AppTheme.textPrimary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              const _LivePill(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            t['name'] as String? ?? '',
            style: const TextStyle(
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
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('·',
                    style: TextStyle(
                        color: AppTheme.textDim, fontSize: 13)),
              ),
              Text(
                t['format_name'] as String? ?? '',
                style: const TextStyle(
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

  // ===== Group tabs =====
  Widget _buildGroupTabs(List<Map<String, dynamic>> groups) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < groups.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGroupIdx = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedGroupIdx == i
                        ? AppTheme.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    groups[i]['name'] as String? ?? 'Группа ${i + 1}',
                    style: TextStyle(
                      color: _selectedGroupIdx == i
                          ? const Color(0xFF0A0A0D)
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== Leaderboard =====
  Widget _buildLeaderboard(Map<String, dynamic> group) {
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
                const Icon(Icons.emoji_events_outlined,
                    color: AppTheme.amber, size: 16),
                const SizedBox(width: 8),
                const Text(
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
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Row(
              children: const [
                SizedBox(width: 16, child: Text('#', style: _hdrStyle)),
                SizedBox(width: 6),
                Expanded(child: Text('Игрок', style: _hdrStyle)),
                SizedBox(width: 18, child: Center(child: Text('В', style: _hdrStyle))),
                SizedBox(width: 18, child: Center(child: Text('П', style: _hdrStyle))),
                SizedBox(width: 18, child: Center(child: Text('З', style: _hdrStyle))),
                SizedBox(width: 26, child: Center(child: Text('РП', style: _hdrStyle))),
                SizedBox(width: 24, child: Center(child: Text('%', style: _hdrStyle))),
                SizedBox(width: 28, child: Center(child: Text('Очки', style: _hdrStyle))),
              ],
            ),
          ),
          for (final p in lb) _buildLeaderboardRow(p),
          const SizedBox(height: 6),
        ],
      ),
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

  Widget _buildLeaderboardRow(Map<String, dynamic> p) {
    final position = (p['position'] as num).toInt();
    final isMe = p['is_me'] == true;
    Color rankColor = AppTheme.textDim;
    if (position == 1) rankColor = const Color(0xFFFFD700); // gold
    if (position == 2) rankColor = const Color(0xFFC0C0C0); // silver
    if (position == 3) rankColor = const Color(0xFFCD7F32); // bronze

    final pointDiff = (p['point_diff'] as num).toInt();

    final playerId = p['id'] is num ? (p['id'] as num).toInt() : null;
    final playerName = p['name'] as String?;
    final draws = (p['draws'] as num?)?.toInt() ?? 0;
    final winPercent = (p['win_percent'] as num?)?.toInt() ?? 0;
    return InkWell(
      onTap: () => _openPlayer(playerId, playerName),
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? AppTheme.accent.withAlpha(20) : null,
          border: const Border(
            top: BorderSide(color: AppTheme.divider, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              child: Text(
                '$position',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _Avatar(
                url: p['avatar'] as String?,
                name: p['name'] as String? ?? '',
                size: 22),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                (p['name'] as String? ?? '—'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                  fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            // В
            SizedBox(
              width: 18,
              child: Center(
                child: Text('${p['wins']}',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            // П
            SizedBox(
              width: 18,
              child: Center(
                child: Text('${p['losses']}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            // З (ничьи)
            SizedBox(
              width: 18,
              child: Center(
                child: Text('$draws',
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            // РП (разница)
            SizedBox(
              width: 26,
              child: Center(
                child: Text(
                  pointDiff > 0 ? '+$pointDiff' : '$pointDiff',
                  style: TextStyle(
                    color: pointDiff > 0
                        ? AppTheme.accent
                        : (pointDiff < 0
                            ? AppTheme.error
                            : AppTheme.textSecondary),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // %
            SizedBox(
              width: 24,
              child: Center(
                child: Text('$winPercent',
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            // Очки
            SizedBox(
              width: 28,
              child: Center(
                child: Text(
                  '${p['total_points']}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Rounds =====
  Widget _buildRounds(Map<String, dynamic> group) {
    final rounds = (group['rounds'] as List).cast<Map<String, dynamic>>();
    final groupId = (group['id'] as num).toInt();

    // При первом показе группы — раскрываем «текущий» раунд (round.status == in_progress)
    // или первый не завершённый. Остальные сворачиваем.
    if (!_initializedGroups.contains(groupId)) {
      _initializedGroups.add(groupId);
      int? activeIdx;
      // 1) ищем раунд со статусом in_progress
      for (var i = 0; i < rounds.length; i++) {
        if (rounds[i]['status'] == 'in_progress') {
          activeIdx = i;
          break;
        }
      }
      // 2) иначе — первый не completed
      if (activeIdx == null) {
        final idx =
            rounds.indexWhere((r) => r['status'] != 'completed');
        if (idx >= 0) activeIdx = idx;
      }
      // 3) иначе — последний (все завершены)
      activeIdx ??= rounds.isNotEmpty ? rounds.length - 1 : -1;
      for (var i = 0; i < rounds.length; i++) {
        final rid = (rounds[i]['id'] as num).toInt();
        _roundExpanded[rid] = (i == activeIdx);
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
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$completedCount / ${matches.length} матчей',
                    style: const TextStyle(
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
                    const _RoundStatusPill(
                      text: 'завершён',
                      color: AppTheme.textDim,
                    )
                  else
                    const _RoundStatusPill(
                      text: 'ожидание',
                      color: AppTheme.amber,
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            for (var i = 0; i < matches.length; i++)
              _buildMatch(matches[i], isLast: i == matches.length - 1),
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

    final t1Win = completed && (score1 ?? 0) > (score2 ?? 0);
    final t2Win = completed && (score2 ?? 0) > (score1 ?? 0);
    final draw = completed && (score1 ?? 0) == (score2 ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: hasMe ? AppTheme.accent.withAlpha(15) : null,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (court != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
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
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (hasMe) ...[
                    const SizedBox(width: 6),
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
                ],
              ),
            ),
          // Team 1
          _buildTeamRow(t1, isWinner: t1Win, isDraw: draw, score: score1),
          const SizedBox(height: 6),
          // Team 2
          _buildTeamRow(t2, isWinner: t2Win, isDraw: draw, score: score2),
        ],
      ),
    );
  }

  Widget _buildTeamRow(Map<String, dynamic> team,
      {required bool isWinner, required bool isDraw, dynamic score}) {
    final p1 = team['player1'] as Map<String, dynamic>?;
    final p2 = team['player2'] as Map<String, dynamic>?;
    final p1Id = p1 != null && p1['id'] is num ? (p1['id'] as num).toInt() : null;
    final p2Id = p2 != null && p2['id'] is num ? (p2['id'] as num).toInt() : null;

    final nameStyle = TextStyle(
      color: isWinner
          ? AppTheme.accent
          : (isDraw ? AppTheme.textPrimary : AppTheme.textSecondary),
      fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600,
      fontSize: 13,
    );

    return Row(
      children: [
        GestureDetector(
          onTap: () => _openPlayer(p1Id, p1?['name'] as String?),
          child: _Avatar(
              url: p1?['avatar'] as String?,
              name: p1?['name'] as String? ?? '',
              size: 22),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _openPlayer(p2Id, p2?['name'] as String?),
          child: _Avatar(
              url: p2?['avatar'] as String?,
              name: p2?['name'] as String? ?? '',
              size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openPlayer(p1Id, p1?['name'] as String?),
                child: Text(p1?['name'] as String? ?? '—', style: nameStyle),
              ),
              Text(' / ', style: nameStyle),
              GestureDetector(
                onTap: () => _openPlayer(p2Id, p2?['name'] as String?),
                child: Text(p2?['name'] as String? ?? '—', style: nameStyle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isWinner
                ? AppTheme.accent
                : (isDraw
                    ? AppTheme.cardRaised
                    : (score == null
                        ? Colors.transparent
                        : AppTheme.cardRaised)),
            borderRadius: BorderRadius.circular(6),
            border: score == null
                ? Border.all(color: const Color(0xFF2A2A2A))
                : null,
          ),
          child: Text(
            score == null ? '—' : '$score',
            style: TextStyle(
              color: isWinner
                  ? const Color(0xFF0A0A0D)
                  : (score == null
                      ? AppTheme.textDim
                      : AppTheme.textPrimary),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ],
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
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
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
