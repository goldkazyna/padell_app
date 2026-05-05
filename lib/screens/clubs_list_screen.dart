import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/club.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';

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
      final clubs = await context.read<ClubService>().getClubs(search: _search);
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
            Expanded(child: _buildList()),
          ],
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
          const Text(
            'Клубы',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Поиск клуба или города',
            hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            _search = value.trim();
            _load();
          },
        ),
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
              const Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 48),
              const SizedBox(height: 12),
              const Text(
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
      return const Center(
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
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
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
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (club.city != null && club.city!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_city_outlined, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          club.city!,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  if (club.address != null && club.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      club.address!,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
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
