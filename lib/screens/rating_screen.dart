import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rating_provider.dart';
import '../services/rating_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rating/my_rank_card.dart';
import '../widgets/rating/player_rating_item.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingProvider>().loadRating();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<RatingProvider>(
        builder: (context, rating, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Рейтинг',
                      style: TextStyle(
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
                            rating.setSearchQuery('');
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

              // Search field
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Поиск по имени...',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    onSubmitted: (value) {
                      rating.setSearchQuery(value);
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // My card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MyRankCard(card: rating.myCard),
              ),
              const SizedBox(height: 16),

              // Level filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLevelFilters(rating),
              ),
              const SizedBox(height: 16),

              // Table header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Text(
                      '#',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 44),
                    const Text(
                      'ИГРОК',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'ОЧКИ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Content
              Expanded(
                child: _buildContent(rating),
              ),

              // Neighbors section (only when filter is 'all')
              if (rating.neighbors.isNotEmpty &&
                  !rating.isLoading &&
                  rating.levelFilter == 'all' &&
                  rating.searchQuery.isEmpty)
                _buildNeighborsSection(rating),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLevelFilters(RatingProvider rating) {
    final filters = ['all', '1', '2', '3', '4'];
    final labels = ['Все', 'L1', 'L2', 'L3', 'L4'];

    return Row(
      children: List.generate(filters.length, (index) {
        final isSelected = rating.levelFilter == filters[index];
        return Padding(
          padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => rating.setLevelFilter(filters[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContent(RatingProvider rating) {
    if (rating.isLoading && rating.players.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    if (rating.error != null && rating.players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rating.error!,
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => rating.loadRating(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (rating.players.isEmpty) {
      return const Center(
        child: Text(
          'Игроки не найдены',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => rating.refresh(),
      color: AppTheme.accent,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        itemCount: rating.players.length + (rating.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == rating.players.length) {
            return _buildLoadMoreButton(rating);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PlayerRatingItem(player: rating.players[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton(RatingProvider rating) {
    final remaining = rating.total - rating.players.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: rating.isLoadingMore ? null : () => rating.loadMore(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating.isLoadingMore)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                const Icon(Icons.more_horiz, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '$remaining игроков',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
              const SizedBox(width: 8),
              const Text(
                'Показать всех',
                style: TextStyle(color: AppTheme.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeighborsSection(RatingProvider rating) {
    // Show only 1 neighbor above, me, 1 neighbor below (3 total)
    final neighbors = rating.neighbors;
    final meIndex = neighbors.indexWhere((p) => p.isMe);

    List<RatingPlayer> displayNeighbors = [];
    if (meIndex >= 0) {
      final start = (meIndex - 1).clamp(0, neighbors.length);
      final end = (meIndex + 2).clamp(0, neighbors.length);
      displayNeighbors = neighbors.sublist(start, end);
    } else if (neighbors.length <= 3) {
      displayNeighbors = neighbors;
    } else {
      displayNeighbors = neighbors.sublist(0, 3);
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Моя позиция',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ...displayNeighbors.map((player) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: PlayerRatingItem(player: player),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
