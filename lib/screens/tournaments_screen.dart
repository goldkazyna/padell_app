import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournaments/tournament_card.dart';
import '../widgets/tournaments/tournament_archive_card.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                AppLocalizations.of(context)!.tournaments,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: AppTheme.accent,
                  indicatorWeight: 2,
                  labelColor: AppTheme.accent,
                  unselectedLabelColor: const Color(0xFF52525B),
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.openTab),
                    Tab(text: AppLocalizations.of(context)!.myTab),
                    Tab(text: AppLocalizations.of(context)!.archiveTab),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _OpenTab(),
                  _MyTab(),
                  _ArchiveTab(),
                ],
              ),
            ),
          ],
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

class _OpenTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingOpen) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.openTournaments.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noOpenTournaments,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        // Группируем турниры по клубам
        final grouped = <int, List<Tournament>>{};
        final clubNames = <int, String>{};
        for (final t in provider.openTournaments) {
          grouped.putIfAbsent(t.club.id, () => []).add(t);
          clubNames[t.club.id] = t.club.name;
        }
        final clubIds = grouped.keys.toList();

        return RefreshIndicator(
          onRefresh: () => provider.loadOpenTournaments(),
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: clubIds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final clubId = clubIds[index];
              final tournaments = grouped[clubId]!;
              final clubName = clubNames[clubId]!;
              return _ClubAccordion(
                clubName: clubName,
                clubLogo: tournaments.first.club.logo,
                tournaments: tournaments,
                initiallyExpanded: true,
              );
            },
          ),
        );
      },
    );
  }
}

class _ClubAccordion extends StatefulWidget {
  final String clubName;
  final String? clubLogo;
  final List<Tournament> tournaments;
  final bool initiallyExpanded;

  const _ClubAccordion({
    required this.clubName,
    this.clubLogo,
    required this.tournaments,
    this.initiallyExpanded = true,
  });

  @override
  State<_ClubAccordion> createState() => _ClubAccordionState();
}

class _ClubAccordionState extends State<_ClubAccordion>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: _expanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  // Генерируем инициалы из названия клуба
  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  // Цвет логотипа на основе имени клуба
  Color _getClubColor(String name) {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFFFF9F0A), // orange
      const Color(0xFFBF5AF2), // purple
      const Color(0xFF0A84FF), // blue
      const Color(0xFF30D5C8), // teal
      const Color(0xFFFF375F), // pink
      const Color(0xFF32D74B), // green
    ];
    return colors[hash.abs() % colors.length];
  }

  Widget _buildInitialsLogo(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(180)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(widget.clubName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getClubColor(widget.clubName);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Club logo
                  if (widget.clubLogo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.clubLogo!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitialsLogo(color),
                      ),
                    )
                  else
                    _buildInitialsLogo(color),
                  const SizedBox(width: 10),
                  // Club name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.clubName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.clubTournamentsCount(widget.tournaments.length),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  RotationTransition(
                    turns: _arrowAnimation,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                for (int i = 0; i < widget.tournaments.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      height: 1,
                      color: const Color(0xFF252528),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openTournamentDetail(
                      context,
                      widget.tournaments[i].id,
                    ),
                    child: TournamentCard(
                      day: widget.tournaments[i].dayOfMonth,
                      month: widget.tournaments[i].monthShort,
                      time: widget.tournaments[i].time,
                      name: widget.tournaments[i].name,
                      type: widget.tournaments[i].typeName,
                      typeColor: widget.tournaments[i].typeColor,
                      club: widget.tournaments[i].club.name,
                      participants: widget.tournaments[i].participantsText,
                      price: widget.tournaments[i].priceText,
                      level: widget.tournaments[i].levelText,
                      isRegistered: widget.tournaments[i].isRegistered,
                      isFull: widget.tournaments[i].isFull,
                      flat: true,
                    ),
                  ),
                  if (i < widget.tournaments.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingMy) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.myTournaments.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.notRegisteredForTournaments,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMyTournaments(),
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.myTournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final t = provider.myTournaments[index];
              return GestureDetector(
                onTap: () => _openTournamentDetail(context, t.id),
                child: TournamentCard.fromTournament(t),
              );
            },
          ),
        );
      },
    );
  }
}

class _ArchiveTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingArchive) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.archiveTournaments.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noFinishedTournaments,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadArchiveTournaments(),
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.archiveTournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final t = provider.archiveTournaments[index];
              return GestureDetector(
                onTap: () => _openTournamentDetail(context, t.id),
                child: TournamentArchiveCard.fromTournament(t),
              );
            },
          ),
        );
      },
    );
  }
}
