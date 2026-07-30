import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';
import '../widgets/app_back_button.dart';
import '../l10n/app_localizations.dart';
import 'game_detail_screen.dart';

class GameInvitationsScreen extends StatefulWidget {
  const GameInvitationsScreen({super.key});

  @override
  State<GameInvitationsScreen> createState() => _GameInvitationsScreenState();
}

class _GameInvitationsScreenState extends State<GameInvitationsScreen> {
  bool _loading = true;
  int? _actioningInvitationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<GameProvider>().loadInvitations();
      if (mounted) setState(() => _loading = false);
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

  Future<void> _accept(GameInvitationItem item) async {
    setState(() => _actioningInvitationId = item.invitationId);
    final provider = context.read<GameProvider>();
    final result = await provider.accept(item.game.id);
    if (!mounted) return;
    setState(() => _actioningInvitationId = null);
    if (result.success) {
      provider.loadInvitations();
    } else {
      showAppAlert(context, result.message, isError: true);
    }
  }

  Future<void> _decline(GameInvitationItem item) async {
    setState(() => _actioningInvitationId = item.invitationId);
    final provider = context.read<GameProvider>();
    final result = await provider.decline(item.game.id);
    if (!mounted) return;
    setState(() => _actioningInvitationId = null);
    if (result.success) {
      provider.loadInvitations();
    } else {
      showAppAlert(context, result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
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
                    AppLocalizations.of(context)!.gameInvitationsTitle,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<GameProvider>(
                builder: (context, provider, child) {
                  if (_loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    );
                  }

                  if (provider.invitations.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.gameInvitationsEmpty,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadInvitations(),
                    color: AppTheme.accent,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.invitations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final item = provider.invitations[index];
                        return _InvitationCard(
                          item: item,
                          isActioning: _actioningInvitationId == item.invitationId,
                          onTap: () => _openDetail(item.game.id),
                          onAccept: () => _accept(item),
                          onDecline: () => _decline(item),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final GameInvitationItem item;
  final bool isActioning;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InvitationCard({
    required this.item,
    required this.isActioning,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = item.game;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A3330),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, color: AppTheme.accent, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.gameInvitedBy(item.inviterName),
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildMetaRow(
              Icons.location_on,
              game.club?.name ?? l10n.gameTitleFallback,
            ),
            const SizedBox(height: 6),
            _buildMetaRow(
              Icons.calendar_today,
              '${game.dateFormatted}, ${game.timeFormatted}',
            ),
            const SizedBox(height: 6),
            _buildMetaRow(
              Icons.sports_tennis,
              game.formatName,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: l10n.gameActionDecline,
                    color: AppTheme.textSecondary,
                    borderColor: const Color(0xFF2A3330),
                    isLoading: isActioning,
                    onTap: isActioning ? null : onDecline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: l10n.gameActionAccept,
                    color: Colors.black,
                    backgroundColor: AppTheme.accent,
                    isLoading: isActioning,
                    onTap: isActioning ? null : onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
