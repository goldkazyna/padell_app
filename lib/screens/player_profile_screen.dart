import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/rating_provider.dart';
import '../providers/settings_provider.dart';
import '../services/rating_service.dart';
import '../theme/app_theme.dart';
import '../utils/rating_formatter.dart';
import '../models/tournament.dart';
import '../utils/tournament_navigation.dart';
import '../services/invitation_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_tab_bar.dart';
import '../widgets/profile/medal.dart';
import '../widgets/profile/player_hero.dart';
import '../widgets/profile/rating_dynamics_card.dart';

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
  bool _inviting = false;

  final _invitationService = InvitationService(ApiService(), StorageService());

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

  Future<void> _openInvite() async {
    setState(() => _inviting = true);
    List<Tournament> tournaments;
    try {
      tournaments =
          await _invitationService.getInvitableTournaments(widget.playerId);
    } catch (_) {
      if (mounted) {
        setState(() => _inviting = false);
        showAppAlert(context, 'Не удалось загрузить турниры',
            title: 'Ошибка', isError: true);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _inviting = false);
    if (tournaments.isEmpty) {
      showAppAlert(context,
          'Нет подходящих активных турниров для этого игрока по его уровню',
          title: 'Турниров нет');
      return;
    }
    _showInviteSheet(tournaments);
  }

  void _showInviteSheet(List<Tournament> tournaments) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Выберите турнир',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: tournaments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _InviteTournamentTile(
                  tournament: tournaments[i],
                  onTap: () => _doInvite(tournaments[i].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doInvite(int tournamentId) async {
    try {
      await _invitationService.invitePlayer(tournamentId, widget.playerId);
      if (mounted) {
        Navigator.pop(context);
        showAppAlert(context, 'Приглашение отправлено игроку', title: 'Готово');
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showAppAlert(context, e.message, title: 'Ошибка', isError: true);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        showAppAlert(context, 'Не удалось отправить приглашение',
            title: 'Ошибка', isError: true);
      }
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
                      Text(_error!, style: TextStyle(color: AppTheme.textSecondary)),
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

          // Кнопка «Позвать на турнир» — зелёный градиент как «История турниров»
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _inviting ? null : _openInvite,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF22C55E), Color(0xFF166534)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: _inviting
                            ? const Padding(
                                padding: EdgeInsets.all(7),
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.emoji_events_rounded,
                                color: Colors.white, size: 19),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Позвать на турнир',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (p.levelVerification != null)
            _buildVerificationCard(p.levelVerification!),
          const SizedBox(height: 8),

          // Карточка «Динамика рейтинга» — данные приходят явно из PlayerProfile.
          RatingDynamicsCard.withData(
            details: p.ratingTrendDetails,
            trend: p.ratingTrend,
          ),

          // History section
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'ИСТОРИЯ РЕЙТИНГА',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary, letterSpacing: 0.5,
              ),
            ),
          ),

          if (p.history.isEmpty)
            Padding(
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

  Widget _buildManualIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x14F59E0B), // амбер с прозрачностью
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.tune_rounded,
        size: 22,
        color: AppTheme.amber,
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
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(
                  Icons.emoji_events_outlined,
                  size: 22,
                  color: AppTheme.textSecondary,
                ),
    );
  }

  Widget _buildHistoryRow(RatingHistoryItem h) {
    final isPositive = h.change >= 0;
    final isManual = h.tournamentId == null;

    return GestureDetector(
      onTap: h.tournamentId != null
          // Открываем тем же роутером, что и в своём профиле, чтобы парный
          // (командный) турнир открывался в нормальном Team-Live экране,
          // а не в старом TournamentResultsScreen.
          ? () => openTournamentLiveByType(
                context,
                tournamentId: h.tournamentId!,
                tournamentType: h.tournamentType ?? 'americano',
                highlightPlayerId: widget.playerId,
              )
          : null,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1A1A1E), width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            isManual ? _buildManualIcon() : _buildPlaceIcon(h.place),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.tournamentName,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    h.date,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (h.tournamentId != null)
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF3F3F46)),
            if (!h.isRated)
              Builder(builder: (ctx) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    AppLocalizations.of(ctx)!.unratedBadge,
                    style: TextStyle(
                      color: AppTheme.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              })
            else
              Builder(builder: (ctx) {
                final precise = ctx.watch<SettingsProvider>().preciseRating;
                return SizedBox(
                  width: precise ? 80 : 50,
                  child: Text(
                    RatingFormatter.formatRatingChange(h.change, precise, decimals: 4),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: isPositive ? AppTheme.accent : const Color(0xFFEF4444),
                    ),
                  ),
                );
              }),
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
            Icon(Icons.verified_outlined,
                color: AppTheme.blue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                      style: TextStyle(
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

/// Плитка турнира в листе «Позвать на турнир».
class _InviteTournamentTile extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;
  const _InviteTournamentTile({required this.tournament, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${t.club.name} · ${t.dateShort}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Уровень ${t.levelText}',
                      style: TextStyle(
                          color: AppTheme.textDim, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Позвать',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
