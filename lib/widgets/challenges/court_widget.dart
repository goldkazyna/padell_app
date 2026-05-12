import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/challenge.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/rating_formatter.dart';

class CourtWidget extends StatelessWidget {
  final List<ChallengePlayer> players;
  final String status;
  final int? myUserId;
  final bool isEditing;
  final Function(int position)? onPositionTap;

  const CourtWidget({
    super.key,
    required this.players,
    required this.status,
    this.myUserId,
    this.isEditing = false,
    this.onPositionTap,
  });

  ChallengePlayer? _playerAt(int position) {
    try {
      return players.firstWhere((p) => p.position == position);
    } catch (_) {
      return null;
    }
  }

  bool get _isCompleted => status == 'completed';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Scale avatar based on available width, min 40, max 56
        final avatarSize = (availableWidth * 0.13).clamp(40.0, 56.0);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.accent.withAlpha(20),
                AppTheme.accent.withAlpha(8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accent.withAlpha(77),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              // Court area with divider
              IntrinsicHeight(
                child: Row(
                  children: [
                    // Team A
                    Expanded(
                      child: _buildTeamColumn(
                        context: context,
                        positions: [1, 2],
                        avatarSize: avatarSize,
                      ),
                    ),
                    // Center divider with label
                    _buildDivider(context),
                    // Team B
                    Expanded(
                      child: _buildTeamColumn(
                        context: context,
                        positions: [3, 4],
                        avatarSize: avatarSize,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Team labels
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.challengeTeamA,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.accent.withAlpha(102),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.challengeTeamB,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.accent.withAlpha(102),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical line
          Positioned.fill(
            child: Center(
              child: Container(
                width: 1,
                color: AppTheme.accent.withAlpha(51),
              ),
            ),
          ),
          // "СЕТКА" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(38),
              borderRadius: BorderRadius.circular(4),
            ),
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                AppLocalizations.of(context)!.courtNet,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn({
    required BuildContext context,
    required List<int> positions,
    required double avatarSize,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerSlot(context, positions[0], avatarSize),
        const SizedBox(height: 16),
        _buildPlayerSlot(context, positions[1], avatarSize),
      ],
    );
  }

  Widget _buildPlayerSlot(BuildContext context, int position, double avatarSize) {
    final player = _playerAt(position);
    final isFilled = player != null;
    final isMe = player?.isMe ?? false;

    return GestureDetector(
      onTap: (!isFilled || isEditing) && onPositionTap != null
          ? () => onPositionTap!(position)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: isFilled
                  ? _getAvatarColor(player)
                  : AppTheme.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(avatarSize * 0.27),
              border: Border.all(
                color: _getAvatarBorderColor(isFilled, isMe),
                width: isMe ? 2 : (isFilled ? 0 : 1),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: isFilled
                ? (player.avatar != null
                    ? Image.network(
                        player.avatar!,
                        fit: BoxFit.cover,
                        width: avatarSize,
                        height: avatarSize,
                        errorBuilder: (_, __, ___) => Text(
                          player.initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: avatarSize * 0.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        player.initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: avatarSize * 0.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ))
                : Icon(
                    Icons.person_add,
                    color: AppTheme.accent,
                    size: avatarSize * 0.38,
                  ),
          ),
          const SizedBox(height: 6),
          // Name or placeholder
          SizedBox(
            width: avatarSize + 24,
            child: isFilled
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: player.fullName.split(' ').map((word) => Text(
                      word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )).toList(),
                  )
                : Text(
                    isEditing ? AppLocalizations.of(context)!.courtInvite : AppLocalizations.of(context)!.courtFreeSlot,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          // Rating or rating change
          if (isFilled) _buildRatingLabel(context, player),
        ],
      ),
    );
  }

  Color _getAvatarColor(ChallengePlayer? player) {
    if (player == null) return AppTheme.accent.withAlpha(25);
    if (player.isPending || player.isInvited) return const Color(0xFFEAB308); // yellow
    return AppTheme.accent;
  }

  Color _getAvatarBorderColor(bool isFilled, bool isMe) {
    if (!isFilled) return AppTheme.accent.withAlpha(77);
    if (isMe) return Colors.white;
    return Colors.transparent;
  }

  Widget _buildRatingLabel(BuildContext context, ChallengePlayer player) {
    if (_isCompleted && player.ratingChange != null) {
      final change = player.ratingChange!;
      final isPositive = change >= 0;
      final precise = context.watch<SettingsProvider>().preciseRating;
      return Text(
        RatingFormatter.formatRatingChange(change, precise),
        style: TextStyle(
          color: isPositive ? AppTheme.accent : AppTheme.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final precise = context.watch<SettingsProvider>().preciseRating;
    return Text(
      RatingFormatter.formatRating(player.rating, precise),
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
