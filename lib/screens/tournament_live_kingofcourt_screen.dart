import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'player_profile_screen.dart';

/// Live-экран турнира «Король корта».
/// Корты упорядочены 1..N: Корт 1 — «Топ», Корт N — «Дно».
/// После каждого раунда: победители корта 1 остаются, проигравшие
/// последнего корта остаются, остальные двигаются вверх/вниз.
/// Пары перемешиваются каждый раунд.
class TournamentLiveKingOfCourtScreen extends StatefulWidget {
  final int tournamentId;
  const TournamentLiveKingOfCourtScreen({super.key, required this.tournamentId});

  @override
  State<TournamentLiveKingOfCourtScreen> createState() =>
      _TournamentLiveKingOfCourtScreenState();
}

enum _KocTab { rounds, table }

const _hdrStyle = TextStyle(
  color: AppTheme.textDim,
  fontSize: 10,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
);

class _TournamentLiveKingOfCourtScreenState
    extends State<TournamentLiveKingOfCourtScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  _KocTab _activeTab = _KocTab.rounds;
  final Map<int, bool> _roundExpanded = {};
  bool _expandedInitialized = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _expandedInitialized = false;
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
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
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
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
    final leaderboard =
        (_data!['leaderboard'] as List).cast<Map<String, dynamic>>();
    final rounds = (_data!['rounds'] as List).cast<Map<String, dynamic>>();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          _buildHeader(tournament),
          _buildMainTabs(),
          if (_activeTab == _KocTab.rounds)
            _buildRounds(rounds)
          else
            _buildLeaderboard(leaderboard),
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
                    style:
                        TextStyle(color: AppTheme.textDim, fontSize: 13)),
              ),
              Text(
                t['format_name'] as String? ?? '',
                style: const TextStyle(
                    color: AppTheme.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Main tabs =====
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
            for (final tab in _KocTab.values) Expanded(child: _kocTabBtn(tab)),
          ],
        ),
      ),
    );
  }

  Widget _kocTabBtn(_KocTab tab) {
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
          tab == _KocTab.rounds ? 'Раунды' : 'Таблица',
          style: TextStyle(
            color: isActive ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ===== Leaderboard =====
  Widget _buildLeaderboard(List<Map<String, dynamic>> leaderboard) {
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
              children: const [
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
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                2: FlexColumnWidth(),
                3: IntrinsicColumnWidth(),
                4: IntrinsicColumnWidth(),
                5: IntrinsicColumnWidth(),
                6: IntrinsicColumnWidth(),
                7: IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _hdrRow(),
                for (final p in leaderboard) _lbRow(p),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  TableRow _hdrRow() {
    Widget h(String t, {bool center = true}) => Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Text(t,
              textAlign: center ? TextAlign.center : TextAlign.left,
              style: _hdrStyle),
        );
    return TableRow(
      children: [
        h('#', center: false),
        const SizedBox(),
        h('Игрок', center: false),
        h('В'),
        h('П'),
        h('РП'),
        h('%'),
        h('Очки'),
      ],
    );
  }

  TableRow _lbRow(Map<String, dynamic> p) {
    final position = (p['position'] as num).toInt();
    final isMe = p['is_me'] == true;
    Color rankColor = AppTheme.textDim;
    if (position == 1) rankColor = const Color(0xFFFFD700);
    if (position == 2) rankColor = const Color(0xFFC0C0C0);
    if (position == 3) rankColor = const Color(0xFFCD7F32);
    final pointDiff = (p['point_diff'] as num).toInt();
    final ballPercent = (p['ball_percent'] as num?)?.toInt() ?? 0;
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
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      children: [
        cell(
          Text('$position',
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              )),
          padding: const EdgeInsets.fromLTRB(2, 8, 6, 8),
          alignment: Alignment.centerLeft,
        ),
        cell(
          _Avatar(
            url: p['avatar'] as String?,
            name: p['name'] as String? ?? '',
            size: 24,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        cell(
          Text(
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
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          alignment: Alignment.centerLeft,
        ),
        cell(Text('${p['wins']}',
            style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700))),
        cell(Text('${p['losses']}',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600))),
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
        cell(Text('$ballPercent',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600))),
        cell(Text('${p['total_points']}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ))),
      ],
    );
  }

  // ===== Rounds =====
  Widget _buildRounds(List<Map<String, dynamic>> rounds) {
    if (!_expandedInitialized) {
      _expandedInitialized = true;
      int? activeIdx;
      for (var i = 0; i < rounds.length; i++) {
        if (rounds[i]['status'] == 'in_progress') {
          activeIdx = i;
          break;
        }
      }
      if (activeIdx == null) {
        final idx = rounds.indexWhere((r) => r['status'] != 'completed');
        if (idx >= 0) activeIdx = idx;
      }
      activeIdx ??= rounds.isNotEmpty ? rounds.length - 1 : -1;

      for (var i = 0; i < rounds.length; i++) {
        final rid = (rounds[i]['id'] as num).toInt();
        _roundExpanded[rid] = i == activeIdx;
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
    final completedCount =
        matches.where((m) => m['status'] == 'completed').length;
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
                    const _RoundStatusPill(
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
    final tier = m['court_tier'] as String? ?? 'middle';
    final label = m['court_label'] as String? ?? 'Корт $court';

    final t1Win = completed && (score1 ?? 0) > (score2 ?? 0);
    final t2Win = completed && (score2 ?? 0) > (score1 ?? 0);

    Color tierFg;
    Color tierBg;
    switch (tier) {
      case 'top':
        tierFg = AppTheme.amber;
        tierBg = AppTheme.amber.withAlpha(30);
        break;
      case 'bottom':
        tierFg = AppTheme.error;
        tierBg = AppTheme.error.withAlpha(30);
        break;
      default:
        tierFg = const Color(0xFF38BDF8);
        tierBg = const Color(0xFF38BDF8).withAlpha(30);
    }

    return Container(
      decoration: BoxDecoration(
        color: hasMe ? AppTheme.accent.withAlpha(20) : null,
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tierBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: tierFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(38),
                      borderRadius: BorderRadius.circular(6),
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
          _buildTeamCard(t1,
              isWinner: t1Win, isCompleted: completed, score: score1),
          const SizedBox(height: 6),
          _buildTeamCard(t2,
              isWinner: t2Win, isCompleted: completed, score: score2),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team,
      {required bool isWinner,
      required bool isCompleted,
      dynamic score}) {
    final p1 = team['player1'] as Map<String, dynamic>?;
    final p2 = team['player2'] as Map<String, dynamic>?;
    final isLoser = isCompleted && !isWinner;
    final isPending = !isCompleted;

    final Color bg;
    final Border? border;
    if (isPending) {
      bg = Colors.transparent;
      border = Border.all(color: const Color(0xFF2A2A2A));
    } else {
      bg = AppTheme.cardRaised.withAlpha(120);
      border = null;
    }

    final nameColor = isLoser ? AppTheme.textSecondary : AppTheme.textPrimary;
    final nameWeight = isWinner ? FontWeight.w700 : FontWeight.w600;

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
              builder: (c, w) => Stack(
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
            builder: (c, w) => Stack(
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
    final cleaned =
        name.replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '');
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
        errorBuilder: (c, e, s) => fallback,
      ),
    );
  }
}
