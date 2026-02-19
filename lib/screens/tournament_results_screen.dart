import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';

class TournamentResultsScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentResultsScreen({super.key, required this.tournament});

  @override
  State<TournamentResultsScreen> createState() =>
      _TournamentResultsScreenState();
}

class _TournamentResultsScreenState extends State<TournamentResultsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final profileService = context.read<ProfileService>();
    final data = await profileService.getTournamentResults(widget.tournament.id);
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
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, t),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummary(),
                          const SizedBox(height: 24),
                          _buildMatchesSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
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
              _buildCircleButton(
                icon: Icons.chevron_left,
                onTap: () => Navigator.pop(context),
              ),
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
            '${t.dateFormatted} · ${t.club.name}',
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

  Widget _buildSummary() {
    final summary = _data?['summary'] as Map<String, dynamic>?;
    final matchesCount = summary?['matches_count'] ?? 0;
    final wins = summary?['wins'] ?? 0;
    final losses = summary?['losses'] ?? 0;
    final ratingChange = summary?['rating_change'] ?? 0;

    return Row(
      children: [
        _buildSummaryCard('$matchesCount', 'МАТЧЕЙ'),
        const SizedBox(width: 10),
        _buildSummaryCard('$wins / $losses', 'ПОБЕДЫ'),
        const SizedBox(width: 10),
        _buildSummaryCard(
          ratingChange >= 0 ? '+$ratingChange' : '$ratingChange',
          'РЕЙТИНГ',
          valueColor:
              ratingChange >= 0 ? AppTheme.accent : const Color(0xFFEF4444),
        ),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Матчи',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$formatName · $matchesCount раундов',
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
                    ratingChange >= 0 ? '+$ratingChange' : '$ratingChange',
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
              isDraw ? 'НИЧЬЯ' : isWin ? 'ПОБЕДА' : 'ПОРАЖЕНИЕ',
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
