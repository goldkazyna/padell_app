import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';
import '../../screens/player_profile_screen.dart';
import '../../utils/rating_formatter.dart';
import '../verified_badge.dart';

class TeamListSection extends StatelessWidget {
  final Tournament tournament;
  final int? currentUserId;

  static const Color _pendingColor = Color(0xFFF59E0B);
  static const Color _waitlistColor = AppTheme.blue;

  const TeamListSection({
    super.key,
    required this.tournament,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pending = tournament.teams.where((t) => t.isPending).toList();
    final approved = tournament.teams.where((t) => t.isApproved).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending teams
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              Text(
                l10n.pendingModeration,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(pending.length, _pendingColor),
            ],
          ),
          const SizedBox(height: 12),
          ...pending.map((team) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildTeamRow(context: context, team: team, isPending: true),
          )),
          const SizedBox(height: 24),
        ],

        // Approved teams
        Row(
          children: [
            Text(
              l10n.teams,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (approved.isNotEmpty) ...[
              const SizedBox(width: 8),
              _buildCountBadge(approved.length, AppTheme.accent),
            ],
            const Spacer(),
            Text(
              l10n.countOfMax(tournament.participantsCount, tournament.maxParticipants),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (approved.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
            ),
            child: Center(
              child: Text(
                l10n.noTeamsYet,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          )
        else
          ...List.generate(approved.length, (index) {
            final team = approved[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildTeamRow(context: context, team: team, isPending: false, index: index + 1),
            );
          }),

        // Spots left
        if (tournament.spotsLeft > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.textSecondary, width: 1),
                    ),
                    child: const Icon(Icons.add, color: AppTheme.textSecondary, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.spotsLeftCount(tournament.spotsLeft),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Лист ожидания
        if (tournament.waitlistTeams.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Лист ожидания',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(tournament.waitlistTeams.length, _waitlistColor),
              const Spacer(),
              if (tournament.waitlistSize > 0)
                Text(
                  '${tournament.waitlistTeams.length} / ${tournament.waitlistSize} пар',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(tournament.waitlistTeams.length, (index) {
            final team = tournament.waitlistTeams[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildTeamRow(
                context: context,
                team: team,
                isPending: false,
                isWaitlist: true,
                index: index + 1,
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTeamRow({
    required BuildContext context,
    required TournamentTeam team,
    required bool isPending,
    bool isWaitlist = false,
    int? index,
  }) {
    final isMyTeam = _isMyTeam(team);
    final Color bgColor;
    final Color borderColor;

    if (isPending) {
      bgColor = _pendingColor.withAlpha(15);
      borderColor = _pendingColor.withAlpha(60);
    } else if (isWaitlist) {
      bgColor = _waitlistColor.withAlpha(15);
      borderColor = _waitlistColor.withAlpha(60);
    } else if (isMyTeam) {
      bgColor = AppTheme.accent.withAlpha(15);
      borderColor = AppTheme.accent.withAlpha(60);
    } else {
      bgColor = AppTheme.card;
      borderColor = const Color(0xFF2A2A2A);
    }

    final Color primaryColor = isPending
        ? _pendingColor
        : isWaitlist
            ? _waitlistColor
            : (isMyTeam ? AppTheme.accent : AppTheme.textPrimary);
    final Color secondaryColor = isPending
        ? _pendingColor
        : isWaitlist
            ? _waitlistColor.withAlpha(180)
            : (isMyTeam ? AppTheme.accent.withAlpha(180) : AppTheme.textSecondary);
    final Color avatarBg = isPending
        ? _pendingColor
        : isWaitlist
            ? _waitlistColor
            : (isMyTeam ? AppTheme.accent : const Color(0xFF2A2A2A));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          // Player 1
          _buildPlayerLine(
            player: team.player1,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            avatarBg: avatarBg,
            leading: isPending ? '–' : '${index ?? 0}',
          ),
          if (team.player2 != null) ...[
            const SizedBox(height: 8),
            // Player 2
            _buildPlayerLine(
              player: team.player2!,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              avatarBg: avatarBg,
            ),
          ],
          // Pending badge
          if (isPending) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _pendingColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _pendingColor.withAlpha(60), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, color: _pendingColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.pendingStatus,
                      style: const TextStyle(
                        color: _pendingColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (isWaitlist) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _waitlistColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _waitlistColor.withAlpha(60), width: 0.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_bottom, color: _waitlistColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'В очереди',
                      style: TextStyle(
                        color: _waitlistColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerLine({
    required TournamentTeamPlayer player,
    required Color primaryColor,
    required Color secondaryColor,
    required Color avatarBg,
    String? leading,
  }) {
    return Builder(builder: (context) => GestureDetector(
      onTap: player.id > 0
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerProfileScreen(
                    playerId: player.id,
                    playerName: player.name,
                  ),
                ),
              )
          : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
      children: [
        // Index or spacing
        SizedBox(
          width: 24,
          child: leading != null
              ? Text(
                  leading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 10),

        // Avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: avatarBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              player.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Name + level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (player.levelVerified) ...[
                    const SizedBox(width: 5),
                    const VerifiedBadge(size: 11),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Builder(builder: (ctx) {
                final precise = ctx.watch<SettingsProvider>().preciseRating;
                return Text(
                  RatingFormatter.formatLevelLabel(
                    bucketedLevel: player.level,
                    rating: player.rating,
                    precise: precise,
                  ),
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12,
                  ),
                );
              }),
            ],
          ),
        ),

        // Rating
        Builder(builder: (ctx) {
          final precise = ctx.watch<SettingsProvider>().preciseRating;
          return Text(
            RatingFormatter.formatRating(player.rating, precise),
            style: TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ],
    ),
    ));
  }

  bool _isMyTeam(TournamentTeam team) {
    if (currentUserId == null) return false;
    return team.player1.id == currentUserId ||
        (team.player2 != null && team.player2!.id == currentUserId);
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
