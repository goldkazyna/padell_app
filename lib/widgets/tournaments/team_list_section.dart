import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';

class TeamListSection extends StatelessWidget {
  final Tournament tournament;
  final int? currentUserId;

  static const Color _pendingColor = Color(0xFFF59E0B);

  const TeamListSection({
    super.key,
    required this.tournament,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final pending = tournament.teams.where((t) => t.isPending).toList();
    final approved = tournament.teams.where((t) => t.isApproved).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending teams
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'На модерации',
                style: TextStyle(
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
            child: _buildTeamRow(team: team, isPending: true),
          )),
          const SizedBox(height: 24),
        ],

        // Approved teams
        Row(
          children: [
            const Text(
              'Команды',
              style: TextStyle(
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
              '${tournament.participantsCount} из ${tournament.maxParticipants}',
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
            child: const Center(
              child: Text(
                'Пока нет команд',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          )
        else
          ...List.generate(approved.length, (index) {
            final team = approved[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildTeamRow(team: team, isPending: false, index: index + 1),
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
                    'Ещё ${tournament.spotsLeft} свободных мест',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamRow({
    required TournamentTeam team,
    required bool isPending,
    int? index,
  }) {
    final isMyTeam = _isMyTeam(team);
    final Color bgColor;
    final Color borderColor;

    if (isPending) {
      bgColor = _pendingColor.withAlpha(15);
      borderColor = _pendingColor.withAlpha(60);
    } else if (isMyTeam) {
      bgColor = AppTheme.accent.withAlpha(15);
      borderColor = AppTheme.accent.withAlpha(60);
    } else {
      bgColor = AppTheme.card;
      borderColor = const Color(0xFF2A2A2A);
    }

    final Color primaryColor = isPending ? _pendingColor : (isMyTeam ? AppTheme.accent : AppTheme.textPrimary);
    final Color secondaryColor = isPending ? _pendingColor : (isMyTeam ? AppTheme.accent.withAlpha(180) : AppTheme.textSecondary);
    final Color avatarBg = isPending ? _pendingColor : (isMyTeam ? AppTheme.accent : const Color(0xFF2A2A2A));

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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: _pendingColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ожидание',
                      style: TextStyle(
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
    return Row(
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
              Text(
                player.name,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                player.levelText,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Rating
        Text(
          '${player.rating}',
          style: TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
