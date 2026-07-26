import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import '../widgets/coming_soon_badge.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_tab_bar.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatefulWidget {
  /// 'club' (по умолчанию) — обычные клубы; 'community' — комьюнити.
  final String type;
  final String title;

  const ClubsListScreen({
    super.key,
    this.type = 'club',
    this.title = 'Клубы',
  });

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String? _activeCity; // null = все

  static const _cities = <String>[
    'Алматы',
    'Астана',
    'Шымкент',
    'Караганда',
    'Актобе',
    'Актау',
    'Атырау',
    'Костанай',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final clubs = await context.read<ClubService>().getClubs(
            search: _search,
            type: widget.type,
            city: _activeCity,
          );
      if (!mounted) return;
      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearch(),
            const SizedBox(height: 4),
            _buildCityTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      bottomNavigationBar: const MainTabBar(),
    );
  }

  Widget _buildCityTabs() {
    final tabs = <(String?, String)>[
      (null, AppLocalizations.of(context)!.cityAll),
    ];
    for (final c in _cities) {
      tabs.add((c, c));
    }
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final t in tabs) _buildCityTab(t.$1, t.$2),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTab(String? value, String label) {
    final isActive = _activeCity == value;
    return GestureDetector(
      onTap: () {
        if (_activeCity != value) {
          setState(() => _activeCity = value);
          _load();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 14),
          Text(
            widget.title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.type == 'community'
              ? l.searchCommunityHint
              : l.searchClubHint,
          hintStyle: TextStyle(
              color: AppTheme.textSecondary, fontSize: 14),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.search,
              color: AppTheme.textSecondary, size: 20),
        ),
        onChanged: (value) {
          _search = value.trim();
          _load();
        },
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading && _clubs.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null && _clubs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 48),
              const SizedBox(height: 12),
              Text(
                'Не удалось загрузить клубы',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      );
    }
    if (_clubs.isEmpty) {
      return Center(
        child: Text(
          'Клубов не найдено',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _clubs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _ClubTile(
          club: _clubs[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClubDetailScreen(
                clubId: _clubs[index].id,
                initialClub: _clubs[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const _ClubTile({required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: club.logo != null
                  ? Image.network(
                      club.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitials(),
                    )
                  : _buildInitials(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (club.comingSoon) ...[
                    const SizedBox(height: 5),
                    const ComingSoonBadge(fontSize: 9),
                  ],
                  const SizedBox(height: 4),
                  if (club.city != null && club.city!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_city_outlined, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          club.city!,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  if (club.address != null && club.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      club.address!,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (club.tournamentsCount > 0) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 15, color: AppTheme.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    '${club.tournamentsCount}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final words = club.name.trim().split(RegExp(r'\s+'));
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : (club.name.length >= 2 ? club.name.substring(0, 2).toUpperCase() : club.name.toUpperCase());
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
