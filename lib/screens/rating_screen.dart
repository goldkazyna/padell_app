import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/rating_provider.dart';
import '../providers/settings_provider.dart';
import '../services/rating_service.dart';
import '../theme/app_theme.dart';
import '../utils/rating_formatter.dart';
import '../widgets/verified_badge.dart';
import 'player_profile_screen.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  int _currentTab = 0; // 0 = Rating, 1 = Growth

  // Growth state
  String _growthSearch = '';
  String _growthPeriod = 'month';
  List<GrowthPlayer> _growthPlayers = [];
  int _myGrowth = 0;
  int _myGrowthPlace = 0;
  bool _growthLoading = false;
  String? _growthError;
  int _growthPage = 1;
  int _growthTotalPages = 1;
  bool _growthLoadingMore = false;
  bool get _growthHasMore => _growthPage < _growthTotalPages;

  // Tournaments state
  String _tournamentsSearch = '';
  String _tournamentsPeriod = 'month';
  List<TournamentsPlayer> _tournamentsPlayers = [];
  int _myTournaments = 0;
  int _myTournamentsChange = 0;
  int _myTournamentsPlace = 0;
  bool _tournamentsLoading = false;
  String? _tournamentsError;
  int _tournamentsPage = 1;
  int _tournamentsTotalPages = 1;
  bool _tournamentsLoadingMore = false;
  bool get _tournamentsHasMore => _tournamentsPage < _tournamentsTotalPages;

  final ScrollController _ratingScrollController = ScrollController();
  final ScrollController _growthScrollController = ScrollController();
  final ScrollController _tournamentsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RatingProvider>();
      provider.setSearchQuery('');
      _searchController.clear();
      _showSearch = false;
      provider.loadRating();
    });
    _ratingScrollController.addListener(_onRatingScroll);
    _growthScrollController.addListener(_onGrowthScroll);
    _tournamentsScrollController.addListener(_onTournamentsScroll);
  }

  @override
  void dispose() {
    _ratingScrollController.removeListener(_onRatingScroll);
    _ratingScrollController.dispose();
    _growthScrollController.removeListener(_onGrowthScroll);
    _growthScrollController.dispose();
    _tournamentsScrollController.removeListener(_onTournamentsScroll);
    _tournamentsScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Подгрузка следующих 50 пользователей, когда долистали почти до низа.
  void _onRatingScroll() {
    if (!_ratingScrollController.hasClients) return;
    final pos = _ratingScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      final provider = context.read<RatingProvider>();
      if (provider.hasMore && !provider.isLoadingMore && !provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  void _onGrowthScroll() {
    if (!_growthScrollController.hasClients) return;
    final pos = _growthScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      if (_growthHasMore && !_growthLoadingMore && !_growthLoading) {
        _loadMoreGrowth();
      }
    }
  }

  void _onTournamentsScroll() {
    if (!_tournamentsScrollController.hasClients) return;
    final pos = _tournamentsScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      if (_tournamentsHasMore && !_tournamentsLoadingMore && !_tournamentsLoading) {
        _loadMoreTournaments();
      }
    }
  }

  Future<void> _loadGrowth() async {
    setState(() {
      _growthLoading = true;
      _growthError = null;
      _growthPage = 1;
    });

    final result = await context.read<RatingProvider>().service.getGrowth(
          period: _growthPeriod,
          search: _growthSearch.isNotEmpty ? _growthSearch : null,
          page: 1,
        );

    if (mounted) {
      setState(() {
        _growthLoading = false;
        if (result.success) {
          _growthPlayers = result.players;
          _myGrowth = result.myGrowth;
          _myGrowthPlace = result.myPlace;
          _growthPage = result.page;
          _growthTotalPages = result.totalPages;
        } else {
          _growthError = result.message;
        }
      });
    }
  }

  Future<void> _loadMoreGrowth() async {
    if (_growthLoadingMore || !_growthHasMore) return;
    setState(() => _growthLoadingMore = true);

    final result = await context.read<RatingProvider>().service.getGrowth(
          period: _growthPeriod,
          search: _growthSearch.isNotEmpty ? _growthSearch : null,
          page: _growthPage + 1,
        );

    if (!mounted) return;
    setState(() {
      _growthLoadingMore = false;
      if (result.success) {
        _growthPlayers.addAll(result.players);
        _growthPage = result.page;
        _growthTotalPages = result.totalPages;
      }
    });
  }

  Future<void> _loadTournaments() async {
    setState(() {
      _tournamentsLoading = true;
      _tournamentsError = null;
      _tournamentsPage = 1;
    });

    final result = await context.read<RatingProvider>().service.getTournaments(
          period: _tournamentsPeriod,
          search: _tournamentsSearch.isNotEmpty ? _tournamentsSearch : null,
          page: 1,
        );

    if (mounted) {
      setState(() {
        _tournamentsLoading = false;
        if (result.success) {
          _tournamentsPlayers = result.players;
          _myTournaments = result.myTournaments;
          _myTournamentsChange = result.myChange;
          _myTournamentsPlace = result.myPlace;
          _tournamentsPage = result.page;
          _tournamentsTotalPages = result.totalPages;
        } else {
          _tournamentsError = result.message;
        }
      });
    }
  }

  Future<void> _loadMoreTournaments() async {
    if (_tournamentsLoadingMore || !_tournamentsHasMore) return;
    setState(() => _tournamentsLoadingMore = true);

    final result = await context.read<RatingProvider>().service.getTournaments(
          period: _tournamentsPeriod,
          search: _tournamentsSearch.isNotEmpty ? _tournamentsSearch : null,
          page: _tournamentsPage + 1,
        );

    if (!mounted) return;
    setState(() {
      _tournamentsLoadingMore = false;
      if (result.success) {
        _tournamentsPlayers.addAll(result.players);
        _tournamentsPage = result.page;
        _tournamentsTotalPages = result.totalPages;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ratingTitle,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchController.clear();
                        if (_currentTab == 0) {
                          context.read<RatingProvider>().setSearchQuery('');
                        } else if (_currentTab == 1) {
                          _growthSearch = '';
                          _loadGrowth();
                        } else if (_currentTab == 2) {
                          _tournamentsSearch = '';
                          _loadTournaments();
                        }
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _showSearch ? Icons.close : Icons.search,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tabs: Рейтинг | Рост рейтинга
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
              ),
              child: Row(
                children: [
                  _buildTab(l10n.ratingTabRating, 0),
                  _buildTab(l10n.ratingTabGrowth, 1),
                  _buildTab(l10n.ratingTabTournaments, 2),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Search field (only rating tab)
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.ratingSearchHint,
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                ),
                onSubmitted: (value) {
                  if (_currentTab == 0) {
                    context.read<RatingProvider>().setSearchQuery(value);
                  } else if (_currentTab == 1) {
                    setState(() => _growthSearch = value);
                    _loadGrowth();
                  } else if (_currentTab == 2) {
                    setState(() => _tournamentsSearch = value);
                    _loadTournaments();
                  }
                },
              ),
            ),

          // Content
          Expanded(
            child: _currentTab == 0 ? _buildRatingTab() : _currentTab == 1 ? _buildGrowthTab() : _buildTournamentsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () {
        if (_currentTab != index) {
          setState(() => _currentTab = index);
          if (index == 1 && _growthPlayers.isEmpty) {
            _loadGrowth();
          } else if (index == 2 && _tournamentsPlayers.isEmpty) {
            _loadTournaments();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ==================== RATING TAB ====================
  Widget _buildRatingTab() {
    return Consumer<RatingProvider>(
      builder: (context, rating, _) {
        return Column(
          children: [
            // Level filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLevelFilters(rating),
            ),
            const SizedBox(height: 8),

            // Table header
            _buildTableHeader(),
            const SizedBox(height: 4),

            // List
            Expanded(child: _buildRatingContent(rating)),

            // My position
            if (rating.myCard != null &&
                rating.levelFilter == 'all' &&
                rating.searchQuery.isEmpty)
              _buildMyPositionBar(rating.myCard!),
          ],
        );
      },
    );
  }

  Widget _buildLevelFilters(RatingProvider rating) {
    final l10n = AppLocalizations.of(context)!;
    final filters = ['all', '1', '2', '3', '4'];
    final labels = [l10n.ratingFilterAll, 'L1', 'L2', 'L3', 'L4'];

    return Row(
      children: List.generate(filters.length, (index) {
        final isSelected = rating.levelFilter == filters[index];
        return Padding(
          padding: EdgeInsets.only(right: index < filters.length - 1 ? 6 : 0),
          child: GestureDetector(
            onTap: () => rating.setLevelFilter(filters[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppTheme.accent : const Color(0xFF2A2A2A),
                  width: 0.5,
                ),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 4),
          const Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(width: 48),
          Text(l10n.ratingPlayerHeader, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const Spacer(),
          Text(l10n.ratingPointsHeader, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildRatingContent(RatingProvider rating) {
    final l10n = AppLocalizations.of(context)!;

    if (rating.isLoading && rating.players.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (rating.error != null && rating.players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rating.error!, style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => rating.loadRating(), child: Text(l10n.retry)),
          ],
        ),
      );
    }

    if (rating.players.isEmpty) {
      return Center(child: Text(l10n.ratingPlayersNotFound, style: const TextStyle(color: AppTheme.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: () => rating.refresh(),
      color: AppTheme.accent,
      child: ListView.builder(
        controller: _ratingScrollController,
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: rating.players.length + (rating.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == rating.players.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          return _buildPlayerRow(rating.players[index]);
        },
      ),
    );
  }

  Widget _buildPlayerRow(RatingPlayer player, {int? growthValue, int? tournamentsValue}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerProfileScreen(
              playerId: player.id,
              playerName: player.name,
            ),
          ),
        );
      },
      child: _buildPlayerRowContent(player, growthValue: growthValue, tournamentsValue: tournamentsValue),
    );
  }

  Widget _buildPlayerRowContent(RatingPlayer player, {int? growthValue, int? tournamentsValue}) {
    final isMe = player.isMe;
    final rankColor = player.position == 1
        ? const Color(0xFFFACC15)
        : player.position == 2
            ? const Color(0xFF94A3B8)
            : player.position == 3
                ? const Color(0xFFF97316)
                : const Color(0xFF52525B);

    return Container(
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(15) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: const Color(0xFF1A1A1E), width: 0.5),
          left: isMe ? BorderSide(color: AppTheme.accent, width: 3) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${player.position}',
              textAlign: TextAlign.center,
              style: TextStyle(color: isMe ? AppTheme.accent : rankColor, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isMe ? AppTheme.accent.withAlpha(40) : const Color(0xFF27272A),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: player.avatar != null
                ? Image.network(player.avatar!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(child: Text(player.initials, style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700))))
                : Center(child: Text(player.initials, style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(player.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (player.levelVerified) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 10),
                    ],
                  ],
                ),
                Builder(builder: (ctx) {
                  final precise = ctx.watch<SettingsProvider>().preciseRating;
                  return Text(
                    RatingFormatter.formatLevelLabel(
                      bucketedLevel: player.level,
                      rating: player.rating,
                      precise: precise,
                    ),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  );
                }),
              ],
            ),
          ),
          if (tournamentsValue != null)
            Text(
              '$tournamentsValue',
              style: TextStyle(
                color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 15, fontWeight: FontWeight.w800,
              ),
            )
          else if (growthValue != null)
            Builder(builder: (ctx) {
              final precise = ctx.watch<SettingsProvider>().preciseRating;
              return Text(
                RatingFormatter.formatRatingChange(growthValue, precise),
                style: TextStyle(
                  color: isMe ? AppTheme.accent : const Color(0xFF22C55E),
                  fontSize: 15, fontWeight: FontWeight.w800,
                ),
              );
            })
          else
            Builder(builder: (ctx) {
              final precise = ctx.watch<SettingsProvider>().preciseRating;
              return Text(
                RatingFormatter.formatRating(player.rating, precise),
                style: TextStyle(color: isMe ? AppTheme.accent : AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMyPositionBar(MyRatingCard card) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${card.place}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF27272A), shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: card.avatar != null
                ? Image.network(card.avatar!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(child: Text(card.initials, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700))))
                : Center(child: Text(card.initials, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(card.name, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (card.levelVerified) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 10),
                    ],
                  ],
                ),
                Builder(builder: (ctx) {
                  final precise = ctx.watch<SettingsProvider>().preciseRating;
                  return Text(
                    RatingFormatter.formatLevelLabel(
                      bucketedLevel: card.level,
                      rating: card.rating,
                      precise: precise,
                    ),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  );
                }),
              ],
            ),
          ),
          Builder(builder: (ctx) {
            final precise = ctx.watch<SettingsProvider>().preciseRating;
            return Text(
              RatingFormatter.formatRating(card.rating, precise),
              style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w800),
            );
          }),
        ],
      ),
    );
  }

  // ==================== GROWTH TAB ====================
  Widget _buildGrowthTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Period filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildPeriodChip(l10n.growthPeriodWeek, 'week'),
              const SizedBox(width: 6),
              _buildPeriodChip(l10n.growthPeriodMonth, 'month'),
              const SizedBox(width: 6),
              _buildPeriodChip(l10n.growthPeriodAll, 'all'),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 4),
              const Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(width: 48),
              Text(l10n.ratingPlayerHeader, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              const Spacer(),
              const Text('РОСТ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // List
        Expanded(child: _buildGrowthContent()),

        // My growth bar
        if (_myGrowth > 0 && !_growthLoading)
          _buildMyGrowthBar(),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _growthPeriod == period;
    return GestureDetector(
      onTap: () {
        if (_growthPeriod != period) {
          setState(() => _growthPeriod = period);
          _loadGrowth();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.accent : const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthContent() {
    final l10n = AppLocalizations.of(context)!;

    if (_growthLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (_growthError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_growthError!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadGrowth, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    if (_growthPlayers.isEmpty) {
      return const Center(child: Text('Нет данных за этот период', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: _loadGrowth,
      color: AppTheme.accent,
      child: ListView.builder(
        controller: _growthScrollController,
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _growthPlayers.length + (_growthHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _growthPlayers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          final gp = _growthPlayers[index];
          return _buildPlayerRow(gp.player, growthValue: gp.growth);
        },
      ),
    );
  }

  Widget _buildMyGrowthBar() {
    final rating = context.read<RatingProvider>();
    final card = rating.myCard;
    if (card == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$_myGrowthPlace', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF27272A), shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: card.avatar != null
                ? Image.network(card.avatar!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(child: Text(card.initials, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700))))
                : Center(child: Text(card.initials, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(card.name, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (card.levelVerified) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 10),
                    ],
                  ],
                ),
                Builder(builder: (ctx) {
                  final precise = ctx.watch<SettingsProvider>().preciseRating;
                  return Text(
                    RatingFormatter.formatLevelLabel(
                      bucketedLevel: card.level,
                      rating: card.rating,
                      precise: precise,
                    ),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  );
                }),
              ],
            ),
          ),
          Builder(builder: (ctx) {
            final precise = ctx.watch<SettingsProvider>().preciseRating;
            return Text(
              RatingFormatter.formatRatingChange(_myGrowth, precise),
              style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w800),
            );
          }),
        ],
      ),
    );
  }

  // ==================== TOURNAMENTS TAB ====================
  Widget _buildTournamentsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Period filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTournamentsPeriodChip(l10n.growthPeriodWeek, 'week'),
              const SizedBox(width: 6),
              _buildTournamentsPeriodChip(l10n.growthPeriodMonth, 'month'),
              const SizedBox(width: 6),
              _buildTournamentsPeriodChip(l10n.growthPeriodAll, 'all'),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 4),
              const Text('#', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(width: 48),
              Text(l10n.ratingPlayerHeader, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              const Spacer(),
              const Text('ТУРН.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // List
        Expanded(child: _buildTournamentsContent()),

        // My bar
        if (_myTournaments > 0 && !_tournamentsLoading)
          _buildMyTournamentsBar(),
      ],
    );
  }

  Widget _buildTournamentsPeriodChip(String label, String period) {
    final isSelected = _tournamentsPeriod == period;
    return GestureDetector(
      onTap: () {
        if (_tournamentsPeriod != period) {
          setState(() => _tournamentsPeriod = period);
          _loadTournaments();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.accent : const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentsContent() {
    final l10n = AppLocalizations.of(context)!;

    if (_tournamentsLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.accent));

    if (_tournamentsError != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_tournamentsError!, style: const TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadTournaments, child: Text(l10n.retry)),
      ]));
    }

    if (_tournamentsPlayers.isEmpty) {
      return const Center(child: Text('Нет данных за этот период', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: _loadTournaments,
      color: AppTheme.accent,
      child: ListView.builder(
        controller: _tournamentsScrollController,
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _tournamentsPlayers.length + (_tournamentsHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tournamentsPlayers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          final tp = _tournamentsPlayers[index];
          return _buildPlayerRow(tp.player, tournamentsValue: tp.tournamentsCount);
        },
      ),
    );
  }

  Widget _buildMyTournamentsBar() {
    final rating = context.read<RatingProvider>();
    final card = rating.myCard;
    if (card == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('$_myTournamentsPlace', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF27272A), shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: card.avatar != null
                ? Image.network(card.avatar!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(card.initials, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700))))
                : Center(child: Text(card.initials, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(card.name, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (card.levelVerified) ...[
                const SizedBox(width: 5),
                const VerifiedBadge(size: 10),
              ],
            ]),
            Builder(builder: (ctx) {
              final precise = ctx.watch<SettingsProvider>().preciseRating;
              return Text(
                RatingFormatter.formatLevelLabel(
                  bucketedLevel: card.level,
                  rating: card.rating,
                  precise: precise,
                ),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              );
            }),
          ])),
          Text('$_myTournaments', style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

}
