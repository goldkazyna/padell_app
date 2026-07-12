import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../utils/tournament_type_l10n.dart';

/// Карточка «героя» турнира в секции «Для вас» — V2 дизайн.
///
/// Layout:
///   [дата · день · время]                    [кнопка]
///   Название турнира
///   Формат · Цена
///   ┌── Уровень турнира          ✓ Подходит ──┐
///   │ ━━━━━━━━━━[━━━━●━━━━]━━━━━━━━━           │
///   │ 1.25     вы 2.50    3.50                 │
///   └──────────────────────────────────────────┘
///   ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  ⚠ 2 из 16
class HeroTournamentCard extends StatelessWidget {
  final Tournament tournament;
  final double? userLevel;
  final VoidCallback onTap;

  const HeroTournamentCard({
    super.key,
    required this.tournament,
    required this.userLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final full = tournament.isFull;
    final inRange = userLevel != null && tournament.isInLevelRange(userLevel);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: full
                ? AppTheme.error.withValues(alpha: 0.18)
                : AppTheme.border,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Date+day+time row + action button
            _buildTopRow(context, full),
            const SizedBox(height: 10),

            // 2) Title
            Text(
              tournament.name,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // 3) Format · price
            _buildMetaRow(context),

            const SizedBox(height: 10),

            // 4) Level fit indicator (с шкалой 1.0–5.0)
            _buildLevelFit(context, inRange),

            const SizedBox(height: 8),

            // 5) Spots bar + text
            _buildSpotsRow(full),
          ],
        ),
      ),
    );
  }

  // ===== Top row: date+day+time + button =====
  Widget _buildTopRow(BuildContext context, bool full) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateShort = DateFormat('d MMM', locale).format(tournament.datetime);
    final dowShort = DateFormat.E(locale).format(tournament.datetime);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                dateShort,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                dowShort.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                tournament.time,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildActionButton(context, full),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool full) {
    final l = AppLocalizations.of(context)!;
    if (tournament.isRegistered) {
      return _pillButton(
        text: l.youAreParticipating,
        bg: AppTheme.accentSoft,
        fg: AppTheme.accent,
      );
    }

    if (full) {
      return _pillButton(
        text: tournament.isSubscribed ? l.subscribedButton : l.notifyButton,
        bg: AppTheme.blue.withValues(alpha: 0.16),
        fg: AppTheme.blue,
        icon: Icons.notifications_outlined,
      );
    }

    return _pillButton(
      text: l.registerButton,
      bg: AppTheme.accent,
      fg: const Color(0xFF0A0A0D),
    );
  }

  Widget _pillButton({
    required String text,
    required Color bg,
    required Color fg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Meta row: format · price =====
  Widget _buildMetaRow(BuildContext context) {
    final fmt = _formatChipColors(tournament.formatColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
      children: [
        Text(
          localizeTournamentType(context, tournament.type, fallback: tournament.typeName),
          style: TextStyle(
            color: fmt.fg,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (tournament.price > 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '·',
              style: TextStyle(color: AppTheme.textDim, fontSize: 12),
            ),
          ),
          Text(
            tournament.priceTextCompact,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
        ),
        if (tournament.venueClubName != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.place_outlined,
                  size: 13, color: AppTheme.textDim),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  tournament.venueClubName!,
                  style:
                      TextStyle(color: AppTheme.textDim, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ===== Level fit indicator with absolute scale 1.0–5.0 =====
  Widget _buildLevelFit(BuildContext context, bool inRange) {
    final l = AppLocalizations.of(context)!;
    final ok = inRange;
    final boxColor = ok
        ? AppTheme.accent.withValues(alpha: 0.08)
        : AppTheme.error.withValues(alpha: 0.07);
    final borderColor = ok
        ? AppTheme.accent.withValues(alpha: 0.18)
        : AppTheme.error.withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Head: "Уровень турнира" + статус
          Row(
            children: [
              Text(
                l.tournamentLevelLabel,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                ok ? Icons.check_circle : Icons.error_outline,
                size: 14,
                color: ok ? AppTheme.accent : const Color(0xFFFCA7A2),
              ),
              const SizedBox(width: 4),
              Text(
                userLevel == null
                    ? '${tournament.minLevel.toStringAsFixed(2)}–${tournament.maxLevel.toStringAsFixed(2)}'
                    : (ok ? l.levelSuits : l.levelDoesNotSuit),
                style: TextStyle(
                  color: ok ? AppTheme.accent : const Color(0xFFFCA7A2),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Scale 1.0–5.0
          _LevelScale(
            minLevel: tournament.minLevel,
            maxLevel: tournament.maxLevel,
            userLevel: userLevel,
            inRange: ok,
          ),
          const SizedBox(height: 4),

          // Numbers под шкалой
          Row(
            children: [
              Text(
                tournament.minLevel.toStringAsFixed(2),
                style: TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              if (userLevel != null)
                Text(
                  l.yourLevelMark(userLevel!.toStringAsFixed(2)),
                  style: TextStyle(
                    color: ok
                        ? AppTheme.textPrimary
                        : const Color(0xFFFCA7A2),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              const Spacer(),
              Text(
                tournament.maxLevel.toStringAsFixed(2),
                style: TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Spots row =====
  Widget _buildSpotsRow(bool full) {
    final fraction = tournament.maxParticipants > 0
        ? tournament.participantsCount / tournament.maxParticipants
        : 0.0;
    final spotsLeft = tournament.spotsLeft;
    final amberClose = !full && spotsLeft > 0 && spotsLeft <= 2;

    final barColor = full
        ? AppTheme.error
        : amberClose
            ? AppTheme.amber
            : AppTheme.accent;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) => Container(
                    width: c.maxWidth * fraction.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (full)
          Text(
            'мест нет',
            style: TextStyle(
              color: AppTheme.error,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          )
        else if (amberClose)
          Text(
            '⚠ ${tournament.participantsCount} из ${tournament.maxParticipants}',
            style: TextStyle(
              color: AppTheme.amber,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
        else
          Text(
            '${tournament.participantsCount} из ${tournament.maxParticipants}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );
  }
}

/// Шкала уровня 1.0–5.0 с подсветкой диапазона турнира и маркером юзера.
class _LevelScale extends StatelessWidget {
  final double minLevel;
  final double maxLevel;
  final double? userLevel;
  final bool inRange;

  const _LevelScale({
    required this.minLevel,
    required this.maxLevel,
    required this.userLevel,
    required this.inRange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          // Шкала 1.0–5.0 = 4 единицы
          double pct(double level) =>
              ((level.clamp(1.0, 5.0) - 1.0) / 4.0) * width;

          final rangeLeft = pct(minLevel);
          final rangeWidth = pct(maxLevel) - rangeLeft;
          final markerLeft =
              userLevel == null ? null : pct(userLevel!.clamp(1.0, 5.0));

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Track (фон шкалы)
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x0FFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Range (диапазон уровня турнира)
              Positioned(
                left: rangeLeft,
                width: rangeWidth.clamp(0.0, width),
                top: 4,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: inRange
                        ? AppTheme.accent
                        : const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // User marker
              if (markerLeft != null)
                Positioned(
                  left: markerLeft - 7,
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: inRange ? Colors.white : AppTheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.card,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FmtChipColors {
  final Color bg;
  final Color fg;
  const _FmtChipColors(this.bg, this.fg);
}

_FmtChipColors _formatChipColors(TournamentFormatColor color) {
  switch (color) {
    case TournamentFormatColor.blue:
      return _FmtChipColors(
        AppTheme.blue.withValues(alpha: 0.15),
        const Color(0xFF7AA8F8),
      );
    case TournamentFormatColor.purple:
      return _FmtChipColors(
        AppTheme.purple.withValues(alpha: 0.15),
        const Color(0xFFB3A7F8),
      );
    case TournamentFormatColor.orange:
      return _FmtChipColors(
        AppTheme.orange.withValues(alpha: 0.15),
        const Color(0xFFF5A37A),
      );
  }
}
