import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

/// Вся динамика рейтинга: каждая точка от первой игры до сегодняшней.
///
/// В карточке профиля помещается только последняя десятка, а вопрос «а что
/// было раньше и с чего я начинал» возникает у всех.
class RatingHistoryScreen extends StatefulWidget {
  const RatingHistoryScreen({super.key});

  @override
  State<RatingHistoryScreen> createState() => _RatingHistoryScreenState();
}

class _RatingHistoryScreenState extends State<RatingHistoryScreen> {
  RatingHistoryData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ProfileService>().getRatingHistory();
      if (mounted) setState(() => _data = data);
    } catch (_) {
      // Экран не пустой ради ошибки: покажем «пока пусто» и кнопку обновить.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: AppBackButton(),
        ),
        centerTitle: true,
        title: const Text(
          'Динамика рейтинга',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : (data == null || data.points.isEmpty)
              ? _empty()
              : RefreshIndicator(
                  color: AppTheme.accent,
                  backgroundColor: AppTheme.card,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    // Первая строка — свод, дальше точки от новых к старым.
                    itemCount: data.points.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) return _summary(data);

                      final point = data.points[data.points.length - i];
                      return _row(point, number: data.points.length - i + 1);
                    },
                  ),
                ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart, size: 40, color: AppTheme.textDim),
            const SizedBox(height: 12),
            Text(
              'Рейтинг пока не менялся',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Сыграйте турнир — здесь появится каждая точка: '
              'что было до, что стало после.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(RatingHistoryData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.current}',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              _delta(data.total, big: true),
              const Spacer(),
              Text(
                '${data.points.length} точек',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat('Начинали с', '${data.start}'),
              _stat('Максимум', '${data.best}'),
              _stat('Минимум', '${data.worst}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _delta(int? delta, {bool big = false}) {
    if (delta == null || delta == 0) {
      return Text(
        '0',
        style: TextStyle(
          color: AppTheme.textDim,
          fontSize: big ? 15 : 14,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }

    final up = delta > 0;
    return Text(
      '${up ? '+' : '−'}${delta.abs()}',
      style: TextStyle(
        color: up ? AppTheme.accent : AppTheme.error,
        fontSize: big ? 15 : 14,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _row(RatingTrendPoint point, {required int number}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Номер точки: видно, сколько всего было и где мы в этом ряду.
          SizedBox(
            width: 26,
            child: Text(
              '$number',
              style: TextStyle(
                color: AppTheme.textDim,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (point.date != null) point.date!,
                    if (point.clubName != null) point.clubName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${point.rating}',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              _delta(point.delta),
            ],
          ),
        ],
      ),
    );
  }
}
