import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/tournament.dart';
import '../services/profile_service.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/rating_formatter.dart';
import '../widgets/app_back_button.dart';

class TournamentResultsScreen extends StatefulWidget {
  final Tournament tournament;
  final int? playerId;

  const TournamentResultsScreen({super.key, required this.tournament, this.playerId});

  @override
  State<TournamentResultsScreen> createState() =>
      _TournamentResultsScreenState();
}

class _TournamentResultsScreenState extends State<TournamentResultsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final profileService = context.read<ProfileService>();
    final data = await profileService.getTournamentResults(widget.tournament.id, playerId: widget.playerId);
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accent))
            : _data == null
                ? const Center(child: Text('Нет данных', style: TextStyle(color: Color(0xFF71717A))))
                : Column(
                    children: [
                      _buildHeader(context, t),
                      _buildSummary(),
                      const SizedBox(height: 12),
                      _buildTabs(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _currentTab == 0
                            ? SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMatchesSection(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              )
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

  Widget _buildHeader(BuildContext context, Tournament t) {
    final summary = _data?['summary'] as Map<String, dynamic>?;
    final rawPlace = summary?['place'];
    final place = rawPlace is int
        ? rawPlace
        : (rawPlace != null ? int.tryParse(rawPlace.toString()) : null);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(),
              _buildCircleButton(
                icon: Icons.ios_share,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (place != null && (place == 1 || place == 2))
            Text(
              place == 1 ? '🥇' : '🥈',
              style: const TextStyle(fontSize: 48),
            ),
          const SizedBox(height: 12),
          Text(
            t.name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '${DateFormat('d MMMM', Localizations.localeOf(context).toLanguageTag()).format(t.datetime)} · ${t.club.name}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab() {
    final participants = _data?['participants'] as List<dynamic>? ?? [];

    if (participants.isEmpty) {
      return const Center(
        child: Text('Нет участников', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    final currentUserId = widget.playerId ?? context.read<HomeProvider>().user?.id;

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
        final isMe = currentUserId != null && id == currentUserId;

        final parts = name.trim().split(RegExp(r'\s+'));
        final initials = parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : name.isNotEmpty ? name[0].toUpperCase() : '?';

        String levelCategory = level >= 4.0 ? '4' : level >= 3.0 ? '3' : level >= 2.0 ? '2' : '1';

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.accent.withAlpha(15) : AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMe ? AppTheme.accent.withAlpha(60) : const Color(0xFF2A2A2A),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isMe ? AppTheme.accent.withAlpha(180) : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.accent : const Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                  ),
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
                      Text(
                        name,
                        style: TextStyle(
                          color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'L$levelCategory · $level',
                        style: TextStyle(
                          color: isMe ? AppTheme.accent.withAlpha(180) : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$rating',
                  style: TextStyle(
                    color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayoffMatch(Map<String, dynamic> match) {
    final stageName = match['stage_name'] as String? ?? '';
    final status = match['status'] as String? ?? '';
    final t1Score = match['team1_score'];
    final t2Score = match['team2_score'];
    final team1 = (match['team1_players'] as List<dynamic>? ?? []);
    final team2 = (match['team2_players'] as List<dynamic>? ?? []);
    final isCompleted = status == 'completed';

    final t1Won = isCompleted && t1Score != null && t2Score != null && (t1Score as int) > (t2Score as int);
    final t2Won = isCompleted && t1Score != null && t2Score != null && (t2Score as int) > (t1Score as int);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stageName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              // Team 1
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: team1.map((p) {
                    final player = p as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Container(
                          width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF27272A), shape: BoxShape.circle),
                          child: Center(child: Text(player['initials'] as String? ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w700))),
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(player['name'] as String? ?? '', style: TextStyle(color: t1Won ? AppTheme.accent : AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
              // Score
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('$t1Score : $t2Score', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('vs', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                ),
              // Team 2
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: team2.map((p) {
                    final player = p as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Expanded(child: Text(player['name'] as String? ?? '', textAlign: TextAlign.right, style: TextStyle(color: t2Won ? AppTheme.accent : AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        Container(
                          width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF27272A), shape: BoxShape.circle),
                          child: Center(child: Text(player['initials'] as String? ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w700))),
                        ),
                      ]),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboard = _data?['leaderboard'] as List<dynamic>? ?? [];

    if (leaderboard.isEmpty) {
      return const Center(
        child: Text('Нет данных', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    final currentUserId = widget.playerId ?? context.read<HomeProvider>().user?.id;

    final playoff = _data?['playoff'] as List<dynamic>? ?? [];

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 28, child: Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              const Expanded(child: Text('ИГРОК', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 28, child: Text('В', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 28, child: Text('П', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 36, child: Text('Р', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 36, child: Text('%', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 40, child: Text('ОЧКИ', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
        // List + Playoff
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: leaderboard.length + (playoff.isNotEmpty ? playoff.length + 1 : 0),
            itemBuilder: (context, index) {
              // Playoff section
              if (index >= leaderboard.length) {
                final playoffIndex = index - leaderboard.length;
                if (playoffIndex == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('ПЛЕЙ-ОФФ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  );
                }
                return _buildPlayoffMatch(playoff[playoffIndex - 1] as Map<String, dynamic>);
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
              final position = p['position'] as int? ?? index + 1;
              final isMe = currentUserId != null && id == currentUserId;

              final parts = name.trim().split(RegExp(r'\s+'));
              final initials = parts.length >= 2
                  ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                  : name.isNotEmpty ? name[0].toUpperCase() : '?';

              final posColor = position == 1
                  ? const Color(0xFFFACC15)
                  : position == 2
                      ? const Color(0xFF94A3B8)
                      : position == 3
                          ? const Color(0xFFF97316)
                          : const Color(0xFF52525B);

              return Container(
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.accent.withAlpha(15) : Colors.transparent,
                  border: const Border(bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text('$position', textAlign: TextAlign.center,
                        style: TextStyle(color: isMe ? AppTheme.accent : posColor, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: isMe ? AppTheme.accent.withAlpha(40) : const Color(0xFF27272A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(initials, style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(name, style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 28, child: Text('$wins', textAlign: TextAlign.center, style: TextStyle(color: isMe ? AppTheme.accent : const Color(0xFF22C55E), fontSize: 12))),
                    SizedBox(width: 28, child: Text('$losses', textAlign: TextAlign.center, style: TextStyle(color: isMe ? AppTheme.accent : const Color(0xFFEF4444), fontSize: 12))),
                    SizedBox(width: 36, child: Text('$ptsFor:$ptsAgainst', textAlign: TextAlign.center, style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textSecondary, fontSize: 10))),
                    SizedBox(width: 36, child: Text('$winPercent%', textAlign: TextAlign.center, style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600))),
                    SizedBox(width: 40, child: Text('$totalPoints', textAlign: TextAlign.right, style: TextStyle(color: isMe ? AppTheme.accent : const Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.w800))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['Результаты', 'Участники', 'Таблица'];
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

  Widget _buildSummary() {
    final summary = _data?['summary'] as Map<String, dynamic>?;
    final matchesCount = summary?['matches_count'] ?? 0;
    final wins = summary?['wins'] ?? 0;
    final losses = summary?['losses'] ?? 0;
    final ratingChange = (summary?['rating_change'] as num?)?.toInt() ?? 0;
    final precise = context.watch<SettingsProvider>().preciseRating;

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSummaryCard('$matchesCount', l10n.matchesLabel),
          const SizedBox(width: 10),
          _buildSummaryCard('$wins / $losses', l10n.winsLabel),
          const SizedBox(width: 10),
          _buildSummaryCard(
            RatingFormatter.formatRatingChange(ratingChange, precise, decimals: 4),
            l10n.ratingLabel,
            valueColor:
                ratingChange >= 0 ? AppTheme.accent : const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String value, String label, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesSection() {
    final matches = _data?['matches'] as List<dynamic>? ?? [];
    final tournament = _data?['tournament'] as Map<String, dynamic>?;
    final formatName = tournament?['format_name'] ?? '';
    final matchesCount = matches.length;

    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.matchesTitle,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$formatName · ${l10n.roundsCount(matchesCount)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...matches.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMatchCard(m as Map<String, dynamic>),
            )),
      ],
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    var roundName = match['round_name'] as String? ?? '';
    if (roundName.contains('ФИНАЛ') || roundName.contains('ПОЛУФИНАЛ')) {
      final parts = roundName.split(' · ');
      if (parts.length > 1) {
        roundName = parts.last;
      }
    }
    final scoreMy = match['score_my'] ?? 0;
    final scoreOpp = match['score_opponent'] ?? 0;
    final result = match['result'] as String? ?? '';
    final ratingChange = match['rating_change'] as int? ?? 0;
    final isWin = result == 'win';
    final isDraw = result == 'draw' || scoreMy == scoreOpp;
    final resultColor = isDraw
        ? const Color(0xFFFBBF24)
        : isWin
            ? const Color(0xFF22C55E)
            : const Color(0xFFEF4444);

    final myTeam = match['my_team'] as List<dynamic>? ?? [];
    final oppTeam = match['opponent_team'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        children: [
          // Заголовок раунда + рейтинг
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                roundName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Icon(
                    ratingChange >= 0
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: ratingChange >= 0
                        ? AppTheme.accent
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                  Text(
                    RatingFormatter.formatRatingChange(
                      ratingChange,
                      context.watch<SettingsProvider>().preciseRating,
                      decimals: 4,
                    ),
                    style: TextStyle(
                      color: ratingChange >= 0
                          ? AppTheme.accent
                          : const Color(0xFFEF4444),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Команды и счёт
          Row(
            children: [
              // Моя команда
              Expanded(child: _buildTeamColumn(myTeam, CrossAxisAlignment.start)),

              // Счёт
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$scoreMy : $scoreOpp',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Команда соперника
              Expanded(child: _buildTeamColumn(oppTeam, CrossAxisAlignment.end)),
            ],
          ),

          const SizedBox(height: 12),

          // Результат
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: resultColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isDraw ? AppLocalizations.of(context)!.resultDraw : isWin ? AppLocalizations.of(context)!.resultWin : AppLocalizations.of(context)!.resultLoss,
              style: TextStyle(
                color: resultColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(
      List<dynamic> team, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: team.map((player) {
        final p = player as Map<String, dynamic>;
        final name = p['name'] as String? ?? '';
        final initials = p['initials'] as String? ?? '';
        final isLeft = alignment == CrossAxisAlignment.start;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLeft) ...[
                _buildInitialsBadge(initials),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                Flexible(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                _buildInitialsBadge(initials),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInitialsBadge(String initials) {
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
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
