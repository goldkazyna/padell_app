import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match.dart';
import '../../screens/rating_history_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/profile_service.dart';
import '../../utils/rating_formatter.dart';
import 'rating_sparkline.dart';

/// Карточка «Динамика рейтинга».
/// Показывает:
///   - текущий рейтинг + дельту выбранной точки (по умолчанию — последней)
///   - sparkline по последним до 10 турнирам с кликабельными точками
///   - блок последних до 15 матчей (W/L цветными ячейками)
///
/// По умолчанию (без параметров) берёт данные из ProfileProvider —
/// используется в экране своего профиля. Если параметры переданы —
/// рисует переданные данные (для чужого профиля).
class RatingDynamicsCard extends StatefulWidget {
  /// Подробности 10 последних точек (название турнира, клуб, дата).
  /// Если пуст — fallback на `ratingTrend`.
  final List<RatingTrendPoint>? ratingTrendDetails;

  /// Простой массив значений рейтинга — fallback если details не пришли.
  final List<int>? ratingTrend;

  /// Последние 15 матчей пользователя. Может быть пуст —
  /// тогда блок матчей не показывается.
  final List<Match>? recentMatches;

  const RatingDynamicsCard({
    super.key,
    this.ratingTrendDetails,
    this.ratingTrend,
    this.recentMatches,
  });

  /// Удобный конструктор: данные приходят явно (используется в чужом
  /// профиле PlayerProfileScreen).
  const RatingDynamicsCard.withData({
    super.key,
    required List<RatingTrendPoint> details,
    required List<int> trend,
    List<Match> matches = const [],
  })  : ratingTrendDetails = details,
        ratingTrend = trend,
        recentMatches = matches;

  @override
  State<RatingDynamicsCard> createState() => _RatingDynamicsCardState();
}

class _RatingDynamicsCardState extends State<RatingDynamicsCard> {
  int? _selectedIdx;

  static const _bg = Color(0xFF1C1C21);
  static const _border = Color(0x14FFFFFF);
  static const _text = Color(0xFFF3F3F5);
  static const _muted = Color(0xFFA2A2AB);
  static const _dim = Color(0xFF6A6A73);
  static const _green = Color(0xFF22C47A);
  static const _red = Color(0xFFEF4444);
  static const _yellow = Color(0xFFEAB308);

  @override
  Widget build(BuildContext context) {
    // Если данные переданы явно — используем их (чужой профиль).
    // Иначе берём из ProfileProvider (свой профиль).
    if (widget.ratingTrendDetails != null || widget.ratingTrend != null) {
      final details = widget.ratingTrendDetails ?? const <RatingTrendPoint>[];
      final trend = details.isNotEmpty
          ? details.map((d) => d.rating).toList()
          : (widget.ratingTrend ?? const <int>[]);
      final matches = (widget.recentMatches ?? const <Match>[]).take(15).toList();
      return _build(context, details, trend, matches);
    }

    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final stats = profile.statistics;
        final details = stats?.ratingTrendDetails ?? const <RatingTrendPoint>[];
        // Если есть подробности — используем их (с названиями и датами).
        // Иначе fallback на простой массив значений rating_trend.
        final trend = details.isNotEmpty
            ? details.map((d) => d.rating).toList()
            : (stats?.ratingTrend ?? const <int>[]);
        final allMatches = profile.matches;
        final matches = allMatches.take(15).toList();
        return _build(context, details, trend, matches);
      },
    );
  }

  Widget _build(
    BuildContext context,
    List<RatingTrendPoint> details,
    List<int> trend,
    List<Match> matches,
  ) {
    if (trend.isEmpty && matches.isEmpty) {
      return const SizedBox.shrink();
    }

        // Выбранная точка (по умолчанию — последняя)
        final selectedIdx = (_selectedIdx ?? (trend.length - 1))
            .clamp(0, trend.isEmpty ? 0 : trend.length - 1);
        final value = trend.isNotEmpty ? trend[selectedIdx] : 0;
        // Дельта для выбранной точки: из details если есть, иначе считаем
        // относительно предыдущей точки.
        int? delta;
        if (details.isNotEmpty && selectedIdx < details.length) {
          delta = details[selectedIdx].delta;
        } else if (trend.length >= 2 && selectedIdx >= 1) {
          delta = trend[selectedIdx] - trend[selectedIdx - 1];
        }
        final selectedDetails =
            details.isNotEmpty && selectedIdx < details.length
                ? details[selectedIdx]
                : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, value, delta),
                if (selectedDetails != null) ...[
                  const SizedBox(height: 6),
                  _buildSelectedInfo(selectedDetails),
                ],
                if (trend.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildChart(trend, selectedIdx),
                ],
                if (matches.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: _border, width: 1),
                      ),
                    ),
                    child: _buildMatches(matches),
                  ),
                ],
              ],
            ),
          ),
        );
  }

  Widget _buildHeader(BuildContext context, int value, int? delta) {
    final precise = context.watch<SettingsProvider>().preciseRating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'ДИНАМИКА РЕЙТИНГА',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _dim,
                ),
              ),
            ),
            // Только в своём профиле: чужую историю целиком мы не отдаём.
            if (widget.ratingTrendDetails == null)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RatingHistoryScreen(),
                  ),
                ),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.ratingAllDynamics,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _green,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: _green),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              precise
                  ? RatingFormatter.formatRating(value, true)
                  : _formatRating(value),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.0,
                color: _text,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            if (delta != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      delta >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: delta >= 0 ? _green : _red,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      RatingFormatter.formatRatingChange(delta, precise, decimals: 4),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: delta >= 0 ? _green : _red,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedInfo(RatingTrendPoint p) {
    // Формат: «Название турнира — Клуб — Дата»
    final parts = <String>[p.name];
    if (p.clubName != null && p.clubName!.isNotEmpty) parts.add(p.clubName!);
    if (p.date != null && p.date!.isNotEmpty) parts.add(p.date!);
    final text = parts.join(' — ');
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _muted,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildChart(List<int> trend, int selectedIdx) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RatingSparkline(
          trend: trend,
          selectedIdx: selectedIdx,
          green: _green,
          card: _bg,
          size: Size(constraints.maxWidth, 96),
          onPick: (i) => setState(() => _selectedIdx = i),
        );
      },
    );
  }

  Widget _buildMatches(List<Match> matches) {
    // С бэка matches идут desc (новые первыми). Чтобы соответствовать
    // подписям («N матчей назад» слева, «сейчас» справа) — переворачиваем:
    // слева самые старые, справа — последний сыгранный.
    final ordered = matches.reversed.toList();
    final wins = ordered.where((m) => m.isWin).length;
    final draws = ordered.where((m) => m.isDraw).length;
    final losses = ordered.length - wins - draws;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ПОСЛЕДНИЕ ${ordered.length} МАТЧЕЙ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: _dim,
              ),
            ),
            Text(
              draws > 0 ? '$wins В · $losses П · $draws Н' : '$wins В · $losses П',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _muted,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < ordered.length; i++) ...[
              Expanded(
                child: Container(
                  height: 26,
                  margin: EdgeInsets.only(
                    right: i == ordered.length - 1 ? 0 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: (ordered[i].isDraw
                            ? _yellow
                            : (ordered[i].isWin ? _green : _red))
                        .withAlpha(220),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ordered[i].isDraw
                        ? 'Н'
                        : (ordered[i].isWin ? 'В' : 'П'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: ordered[i].isWin || ordered[i].isDraw
                          ? const Color(0xFF06281A)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${ordered.length} матчей назад',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _dim,
              ),
            ),
            const Text(
              'сейчас',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _dim,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Форматировать рейтинг с пробелом-разделителем тысяч.
  static String _formatRating(int v) {
    final s = v.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
