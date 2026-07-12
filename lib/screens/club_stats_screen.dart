import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/club_stats.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/profile/medal.dart';
import '../widgets/verified_badge.dart';
import 'player_profile_screen.dart';

/// Статистика клуба за период: лидерборд игроков (турниров сыграно +
/// заработано рейтинга). Период по умолчанию — текущий месяц.
class ClubStatsScreen extends StatefulWidget {
  final int clubId;
  final String clubName;
  const ClubStatsScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<ClubStatsScreen> createState() => _ClubStatsScreenState();
}

class _ClubStatsScreenState extends State<ClubStatsScreen> {
  static const _accent = AppTheme.accent;

  late DateTimeRange _range;
  bool _loading = true;
  String? _error;
  ClubStatsResult? _data;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day),
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await context.read<ClubService>().getClubStats(
            widget.clubId,
            from: _range.start,
            to: _range.end,
          );
      if (!mounted) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить статистику';
        _loading = false;
      });
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: today,
      initialDateRange: _range,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _accent,
            surface: AppTheme.card,
            onSurface: AppTheme.textPrimary,
          ),
          dialogTheme:
              DialogThemeData(backgroundColor: AppTheme.background),
        ),
        child: child!,
      ),
    );
    if (range != null && mounted) {
      setState(() => _range = DateTimeRange(
            start: DateTime(range.start.year, range.start.month, range.start.day),
            end: DateTime(range.end.year, range.end.month, range.end.day),
          ));
      _load();
    }
  }

  static const _months = [
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];

  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статистика клуба',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.clubName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Выбор периода
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: _rangeButton(),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _rangeButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _accent.withAlpha(22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent.withAlpha(70), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, color: _accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_fmt(_range.start)} — ${_fmt(_range.end)}',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              'Изменить',
              style: TextStyle(color: _accent, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _accent, strokeWidth: 2.5),
      );
    }
    if (_error != null) {
      return _centerInfo(_error!, retry: true);
    }
    final players = _data?.players ?? const <ClubStatsPlayer>[];
    if (players.isEmpty) {
      return _centerInfo('За этот период турниров в клубе не было');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: players.length + 1,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) return _columnsHeader();
        return _playerRow(i, players[i - 1]);
      },
    );
  }

  Widget _centerInfo(String text, {bool retry = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          if (retry) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _load,
              child: const Text('Повторить', style: TextStyle(color: _accent)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _columnsHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4, bottom: 2),
      child: Row(
        children: [
          SizedBox(width: 28),
          SizedBox(width: 50),
          Expanded(child: SizedBox()),
          SizedBox(
            width: 50,
            child: Text('Турниры',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textDim, fontSize: 10.5)),
          ),
          SizedBox(
            width: 50,
            child: Text('Винрейт',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textDim, fontSize: 10.5)),
          ),
          SizedBox(
            width: 54,
            child: Text('Рейтинг',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textDim, fontSize: 10.5)),
          ),
        ],
      ),
    );
  }

  Widget _playerRow(int rank, ClubStatsPlayer p) {
    final earned = p.ratingEarned;
    final earnedColor = earned > 0
        ? AppTheme.accent
        : (earned < 0 ? const Color(0xFFEF4444) : AppTheme.textSecondary);
    final earnedText = earned > 0 ? '+$earned' : '$earned';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PlayerProfileScreen(playerId: p.userId, playerName: p.name),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
        children: [
          // Место — топ-3 медалькой, остальные номером
          SizedBox(
            width: 28,
            child: rank <= 3
                ? Center(child: Medal(place: rank, size: 24))
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          // Аватар / инициалы
          _avatar(p),
          const SizedBox(width: 10),
          // Имя + подпись (уровень · рекорд W-L)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (p.levelVerified) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 13, withTooltip: false),
                    ],
                  ],
                ),
                if (_subtitle(p) != null)
                  Text(
                    _subtitle(p)!,
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
              ],
            ),
          ),
          // Турниры
          SizedBox(
            width: 50,
            child: Text(
              '${p.tournaments}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Винрейт
          SizedBox(
            width: 50,
            child: Text(
              p.matches > 0 ? '${p.winrate}%' : '—',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Заработано рейтинга
          SizedBox(
            width: 54,
            child: Text(
              earnedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: earnedColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        ),
        ),
    );
  }

  Widget _avatar(ClubStatsPlayer p) {
    final url = p.avatar;
    final hasUrl = url != null && url.startsWith('http');
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _accent.withAlpha(30),
        shape: BoxShape.circle,
        image: hasUrl
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasUrl
          ? null
          : Text(
              _initials(p.name),
              style: const TextStyle(
                color: _accent,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  String? _subtitle(ClubStatsPlayer p) {
    final parts = <String>[];
    if (p.level != null) parts.add('Ур. ${p.level!.toStringAsFixed(2)}');
    if (p.matches > 0) parts.add('${p.wins}В·${p.losses}П');
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return '?';
    final list = parts.take(2).map((s) => s[0].toUpperCase()).join();
    return list.isEmpty ? '?' : list;
  }
}
