import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'player_profile_screen.dart';

class TournamentStatsScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const TournamentStatsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<TournamentStatsScreen> createState() => _TournamentStatsScreenState();
}

class _TournamentStatsScreenState extends State<TournamentStatsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });

    try {
      final token = await StorageService().getToken();
      if (token == null) {
        if (mounted) setState(() { _loading = false; _error = 'Не авторизован'; });
        return;
      }
      final response = await ApiService().get('/tournaments/${widget.tournamentId}/stats', token);
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() { _data = response; _loading = false; });
      } else {
        setState(() { _loading = false; _error = response['message'] as String? ?? 'Ошибка'; });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Ошибка загрузки'; });
    }
  }

  void _openPlayer(int id, String name) {
    if (id <= 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(playerId: id, playerName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: const Text('Повторить')),
                      ],
                    ),
                  )
                : _data == null
                    ? const Center(child: Text('Нет данных', style: TextStyle(color: AppTheme.textSecondary)))
                    : Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 12),
                          _buildTabs(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _currentTab == 0
                                ? _buildMatchesTab()
                                : _currentTab == 1
                                    ? _buildParticipantsTab()
                                    : _buildLeaderboardTab(),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.card,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildHeader() {
    final t = _data?['tournament'] as Map<String, dynamic>? ?? {};
    final name = t['name'] as String? ?? widget.tournamentName;
    final date = t['date'] as String? ?? '';
    final clubName = t['club_name'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(icon: Icons.chevron_left, onTap: () => Navigator.pop(context)),
              _buildCircleButton(icon: Icons.ios_share, onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '$date · $clubName',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Матчи', 'Участники', 'Таблица'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isActive = _currentTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentTab = i),
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
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? AppTheme.accent : const Color(0xFF52525B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ================== МАТЧИ ==================
  Widget _buildMatchesTab() {
    final matches = _data?['matches'] as List<dynamic>? ?? [];
    final playoff = _data?['playoff'] as List<dynamic>? ?? [];

    if (matches.isEmpty && playoff.isEmpty) {
      return const Center(
        child: Text('Матчи не сыграны', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    // Группируем обычные матчи по stage
    final byStage = <String, List<dynamic>>{};
    for (final m in matches) {
      final mm = m as Map<String, dynamic>;
      final stage = mm['stage'] as String? ?? 'Матчи';
      byStage.putIfAbsent(stage, () => []).add(mm);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ...byStage.entries.expand((entry) => [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...entry.value.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMatchCard(m as Map<String, dynamic>),
                  )),
            ]),
        if (playoff.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'ПЛЕЙ-ОФФ',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
          ...playoff.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPlayoffMatchCard(m as Map<String, dynamic>),
              )),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final t1Score = match['team1_score'] as int? ?? 0;
    final t2Score = match['team2_score'] as int? ?? 0;
    final team1 = match['team1_players'] as List<dynamic>? ?? [];
    final team2 = match['team2_players'] as List<dynamic>? ?? [];
    final round = match['round'] as int?;
    final stage = match['stage'] as String? ?? '';

    final t1Won = t1Score > t2Score;
    final t2Won = t2Score > t1Score;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        children: [
          if (round != null)
            Row(
              children: [
                Text(
                  '$stage · Раунд $round',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 0.5),
                ),
              ],
            ),
          if (round != null) const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildTeamColumn(team1, CrossAxisAlignment.start, t1Won)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$t1Score : $t2Score',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: _buildTeamColumn(team2, CrossAxisAlignment.end, t2Won)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayoffMatchCard(Map<String, dynamic> match) {
    final stageName = match['stage_name'] as String? ?? match['stage'] as String? ?? '';
    final status = match['status'] as String? ?? '';
    final t1Score = match['team1_score'] as int? ?? 0;
    final t2Score = match['team2_score'] as int? ?? 0;
    final team1 = match['team1_players'] as List<dynamic>? ?? [];
    final team2 = match['team2_players'] as List<dynamic>? ?? [];
    final isCompleted = status == 'completed';

    final t1Won = isCompleted && t1Score > t2Score;
    final t2Won = isCompleted && t2Score > t1Score;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                stageName,
                style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildTeamColumn(team1, CrossAxisAlignment.start, t1Won)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: isCompleted
                    ? Text('$t1Score : $t2Score',
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold))
                    : const Text('vs',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              ),
              Expanded(child: _buildTeamColumn(team2, CrossAxisAlignment.end, t2Won)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(List<dynamic> team, CrossAxisAlignment alignment, bool isWinner) {
    final isLeft = alignment == CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: alignment,
      children: team.map((player) {
        final p = player as Map<String, dynamic>;
        final name = p['name'] as String? ?? '';
        final id = p['id'] as int? ?? 0;
        final initials = _initials(name);

        final nameWidget = Flexible(
          child: GestureDetector(
            onTap: () => _openPlayer(id, name),
            child: Text(
              name,
              textAlign: isLeft ? TextAlign.start : TextAlign.right,
              style: TextStyle(
                color: isWinner ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

        final initialsBadge = _initialsBadge(initials);

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [initialsBadge, const SizedBox(width: 8), nameWidget]
                : [nameWidget, const SizedBox(width: 8), initialsBadge],
          ),
        );
      }).toList(),
    );
  }

  Widget _initialsBadge(String initials) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ================== УЧАСТНИКИ ==================
  Widget _buildParticipantsTab() {
    final participants = _data?['participants'] as List<dynamic>? ?? [];

    if (participants.isEmpty) {
      return const Center(
        child: Text('Нет участников', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final p = participants[index] as Map<String, dynamic>;
        final id = p['id'] as int? ?? 0;
        final name = p['name'] as String? ?? '';
        final rating = p['rating'] as int? ?? 0;
        final levelVal = p['level'];
        double level = 0;
        if (levelVal is num) level = levelVal.toDouble();
        else if (levelVal is String) level = double.tryParse(levelVal) ?? 0;
        final avatar = p['avatar'] as String?;
        final initials = _initials(name);

        String levelCategory = level >= 4.0 ? '4' : level >= 3.0 ? '3' : level >= 2.0 ? '2' : '1';

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => _openPlayer(id, name),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: avatar != null
                        ? Image.network(avatar, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                                  child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ))
                        : Center(
                            child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('L$levelCategory · $level',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('$rating',
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================== ТАБЛИЦА ==================
  Widget _buildLeaderboardTab() {
    final leaderboard = _data?['leaderboard'] as List<dynamic>? ?? [];
    final teamStandings = _data?['team_standings'] as List<dynamic>? ?? [];
    final playoff = _data?['playoff'] as List<dynamic>? ?? [];

    if (leaderboard.isEmpty && teamStandings.isEmpty) {
      return const Center(
        child: Text('Нет данных', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    if (teamStandings.isNotEmpty) {
      return _buildTeamLeaderboard(teamStandings, playoff);
    }

    return _buildPlayerLeaderboard(leaderboard, playoff);
  }

  Widget _buildPlayerLeaderboard(List<dynamic> leaderboard, List<dynamic> playoff) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              SizedBox(width: 28, child: Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 8),
              Expanded(child: Text('ИГРОК', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 28, child: Text('В', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 28, child: Text('П', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 36, child: Text('Р', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 36, child: Text('%', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 40, child: Text('ОЧКИ', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: leaderboard.length + (playoff.isNotEmpty ? playoff.length + 1 : 0),
            itemBuilder: (context, index) {
              if (index >= leaderboard.length) {
                final poIndex = index - leaderboard.length;
                if (poIndex == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('ПЛЕЙ-ОФФ',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildPlayoffMatchCard(playoff[poIndex - 1] as Map<String, dynamic>),
                );
              }

              final p = leaderboard[index] as Map<String, dynamic>;
              final id = p['id'] as int? ?? 0;
              final name = p['name'] as String? ?? '';
              final wins = p['wins'] as int? ?? 0;
              final losses = p['losses'] as int? ?? 0;
              final ptsFor = p['points_for'] as int? ?? 0;
              final ptsAgainst = p['points_against'] as int? ?? 0;
              final winPercent = p['win_percent'] as int? ?? 0;
              final totalPoints = p['total_points'] as int? ?? 0;
              final position = p['position'] as int? ?? (index + 1);
              final initials = _initials(name);

              final posColor = position == 1
                  ? const Color(0xFFFACC15)
                  : position == 2
                      ? const Color(0xFF94A3B8)
                      : position == 3
                          ? const Color(0xFFF97316)
                          : const Color(0xFF52525B);

              return GestureDetector(
                onTap: () => _openPlayer(id, name),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('$position', textAlign: TextAlign.center,
                            style: TextStyle(color: posColor, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: Color(0xFF27272A), shape: BoxShape.circle),
                        child: Center(
                          child: Text(initials,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(width: 28, child: Text('$wins', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12))),
                      SizedBox(width: 28, child: Text('$losses', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12))),
                      SizedBox(width: 36, child: Text('$ptsFor:$ptsAgainst', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10))),
                      SizedBox(width: 36, child: Text('$winPercent%', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600))),
                      SizedBox(width: 40, child: Text('$totalPoints', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.w800))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamLeaderboard(List<dynamic> teamStandings, List<dynamic> playoff) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              SizedBox(width: 28, child: Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 8),
              Expanded(child: Text('КОМАНДА', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              SizedBox(width: 60, child: Text('В – П', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: teamStandings.length + (playoff.isNotEmpty ? playoff.length + 1 : 0),
            itemBuilder: (context, index) {
              if (index >= teamStandings.length) {
                final poIndex = index - teamStandings.length;
                if (poIndex == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('ПЛЕЙ-ОФФ',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildPlayoffMatchCard(playoff[poIndex - 1] as Map<String, dynamic>),
                );
              }

              final t = teamStandings[index] as Map<String, dynamic>;
              final position = t['position'] as int? ?? (index + 1);
              final p1 = t['player1'] as Map<String, dynamic>?;
              final p2 = t['player2'] as Map<String, dynamic>?;
              final wins = t['wins'] as int? ?? 0;
              final losses = t['losses'] as int? ?? 0;
              final pf = t['points_for'] as int? ?? 0;
              final pa = t['points_against'] as int? ?? 0;
              final diff = pf - pa;

              final posColor = position == 1
                  ? const Color(0xFFFACC15)
                  : position == 2
                      ? const Color(0xFF94A3B8)
                      : position == 3
                          ? const Color(0xFFF97316)
                          : const Color(0xFF52525B);

              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text('$position', textAlign: TextAlign.center,
                          style: TextStyle(color: posColor, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p1 != null)
                            GestureDetector(
                              onTap: () => _openPlayer(p1['id'] as int? ?? 0, p1['name'] as String? ?? ''),
                              child: Text(
                                p1['name'] as String? ?? '',
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (p2 != null) ...[
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () => _openPlayer(p2['id'] as int? ?? 0, p2['name'] as String? ?? ''),
                              child: Text(
                                p2['name'] as String? ?? '',
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$wins – $losses',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(diff >= 0 ? '+$diff' : '$diff',
                            style: TextStyle(
                              color: diff >= 0 ? AppTheme.accent : AppTheme.textSecondary,
                              fontSize: 11,
                            )),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
