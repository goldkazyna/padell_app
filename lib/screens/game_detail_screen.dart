import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';
import '../widgets/app_back_button.dart';
import '../widgets/games/game_players_list.dart';
import '../l10n/app_localizations.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadDetails(widget.gameId);
    });
  }

  @override
  void dispose() {
    context.read<GameProvider>().clearCurrentGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (_, provider, _) {
            if (provider.isLoadingDetail && provider.currentGame == null) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                  ),
                ],
              );
            }

            final game = provider.currentGame;
            if (game == null) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.challengeNotFound,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.loadDetails(widget.gameId),
                    color: AppTheme.accent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          _buildStatusBadge(context, game),
                          const SizedBox(height: 16),
                          _buildInfoCard(context, game),
                          const SizedBox(height: 16),
                          GamePlayersList(game: game),
                          if (game.isCreator) ...[
                            const SizedBox(height: 16),
                            _buildShareCard(context, game),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.gameDetailTitle,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Game game) {
    Color badgeColor;
    switch (game.status) {
      case 'open':
        badgeColor = AppTheme.accent;
        break;
      case 'full':
        badgeColor = AppTheme.orange;
        break;
      case 'in_progress':
        badgeColor = const Color(0xFF7C3AED);
        break;
      case 'finished':
        badgeColor = AppTheme.textSecondary;
        break;
      case 'cancelled':
        badgeColor = AppTheme.error;
        break;
      default:
        badgeColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        game.statusName,
        style: TextStyle(
          color: badgeColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Game game) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A3330),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & time
          _buildInfoRow(
            Icons.calendar_today,
            '${game.dateFormatted} ${game.timeFormatted}',
          ),
          // Club
          if (game.club != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on, game.club!.name),
          ],
          const SizedBox(height: 10),
          // Format
          _buildInfoRow(Icons.sports_tennis, game.formatName),
          const SizedBox(height: 10),
          // Type
          _buildInfoRow(Icons.category, game.typeName),
          const SizedBox(height: 10),
          // Level range
          _buildInfoRow(Icons.trending_up, game.levelText),
          // Price
          if (game.price != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.payments,
              '${l10n.gamePriceLabel}: ${game.price}',
            ),
          ],
          // Description
          if (game.description != null && game.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Icons.notes, game.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareCard(BuildContext context, Game game) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = game.shareActive ? AppTheme.accent : AppTheme.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A3330),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.gameShareTitle,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  game.shareActive ? l10n.gameShareActive : l10n.gameShareInactive,
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (game.shareToken != null && game.shareActive) ...[
            const SizedBox(height: 10),
            Text(
              game.shareToken!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
