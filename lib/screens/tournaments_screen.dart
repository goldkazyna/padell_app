import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/tournament.dart';
import '../providers/home_provider.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournaments/club_section_header.dart';
import '../widgets/tournaments/filter_pills.dart';
import '../widgets/tournaments/hero_tournament_card.dart';
import '../widgets/tournaments/tournament_row_v2.dart';
import 'tournament_detail_screen.dart';
import 'tournament_stats_screen.dart';
import 'tournament_live_kingofcourt_screen.dart';
import 'tournament_live_bali_koc_screen.dart';
import 'club_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  final int? initialClubId;

  const TournamentsScreen({super.key, this.initialClubId});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  int _tabIndex = 0;
  late TournamentsFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialClubId != null
        ? TournamentsFilter(clubIds: {widget.initialClubId!})
        : const TournamentsFilter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadAll();
    });
  }

  double? get _userLevel {
    final user = context.read<HomeProvider>().user;
    if (user == null) return null;
    return double.tryParse(user.level);
  }

  Future<void> _openFormatFilter() async {
    final formats = <_FormatOption>[
      const _FormatOption('americano', 'Американо'),
      const _FormatOption('classic', 'Классический'),
      const _FormatOption('team', 'Командный'),
      const _FormatOption('mexicano', 'Мексикано'),
    ];
    final current = Set<String>.from(_filter.formats);
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return _FilterSheet(
              title: 'Формат турнира',
              onReset: () {
                setState(() => _filter = _filter.copyWith(formats: {}));
                Navigator.pop(ctx);
              },
              onApply: () {
                setState(() =>
                    _filter = _filter.copyWith(formats: Set<String>.from(current)));
                Navigator.pop(ctx);
              },
              children: formats.map((f) {
                final checked = current.contains(f.value);
                return _CheckboxRow(
                  label: f.label,
                  checked: checked,
                  onTap: () => setSheetState(() {
                    if (checked) {
                      current.remove(f.value);
                    } else {
                      current.add(f.value);
                    }
                  }),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Future<void> _openDateFilter() async {
    final l = AppLocalizations.of(context)!;
    final options = [
      _DateOption(null, l.dateAll),
      _DateOption('today', l.today),
      _DateOption('tomorrow', l.filterDateTomorrow),
      _DateOption('week', l.dateThisWeek),
    ];
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        title: l.filterDate,
        children: options.map((o) {
          final selected = _filter.dateFilter == o.value;
          return _RadioRow(
            label: o.label,
            selected: selected,
            onTap: () {
              setState(() => _filter = _filter.copyWith(dateFilter: o.value));
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openClubFilter(List<Tournament> allTournaments) async {
    final clubs = <int, String>{};
    for (final t in allTournaments) {
      clubs[t.club.id] = t.club.name;
    }
    final ids = clubs.keys.toList()
      ..sort((a, b) => clubs[a]!.compareTo(clubs[b]!));
    final current = Set<int>.from(_filter.clubIds);
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return _FilterSheet(
              title: AppLocalizations.of(context)!.filterClub,
              onReset: () {
                setState(() => _filter = _filter.copyWith(clubIds: {}));
                Navigator.pop(ctx);
              },
              onApply: () {
                setState(() =>
                    _filter = _filter.copyWith(clubIds: Set<int>.from(current)));
                Navigator.pop(ctx);
              },
              children: ids.map((id) {
                final checked = current.contains(id);
                return _CheckboxRow(
                  label: clubs[id]!,
                  checked: checked,
                  onTap: () => setSheetState(() {
                    if (checked) {
                      current.remove(id);
                    } else {
                      current.add(id);
                    }
                  }),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              AppLocalizations.of(context)!.tournaments,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(AppLocalizations.of(context)!.openTab, 0),
                    _buildTab(AppLocalizations.of(context)!.myTab, 1),
                    _buildTab(AppLocalizations.of(context)!.archiveTab, 2),
                    _buildTab(AppLocalizations.of(context)!.cancelledTab, 3),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_tabIndex == 0) ...[
            Consumer<TournamentProvider>(
              builder: (_, provider, __) => FilterPills(
                filter: _filter,
                onReset: () => setState(() => _filter = const TournamentsFilter()),
                onToggleLevel: () => setState(() =>
                    _filter = _filter.copyWith(onlyMyLevel: !_filter.onlyMyLevel)),
                onFormatTap: _openFormatFilter,
                onDateTap: _openDateFilter,
                onClubTap: () => _openClubFilter(provider.openTournaments),
                onToggleCommunity: () => setState(() =>
                    _filter = _filter.copyWith(onlyCommunity: !_filter.onlyCommunity)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _OpenTab(userLevel: _userLevel, filter: _filter),
                _MyTab(userLevel: _userLevel),
                _ArchiveTab(userLevel: _userLevel),
                _CancelledTab(userLevel: _userLevel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final active = _tabIndex == index;
    return GestureDetector(
      onTap: () {
        if (_tabIndex != index) setState(() => _tabIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

void _openTournamentDetail(BuildContext context, int tournamentId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TournamentDetailScreen(tournamentId: tournamentId),
    ),
  );
}

void _openClubDetail(BuildContext context, int clubId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
  );
}

/// Применяет фильтры к списку турниров (только Open tab).
List<Tournament> _applyFilter(
  List<Tournament> tournaments,
  TournamentsFilter filter,
  double? userLevel,
) {
  var list = tournaments;

  if (filter.onlyMyLevel && userLevel != null) {
    list = list.where((t) => t.isInLevelRange(userLevel)).toList();
  }
  if (filter.formats.isNotEmpty) {
    list = list.where((t) => filter.formats.contains(t.type)).toList();
  }
  if (filter.dateFilter != null) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filter.dateFilter) {
      case 'today':
        list = list.where((t) {
          final d = DateTime(t.datetime.year, t.datetime.month, t.datetime.day);
          return d == today;
        }).toList();
        break;
      case 'tomorrow':
        final tomorrow = today.add(const Duration(days: 1));
        list = list.where((t) {
          final d = DateTime(t.datetime.year, t.datetime.month, t.datetime.day);
          return d == tomorrow;
        }).toList();
        break;
      case 'week':
        final endOfWeek = today.add(const Duration(days: 7));
        list = list.where((t) {
          final d = DateTime(t.datetime.year, t.datetime.month, t.datetime.day);
          return !d.isBefore(today) && d.isBefore(endOfWeek);
        }).toList();
        break;
    }
  }
  if (filter.clubIds.isNotEmpty) {
    list = list.where((t) => filter.clubIds.contains(t.club.id)).toList();
  }
  if (filter.onlyCommunity) {
    list = list.where((t) => t.club.isCommunity).toList();
  }
  return list;
}

// === Open tab: For you + Others ===

class _OpenTab extends StatelessWidget {
  final double? userLevel;
  final TournamentsFilter filter;

  const _OpenTab({required this.userLevel, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingOpen) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        final all = _applyFilter(provider.openTournaments, filter, userLevel);
        if (all.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noOpenTournaments,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        final forYou = userLevel == null
            ? <Tournament>[]
            : all.where((t) => t.isInLevelRange(userLevel)).toList()
          ..sort(_compareOpenFirstThenDate);

        final rest = all.where((t) => !forYou.contains(t)).toList()
          ..sort(_compareOpenFirstThenDate);

        // Для «Для вас» группируем по клубам (в порядке появления)
        final forYouByClub = <int, List<Tournament>>{};
        final forYouClubOrder = <int>[];
        for (final t in forYou) {
          if (!forYouByClub.containsKey(t.club.id)) {
            forYouByClub[t.club.id] = [];
            forYouClubOrder.add(t.club.id);
          }
          forYouByClub[t.club.id]!.add(t);
        }

        // Для «Остальные» группируем по клубам; клубы с open-турнирами наверху
        final restByClub = <int, List<Tournament>>{};
        for (final t in rest) {
          restByClub.putIfAbsent(t.club.id, () => []).add(t);
        }
        final restClubOrder = restByClub.keys.toList()
          ..sort((a, b) {
            final aHasOpen = restByClub[a]!.any((t) => !t.isFull);
            final bHasOpen = restByClub[b]!.any((t) => !t.isFull);
            if (aHasOpen != bHasOpen) return aHasOpen ? -1 : 1;
            final aFirst = restByClub[a]!.first;
            final bFirst = restByClub[b]!.first;
            return aFirst.club.name.compareTo(bFirst.club.name);
          });

        return RefreshIndicator(
          onRefresh: () => provider.loadOpenTournaments(),
          color: AppTheme.accent,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (forYou.isNotEmpty) ...[
                _buildForYouHeader(context, forYou.length),
                for (final clubId in forYouClubOrder) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClubSubHeader(
                      clubName: forYouByClub[clubId]!.first.club.name,
                      city: forYouByClub[clubId]!.first.club.city,
                      logoUrl: forYouByClub[clubId]!.first.club.logo,
                      count: forYouByClub[clubId]!.length,
                      onTap: () => _openClubDetail(context, clubId),
                    ),
                  ),
                  for (final t in forYouByClub[clubId]!)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: HeroTournamentCard(
                        tournament: t,
                        userLevel: userLevel,
                        onTap: () => _openTournamentDetail(context, t.id),
                      ),
                    ),
                ],
              ],
              if (forYou.isNotEmpty && rest.isNotEmpty)
                _buildSectionDivider(),
              if (rest.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  color: forYou.isNotEmpty ? const Color(0x2E000000) : null,
                  child: Column(
                    children: [
                      for (final clubId in restClubOrder)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _ClubBlock(
                            tournaments: restByClub[clubId]!,
                            userLevel: userLevel,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForYouHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.forYouSection,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          if (userLevel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Уровень ${userLevel!.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.textDim,
              fontSize: 11,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 4),
      child: SizedBox(
        height: 22,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0x14FFFFFF),
                    Color(0x14FFFFFF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: AppTheme.background,
              child: const Text(
                'ОСТАЛЬНЫЕ ТУРНИРЫ',
                style: TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _compareOpenFirstThenDate(Tournament a, Tournament b) {
  if (a.isFull != b.isFull) return a.isFull ? 1 : -1;
  return a.datetime.compareTo(b.datetime);
}

/// Блок клуба: большой хедер + карточка со строками.
class _ClubBlock extends StatelessWidget {
  final List<Tournament> tournaments;
  final double? userLevel;

  const _ClubBlock({required this.tournaments, required this.userLevel});

  @override
  Widget build(BuildContext context) {
    final first = tournaments.first;
    final openCount = tournaments.where((t) => !t.isFull).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClubSectionHeader(
          clubName: first.club.name,
          city: first.club.city,
          logoUrl: first.club.logo,
          openCount: openCount,
          totalCount: tournaments.length,
          onTap: () => _openClubDetail(context, first.club.id),
        ),
        const SizedBox(height: 6),
        for (final t in tournaments)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HeroTournamentCard(
              tournament: t,
              userLevel: userLevel,
              onTap: () => _openTournamentDetail(context, t.id),
            ),
          ),
      ],
    );
  }
}

// === My tab ===

class _MyTab extends StatelessWidget {
  final double? userLevel;
  const _MyTab({required this.userLevel});

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingMy) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent));
        }
        if (provider.myTournaments.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.notRegisteredForTournaments,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        final byClub = <int, List<Tournament>>{};
        for (final t in provider.myTournaments) {
          byClub.putIfAbsent(t.club.id, () => []).add(t);
        }
        final clubIds = byClub.keys.toList()
          ..sort((a, b) => byClub[a]!.first.club.name
              .compareTo(byClub[b]!.first.club.name));

        return RefreshIndicator(
          onRefresh: () => provider.loadMyTournaments(),
          color: AppTheme.accent,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              for (final clubId in clubIds) ...[
                const SizedBox(height: 8),
                _ClubBlock(
                  tournaments: byClub[clubId]!..sort(_compareOpenFirstThenDate),
                  userLevel: userLevel,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// === Archive tab ===

enum ArchivePeriod { week, month, quarter, all, custom }

class _ArchiveTab extends StatefulWidget {
  final double? userLevel;
  const _ArchiveTab({required this.userLevel});

  @override
  State<_ArchiveTab> createState() => _ArchiveTabState();
}

class _ArchiveTabState extends State<_ArchiveTab> {
  ArchivePeriod _period = ArchivePeriod.week;
  DateTime? _customFrom;
  DateTime? _customTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyPeriod());
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _applyPeriod() {
    final now = DateTime.now();
    String? from;
    String? to;

    switch (_period) {
      case ArchivePeriod.week:
        from = _formatDate(now.subtract(const Duration(days: 7)));
        to = _formatDate(now);
        break;
      case ArchivePeriod.month:
        from = _formatDate(now.subtract(const Duration(days: 30)));
        to = _formatDate(now);
        break;
      case ArchivePeriod.quarter:
        from = _formatDate(now.subtract(const Duration(days: 90)));
        to = _formatDate(now);
        break;
      case ArchivePeriod.all:
        from = null;
        to = null;
        break;
      case ArchivePeriod.custom:
        if (_customFrom != null) from = _formatDate(_customFrom!);
        if (_customTo != null) to = _formatDate(_customTo!);
        break;
    }

    context.read<TournamentProvider>().loadArchiveTournaments(
          dateFrom: from,
          dateTo: to,
        );
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customFrom != null && _customTo != null
          ? DateTimeRange(start: _customFrom!, end: _customTo!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.card,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null && mounted) {
      setState(() {
        _period = ArchivePeriod.custom;
        _customFrom = range.start;
        _customTo = range.end;
      });
      _applyPeriod();
    }
  }

  String get _customLabel {
    if (_customFrom == null || _customTo == null) return 'Период';
    String fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    return '${fmt(_customFrom!)} – ${fmt(_customTo!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPeriodBar(),
        Expanded(
          child: Consumer<TournamentProvider>(
            builder: (_, provider, __) {
              if (provider.isLoadingArchive) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
              }
              if (provider.archiveTournaments.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noFinishedTournaments,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              final byClub = <int, List<Tournament>>{};
              for (final t in provider.archiveTournaments) {
                byClub.putIfAbsent(t.club.id, () => []).add(t);
              }
              final clubIds = byClub.keys.toList()
                ..sort((a, b) => byClub[a]!.first.club.name
                    .compareTo(byClub[b]!.first.club.name));

              return RefreshIndicator(
                onRefresh: () async => _applyPeriod(),
                color: AppTheme.accent,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    for (final clubId in clubIds) ...[
                      const SizedBox(height: 8),
                      _ArchiveClubBlock(
                        tournaments: byClub[clubId]!
                          ..sort((a, b) => b.datetime.compareTo(a.datetime)),
                        userLevel: widget.userLevel,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _periodChip('Неделя', ArchivePeriod.week),
            const SizedBox(width: 6),
            _periodChip('Месяц', ArchivePeriod.month),
            const SizedBox(width: 6),
            _periodChip('3 месяца', ArchivePeriod.quarter),
            const SizedBox(width: 6),
            _periodChip('Всё', ArchivePeriod.all),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _pickCustomRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _period == ArchivePeriod.custom ? AppTheme.accent : AppTheme.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _period == ArchivePeriod.custom ? AppTheme.accent : const Color(0xFF2A2A2A),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range,
                        size: 14,
                        color: _period == ArchivePeriod.custom ? Colors.black : AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      _period == ArchivePeriod.custom ? _customLabel : 'Период',
                      style: TextStyle(
                        color: _period == ArchivePeriod.custom ? Colors.black : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, ArchivePeriod period) {
    final selected = _period == period;
    return GestureDetector(
      onTap: () {
        if (_period != period) {
          setState(() => _period = period);
          _applyPeriod();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.accent : const Color(0xFF2A2A2A),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ArchiveClubBlock extends StatelessWidget {
  final List<Tournament> tournaments;
  final double? userLevel;

  const _ArchiveClubBlock({required this.tournaments, required this.userLevel});

  void _openStats(BuildContext context, Tournament t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => t.type == 'king_of_court'
            ? TournamentLiveKingOfCourtScreen(tournamentId: t.id)
            : t.type == 'bali_koc'
                ? TournamentLiveBaliKocScreen(tournamentId: t.id)
                : TournamentStatsScreen(
                    tournamentId: t.id,
                    tournamentName: t.name,
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = tournaments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClubSectionHeader(
          clubName: first.club.name,
          city: first.club.city,
          logoUrl: first.club.logo,
          openCount: tournaments.length,
          totalCount: tournaments.length,
          onTap: () => _openClubDetail(context, first.club.id),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < tournaments.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == tournaments.length - 1
                            ? Colors.transparent
                            : AppTheme.divider,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TournamentRowV2(
                    tournament: tournaments[i],
                    userLevel: userLevel,
                    showStatusChip: false,
                    onTap: () => _openStats(context, tournaments[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// === Cancelled tab ===

class _CancelledTab extends StatefulWidget {
  final double? userLevel;
  const _CancelledTab({required this.userLevel});

  @override
  State<_CancelledTab> createState() => _CancelledTabState();
}

class _CancelledTabState extends State<_CancelledTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadCancelledTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingCancelled) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
        }
        if (provider.cancelledTournaments.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noCancelledTournaments,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        final byClub = <int, List<Tournament>>{};
        for (final t in provider.cancelledTournaments) {
          byClub.putIfAbsent(t.club.id, () => []).add(t);
        }
        final clubIds = byClub.keys.toList()
          ..sort((a, b) =>
              byClub[a]!.first.club.name.compareTo(byClub[b]!.first.club.name));

        return RefreshIndicator(
          onRefresh: () => provider.loadCancelledTournaments(),
          color: AppTheme.accent,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              for (final clubId in clubIds) ...[
                const SizedBox(height: 8),
                _ArchiveClubBlock(
                  tournaments: byClub[clubId]!
                    ..sort((a, b) => b.datetime.compareTo(a.datetime)),
                  userLevel: widget.userLevel,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// === Filter sheets helpers ===

class _FilterSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onReset;
  final VoidCallback? onApply;

  const _FilterSheet({
    required this.title,
    required this.children,
    this.onReset,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...children,
            if (onApply != null || onReset != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (onReset != null)
                      Expanded(
                        child: TextButton(
                          onPressed: onReset,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0x0AFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Сбросить',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    if (onReset != null && onApply != null) const SizedBox(width: 8),
                    if (onApply != null)
                      Expanded(
                        child: TextButton(
                          onPressed: onApply,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppTheme.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Применить',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _CheckboxRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? AppTheme.accent : Colors.transparent,
                border: Border.all(
                  color: checked ? AppTheme.accent : AppTheme.textSecondary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.accent : AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: AppTheme.accent),
          ],
        ),
      ),
    );
  }
}

class _FormatOption {
  final String value;
  final String label;
  const _FormatOption(this.value, this.label);
}

class _DateOption {
  final String? value;
  final String label;
  const _DateOption(this.value, this.label);
}
