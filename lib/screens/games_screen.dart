import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/app_back_button.dart';
import '../widgets/games/game_card.dart';
import '../l10n/app_localizations.dart';
import 'create_game_screen.dart';
import 'game_detail_screen.dart';
import 'game_invitations_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      provider.loadFeed();
      provider.loadMyGames();
    });
  }

  void _openDetail(int gameId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(gameId: gameId),
      ),
    );
  }

  void _openCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateGameScreen(),
      ),
    );
  }

  void _openInvitations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GameInvitationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.gameScreenTitle,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _openInvitations,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: AppTheme.border),
                          ),
                        ),
                        child: Icon(
                          Icons.mail_outline,
                          size: 18,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
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
                      Tab(text: AppLocalizations.of(context)!.gameOpenTab),
                      Tab(text: AppLocalizations.of(context)!.gameMyTab),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _OpenTab(onTap: _openDetail),
                    _MyTab(onTap: _openDetail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _openCreate,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withAlpha(76),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _OpenTab extends StatelessWidget {
  final void Function(int) onTap;

  const _OpenTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFeed && provider.feed.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.feed.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.gameEmptyOpen,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadFeed(),
          color: AppTheme.accent,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.feed.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final game = provider.feed[index];
              return GameCard(
                game: game,
                onTap: () => onTap(game.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _MyTab extends StatelessWidget {
  final void Function(int) onTap;

  const _MyTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingMy && provider.myGames.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.myGames.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.gameEmptyMy,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMyGames(),
          color: AppTheme.accent,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.myGames.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final game = provider.myGames[index];
              return GameCard(
                game: game,
                onTap: () => onTap(game.id),
              );
            },
          ),
        );
      },
    );
  }
}
