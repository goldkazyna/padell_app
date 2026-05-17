import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

/// Состояние фильтров экрана турниров.
class TournamentsFilter {
  final bool onlyMyLevel;
  final Set<String> formats;
  final String? dateFilter; // 'today' | 'tomorrow' | 'week' | null
  final Set<int> clubIds;
  final bool onlyCommunity;

  const TournamentsFilter({
    this.onlyMyLevel = false,
    this.formats = const {},
    this.dateFilter,
    this.clubIds = const {},
    this.onlyCommunity = false,
  });

  bool get isEmpty =>
      !onlyMyLevel &&
      formats.isEmpty &&
      dateFilter == null &&
      clubIds.isEmpty &&
      !onlyCommunity;

  TournamentsFilter copyWith({
    bool? onlyMyLevel,
    Set<String>? formats,
    Object? dateFilter = _unset,
    Set<int>? clubIds,
    bool? onlyCommunity,
  }) {
    return TournamentsFilter(
      onlyMyLevel: onlyMyLevel ?? this.onlyMyLevel,
      formats: formats ?? this.formats,
      dateFilter:
          dateFilter == _unset ? this.dateFilter : dateFilter as String?,
      clubIds: clubIds ?? this.clubIds,
      onlyCommunity: onlyCommunity ?? this.onlyCommunity,
    );
  }
}

const _unset = Object();

/// Горизонтальные pills: Все · Уровень · Формат · Дата · Клуб.
class FilterPills extends StatelessWidget {
  final TournamentsFilter filter;
  final VoidCallback onReset;
  final VoidCallback onToggleLevel;
  final VoidCallback onFormatTap;
  final VoidCallback onDateTap;
  final VoidCallback onClubTap;
  final VoidCallback onToggleCommunity;

  const FilterPills({
    super.key,
    required this.filter,
    required this.onReset,
    required this.onToggleLevel,
    required this.onFormatTap,
    required this.onDateTap,
    required this.onClubTap,
    required this.onToggleCommunity,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _pill(
            l.all,
            active: filter.isEmpty,
            onTap: onReset,
          ),
          const SizedBox(width: 6),
          _pill(
            filter.onlyMyLevel ? l.filterMyLevel : l.filterLevel,
            active: filter.onlyMyLevel,
            onTap: onToggleLevel,
          ),
          const SizedBox(width: 6),
          _pill(
            filter.formats.isEmpty
                ? l.filterFormat
                : l.filterFormatWithCount(filter.formats.length),
            active: filter.formats.isNotEmpty,
            onTap: onFormatTap,
          ),
          const SizedBox(width: 6),
          _pill(
            filter.dateFilter == null
                ? l.filterDate
                : _dateLabel(l, filter.dateFilter!),
            active: filter.dateFilter != null,
            onTap: onDateTap,
          ),
          const SizedBox(width: 6),
          _pill(
            filter.clubIds.isEmpty
                ? l.filterClub
                : l.filterClubWithCount(filter.clubIds.length),
            active: filter.clubIds.isNotEmpty,
            onTap: onClubTap,
          ),
          const SizedBox(width: 6),
          _pill(
            l.filterCommunity,
            active: filter.onlyCommunity,
            onTap: onToggleCommunity,
          ),
        ],
      ),
    );
  }

  Widget _pill(String label,
      {required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTheme.accentSoft : const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _dateLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'today':
        return l.today;
      case 'tomorrow':
        return l.filterDateTomorrow;
      case 'week':
        return l.filterDateWeek;
      default:
        return l.filterDate;
    }
  }
}
