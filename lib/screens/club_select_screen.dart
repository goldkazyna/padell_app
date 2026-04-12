import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/court_provider.dart';
import '../models/club.dart';
import '../theme/app_theme.dart';
import 'court_schedule_screen.dart';

class ClubSelectScreen extends StatefulWidget {
  final bool showBack;
  const ClubSelectScreen({super.key, this.showBack = true});

  @override
  State<ClubSelectScreen> createState() => _ClubSelectScreenState();
}

class _ClubSelectScreenState extends State<ClubSelectScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtProvider>().loadClubs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: widget.showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.selectClub,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Consumer<CourtProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Поиск
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchClub,
                      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      provider.setSearch(value);
                    },
                  ),
                ),
              ),

              // Города
              if (provider.cities.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _CityChip(
                        label: AppLocalizations.of(context)!.allCities,
                        isSelected: provider.selectedCity == null,
                        onTap: () => provider.setCity(null),
                      ),
                      ...provider.cities.map((city) => _CityChip(
                        label: city,
                        isSelected: provider.selectedCity == city,
                        onTap: () => provider.setCity(city),
                      )),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Список клубов
              Expanded(
                child: _buildClubsList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClubsList(CourtProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => provider.loadClubs(),
              child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: AppTheme.accent)),
            ),
          ],
        ),
      );
    }

    if (provider.clubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_tennis, size: 48, color: Color(0xFF3F3F46)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.noClubsFound, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadClubs(),
      color: AppTheme.accent,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.clubs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _ClubCard(
            club: provider.clubs[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourtScheduleScreen(club: provider.clubs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent : AppTheme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.accent : const Color(0xFF2A2A2A),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const _ClubCard({required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Лого клуба
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: const Color(0xFF1E1E1E)),
                    if (club.logo != null)
                      Image.network(
                        club.logo!,
                        fit: BoxFit.cover,
                      )
                    else
                      const Center(
                        child: Icon(Icons.sports_tennis, size: 40, color: Color(0xFF3F3F46)),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.card,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Информация
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (club.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      club.address!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Tag(
                        text: l10n.courtsCount(club.courtsCount),
                        color: const Color(0xFF3B82F6),
                      ),
                      if (club.minPrice != null) ...[
                        const SizedBox(width: 6),
                        _Tag(
                          text: l10n.priceFrom(_formatPrice(club.minPrice!)),
                          color: AppTheme.accent,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]} ',
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
