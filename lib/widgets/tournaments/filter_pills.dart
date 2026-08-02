import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

/// Состояние фильтров экрана турниров.
class TournamentsFilter {
  final bool onlyMyLevel;
  final Set<String> formats;
  final String? dateFilter; // 'today' | 'tomorrow' | 'week' | null
  final DateTime? dateFrom; // свой диапазон (начало), взаимоисключим с dateFilter
  final DateTime? dateTo; // свой диапазон (конец)
  final Set<int> clubIds;
  final Set<String> cities;
  final bool onlyCommunity;

  const TournamentsFilter({
    this.onlyMyLevel = false,
    this.formats = const {},
    this.dateFilter,
    this.dateFrom,
    this.dateTo,
    this.clubIds = const {},
    this.cities = const {},
    this.onlyCommunity = false,
  });

  bool get isEmpty =>
      !onlyMyLevel &&
      formats.isEmpty &&
      dateFilter == null &&
      dateFrom == null &&
      clubIds.isEmpty &&
      cities.isEmpty &&
      !onlyCommunity;

  bool get hasDateRange => dateFrom != null && dateTo != null;

  TournamentsFilter copyWith({
    bool? onlyMyLevel,
    Set<String>? formats,
    Object? dateFilter = _unset,
    Object? dateFrom = _unset,
    Object? dateTo = _unset,
    Set<int>? clubIds,
    Set<String>? cities,
    bool? onlyCommunity,
  }) {
    return TournamentsFilter(
      onlyMyLevel: onlyMyLevel ?? this.onlyMyLevel,
      formats: formats ?? this.formats,
      dateFilter:
          dateFilter == _unset ? this.dateFilter : dateFilter as String?,
      dateFrom: dateFrom == _unset ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _unset ? this.dateTo : dateTo as DateTime?,
      clubIds: clubIds ?? this.clubIds,
      cities: cities ?? this.cities,
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
  final VoidCallback onCityTap;

  const FilterPills({
    super.key,
    required this.filter,
    required this.onReset,
    required this.onToggleLevel,
    required this.onFormatTap,
    required this.onDateTap,
    required this.onClubTap,
    required this.onToggleCommunity,
    required this.onCityTap,
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
            filter.hasDateRange
                ? _rangeLabel(filter.dateFrom!, filter.dateTo!)
                : (filter.dateFilter == null
                    ? l.filterDate
                    : _dateLabel(l, filter.dateFilter!)),
            active: filter.dateFilter != null || filter.hasDateRange,
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
          const SizedBox(width: 6),
          _pill(
            filter.cities.isEmpty
                ? l.filterCity
                : l.filterCityWithCount(filter.cities.length),
            active: filter.cities.isNotEmpty,
            onTap: onCityTap,
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

  String _rangeLabel(DateTime from, DateTime to) {
    String f(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    return '${f(from)} – ${f(to)}';
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
