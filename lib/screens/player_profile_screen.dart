import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rating_provider.dart';
import '../services/rating_service.dart';
import '../theme/app_theme.dart';
import 'tournament_results_screen.dart';
import 'tournament_live_kingofcourt_screen.dart';
import '../models/tournament.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_tab_bar.dart';
import '../widgets/profile/medal.dart';
import '../widgets/profile/player_hero.dart';

class PlayerProfileScreen extends StatefulWidget {
  final int playerId;
  final String playerName;

  const PlayerProfileScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  PlayerProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });

    final result = await context.read<RatingProvider>().service.getPlayer(widget.playerId);

    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _profile = result;
        } else {
          _error = 'Не удалось загрузить профиль';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: Text(
          widget.playerName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: AppTheme.accent,
                  child: _buildContent(),
                ),
      bottomNavigationBar: const MainTabBar(),
    );
  }

  Widget _buildContent() {
    final p = _profile!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerHero(
            userId: p.id,
            name: p.name,
            avatar: p.avatar,
            initials: p.initials,
            rating: p.rating,
            rank: p.place > 0 ? p.place : null,
            level: p.level,
            levelVerified: p.levelVerified,
            trend: p.ratingTrend,
            matchesPlayed: p.matchesPlayed,
            wins: p.wins,
            winrate: p.winrate,
            tournamentsCount: p.tournamentsCount,
          ),
          if (p.levelVerification != null)
            _buildVerificationCard(p.levelVerification!),
          const SizedBox(height: 8),

          // History section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'ИСТОРИЯ РЕЙТИНГА',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary, letterSpacing: 0.5,
              ),
            ),
          ),

          if (p.history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Нет данных', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            ...p.history.map((h) => _buildHistoryRow(h)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPlaceIcon(int? place) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: (place != null && place >= 1 && place <= 3)
          ? Medal(place: place, size: 32)
          : (place != null && place > 3)
              ? Text(
                  '$place',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : const Icon(
                  Icons.emoji_events_outlined,
                  size: 22,
                  color: AppTheme.textSecondary,
                ),
    );
  }

  Widget _buildHistoryRow(RatingHistoryItem h) {
    final isPositive = h.change >= 0;

    return GestureDetector(
      onTap: h.tournamentId != null
          ? () {
              // Минимальный Tournament для экрана результатов
              final dateParts = h.date.split('.');
              DateTime parsedDate;
              try {
                parsedDate = DateTime(
                  int.parse(dateParts[2]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[0]),
                );
              } catch (_) {
                parsedDate = DateTime.now();
              }

              final tournament = Tournament(
                id: h.tournamentId!,
                name: h.tournamentName,
                club: Club(id: 0, name: ''),
                date: h.date,
                time: '',
                datetime: parsedDate,
                type: h.tournamentType ?? 'americano',
                typeName: '',
                status: 'completed',
                statusName: '',
                minLevel: 0,
                maxLevel: 0,
                price: 0,
                maxParticipants: 0,
                participantsCount: 0,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => tournament.type == 'king_of_court'
                      ? TournamentLiveKingOfCourtScreen(
                          tournamentId: tournament.id,
                          highlightPlayerId: widget.playerId,
                        )
                      : TournamentResultsScreen(tournament: tournament, playerId: widget.playerId),
                ),
              );
            }
          : null,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildPlaceIcon(h.place),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.tournamentName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    h.date,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (h.tournamentId != null)
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF3F3F46)),
            SizedBox(
              width: 50,
              child: Text(
                '${isPositive ? '+' : ''}${h.change}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: isPositive ? AppTheme.accent : const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(LevelVerification v) {
    final pieces = <String>[];
    if (v.verifiedByName.isNotEmpty) pieces.add(v.verifiedByName);
    if ((v.clubName ?? '').isNotEmpty) pieces.add(v.clubName!);
    if (v.verifiedAt != null) pieces.add(_fmtDate(v.verifiedAt!));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x144A8BF5), // accent blue с прозрачностью
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.blue.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined,
                color: AppTheme.blue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Уровень подтверждён',
                    style: TextStyle(
                      color: AppTheme.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (pieces.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      pieces.join(' · '),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final local = d.toLocal();
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hh:$mi';
  }
}
