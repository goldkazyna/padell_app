import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/rating_formatter.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_tab_bar.dart';
import 'player_profile_screen.dart';

/// Live-экран турнира «Король Корта (Bali Format)».
/// Корты упорядочены 1..N: Корт 1 — «Топ», Корт N — «Дно».
/// Пары ФИКСИРОВАННЫЕ — не меняются на протяжении всего турнира.
/// После каждого раунда: победители ↑, проигравшие ↓ (как в KOC).
/// Очки: раунд 1 = 1/0; раунды 2+: победитель корта K из N кортов получает
/// (N+2−K) очков, проигравший — 0. Таблица лидеров — по парам.
class TournamentLiveBaliKocScreen extends StatefulWidget {
  final int tournamentId;

  /// ID игрока, которого нужно подсвечивать вместо текущего пользователя.
  /// Используется когда открываем экран из чужого профиля.
  final int? highlightPlayerId;

  const TournamentLiveBaliKocScreen({
    super.key,
    required this.tournamentId,
    this.highlightPlayerId,
  });

  @override
  State<TournamentLiveBaliKocScreen> createState() =>
      _TournamentLiveBaliKocScreenState();
}

enum _BaliTab { rounds, table }

class _TournamentLiveBaliKocScreenState
    extends State<TournamentLiveBaliKocScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  _BaliTab _activeTab = _BaliTab.rounds;
  final Map<int, bool> _roundExpanded = {};
  bool _expandedInitialized = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
        _expandedInitialized = false;
        _roundExpanded.clear();
      });
    }
    try {
      final token = await StorageService().getToken();
      final qs = widget.highlightPlayerId != null
          ? '?player_id=${widget.highlightPlayerId}'
          : '';
      final response = await ApiService()
          .get('/tournaments/${widget.tournamentId}/live$qs', token);
      if (!mounted) return;
      if (response['success'] == true) {
        if (widget.highlightPlayerId != null) {
          _overrideHighlight(response, widget.highlightPlayerId!);
        }
        setState(() {
          _data = response;
          _loading = false;
        });
      } else {
        if (silent) return; // тихая перезагрузка: ошибки не подсвечиваем
        setState(() {
          _error = (response['message'] as String?) ?? 'Ошибка загрузки';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (silent) return; // тихая перезагрузка: ошибки сети тоже игнорим
      setState(() {
        _error = 'Ошибка сети: $e';
        _loading = false;
      });
    }
  }

  /// Помечаем is_me/has_me для заданного игрока (через его пару).
  void _overrideHighlight(Map<String, dynamic> response, int playerId) {
    final leaderboard =
        (response['leaderboard'] as List?)?.cast<Map<String, dynamic>>() ??
            const [];
    for (final row in leaderboard) {
      final p1 = row['player1'] as Map<String, dynamic>?;
      final p2 = row['player2'] as Map<String, dynamic>?;
      final p1Id = p1?['id'];
      final p2Id = p2?['id'];
      row['is_me'] = (p1Id is num && p1Id.toInt() == playerId) ||
          (p2Id is num && p2Id.toInt() == playerId);
    }

    bool playerInList(List<dynamic>? ids, int target) {
      if (ids == null) return false;
      for (final v in ids) {
        if (v is num && v.toInt() == target) return true;
      }
      return false;
    }

    final rounds = (response['rounds'] as List?)?.cast<Map<String, dynamic>>() ??
        const [];
    for (final round in rounds) {
      final matches =
          (round['matches'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      for (final m in matches) {
        final t1 = m['team1'] as Map<String, dynamic>?;
        final t2 = m['team2'] as Map<String, dynamic>?;
        final t1Ids = [
          (t1?['player1'] as Map<String, dynamic>?)?['id'],
          (t1?['player2'] as Map<String, dynamic>?)?['id'],
        ];
        final t2Ids = [
          (t2?['player1'] as Map<String, dynamic>?)?['id'],
          (t2?['player2'] as Map<String, dynamic>?)?['id'],
        ];
        final t1HasMe = playerInList(t1Ids, playerId);
        final t2HasMe = playerInList(t2Ids, playerId);
        if (t1 != null) t1['has_me'] = t1HasMe;
        if (t2 != null) t2['has_me'] = t2HasMe;
        m['has_me'] = t1HasMe || t2HasMe;
      }
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
        bottomNavigationBar: const MainTabBar(),
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
              Icon(Icons.error_outline, color: AppTheme.error, size: 48),
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
          if (_activeTab == _BaliTab.rounds)
            _buildRounds(rounds)
          else
            _buildLeaderboard(leaderboard),
        ],
      ),
    );
  }

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
                    style:
                        TextStyle(color: AppTheme.textDim, fontSize: 13)),
              ),
              Text(
                t['format_name'] as String? ?? '',
                style: TextStyle(
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
            for (final tab in _BaliTab.values) Expanded(child: _baliTabBtn(tab)),
          ],
        ),
      ),
    );
  }

  Widget _baliTabBtn(_BaliTab tab) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = tab);
        // Тихо подтягиваем свежие данные с сервера, чтобы при переключении
        // вкладки таблица/раунды были актуальными.
        _load(silent: true);
      },
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
          tab == _BaliTab.rounds ? 'Раунды' : 'Таблица',
          style: TextStyle(
            color: isActive ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ===== Leaderboard (пары) =====
  Widget _buildLeaderboard(List<Map<String, dynamic>> leaderboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text('#',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text('ПАРА',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 28,
                child: Text('В',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 28,
                child: Text('П',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 36,
                child: Text('РГ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 36,
                child: Text('%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 40,
                child: Text('ОЧКИ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        for (final p in leaderboard) _buildLeaderboardRow(p),
      ],
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> p) {
    final position = (p['position'] as num).toInt();
    final isMe = p['is_me'] == true;
    final wins = (p['wins'] as num?)?.toInt() ?? 0;
    final losses = (p['losses'] as num?)?.toInt() ?? 0;
    final pointDiff = (p['point_diff'] as num?)?.toInt() ?? 0;
    final ballPercent = (p['ball_percent'] as num?)?.toInt() ?? 0;
    final totalPoints = (p['points'] as num?)?.toInt() ?? 0;

    final player1 = p['player1'] as Map<String, dynamic>?;
    final player2 = p['player2'] as Map<String, dynamic>?;

    Color posColor = const Color(0xFF52525B);
    if (position == 1) posColor = const Color(0xFFFACC15);
    if (position == 2) posColor = const Color(0xFF94A3B8);
    if (position == 3) posColor = const Color(0xFFF97316);

    final diffStr = pointDiff > 0 ? '+$pointDiff' : '$pointDiff';
    final diffColor = pointDiff > 0
        ? const Color(0xFF22C55E)
        : (pointDiff < 0
            ? const Color(0xFFEF4444)
            : AppTheme.textSecondary);

    return Container(
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(15) : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isMe ? AppTheme.accent : posColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 2 аватара стопкой
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: _Avatar(
                    url: player1?['avatar'] as String?,
                    name: (player1?['name'] as String?) ?? '',
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _Avatar(
                    url: player2?['avatar'] as String?,
                    name: (player2?['name'] as String?) ?? '',
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 2 имени стопкой
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PairNameLine(
                  player: player1,
                  isMe: isMe,
                  onTap: _openPlayer,
                ),
                const SizedBox(height: 2),
                _PairNameLine(
                  player: player2,
                  isMe: isMe,
                  onTap: _openPlayer,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$wins',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isMe ? AppTheme.accent : const Color(0xFF22C55E),
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$losses',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isMe ? AppTheme.accent : const Color(0xFFEF4444),
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              diffStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isMe ? AppTheme.accent : diffColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$ballPercent%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isMe ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$totalPoints',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isMe ? AppTheme.accent : const Color(0xFF22C55E),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
    final ratingChange = (round['my_rating_change'] as num?)?.toInt();

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
                  if (ratingChange != null && ratingChange != 0) ...[
                    _RatingDeltaPill(delta: ratingChange),
                    const SizedBox(width: 6),
                  ],
                  if (inProgress)
                    const _RoundStatusPill(
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
    final pointsForWin = (m['points_for_win'] as num?)?.toInt();

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

    final p1 = t1['player1'] as Map<String, dynamic>?;
    final p2 = t1['player2'] as Map<String, dynamic>?;
    final p3 = t2['player1'] as Map<String, dynamic>?;
    final p4 = t2['player2'] as Map<String, dynamic>?;

    return Container(
      decoration: BoxDecoration(
        color: hasMe ? AppTheme.accent.withAlpha(20) : null,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: tierFg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (pointsForWin != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardRaised.withAlpha(140),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'победа = $pointsForWin',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (hasMe) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PlayerTile(player: p1, onTap: _openPlayer)),
              const SizedBox(width: 4),
              Expanded(child: _PlayerTile(player: p2, onTap: _openPlayer)),
              const SizedBox(width: 4),
              SizedBox(
                width: 28,
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(
                    'VS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: _PlayerTile(player: p3, onTap: _openPlayer)),
              const SizedBox(width: 4),
              Expanded(child: _PlayerTile(player: p4, onTap: _openPlayer)),
            ],
          ),
          const SizedBox(height: 14),
          _buildScore(
            score1: score1,
            score2: score2,
            t1Win: t1Win,
            t2Win: t2Win,
            completed: completed,
          ),
        ],
      ),
    );
  }

  Widget _buildScore({
    required dynamic score1,
    required dynamic score2,
    required bool t1Win,
    required bool t2Win,
    required bool completed,
  }) {
    if (!completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised.withAlpha(120),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Матч ещё не сыгран',
          style: TextStyle(
            color: AppTheme.textDim,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    Color color1 = t1Win ? AppTheme.accent : AppTheme.textSecondary;
    Color color2 = t2Win ? AppTheme.accent : AppTheme.textSecondary;
    FontWeight w1 = t1Win ? FontWeight.w900 : FontWeight.w700;
    FontWeight w2 = t2Win ? FontWeight.w900 : FontWeight.w700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardRaised.withAlpha(140),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${score1 ?? 0}',
            style: TextStyle(
              color: color1,
              fontSize: 28,
              fontWeight: w1,
              height: 1.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              ':',
              style: TextStyle(
                color: AppTheme.textDim,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
          Text(
            '${score2 ?? 0}',
            style: TextStyle(
              color: color2,
              fontSize: 28,
              fontWeight: w2,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Helpers =====

class _PairNameLine extends StatelessWidget {
  final Map<String, dynamic>? player;
  final bool isMe;
  final void Function(int? id, String? name) onTap;
  const _PairNameLine({
    required this.player,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = player?['name'] as String? ?? '—';
    final id = player?['id'] is num ? (player!['id'] as num).toInt() : null;
    return InkWell(
      onTap: () => onTap(id, name),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isMe ? AppTheme.accent : AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

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

class _RatingDeltaPill extends StatelessWidget {
  final int delta;
  const _RatingDeltaPill({required this.delta});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? AppTheme.accent : AppTheme.error;
    final precise = context.watch<SettingsProvider>().preciseRating;
    final text = RatingFormatter.formatRatingChange(delta, precise);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
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

class _PlayerTile extends StatelessWidget {
  final Map<String, dynamic>? player;
  final void Function(int? id, String? name) onTap;
  const _PlayerTile({required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = player?['name'] as String? ?? '—';
    final avatar = player?['avatar'] as String?;
    final id = player?['id'] is num ? (player!['id'] as num).toInt() : null;
    final levelRaw = player?['level'];
    String? levelText;
    if (levelRaw != null) {
      final lvlNum = levelRaw is num
          ? levelRaw.toDouble()
          : double.tryParse(levelRaw.toString());
      if (lvlNum != null) levelText = lvlNum.toStringAsFixed(1);
    }

    return GestureDetector(
      onTap: () => onTap(id, name),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _Avatar(url: avatar, name: name, size: 56),
                if (levelText != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.background,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        levelText,
                        style: const TextStyle(
                          color: Color(0xFF0A0A0D),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ..._buildNameLines(name),
        ],
      ),
    );
  }

  List<Widget> _buildNameLines(String name) {
    final style = TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.2,
    );
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      return [
        Text('—', textAlign: TextAlign.center, style: style),
      ];
    }
    final first = parts.first;
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return [
      Text(
        first,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style,
      ),
      if (rest.isNotEmpty)
        Text(
          rest,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
        ),
    ];
  }
}
