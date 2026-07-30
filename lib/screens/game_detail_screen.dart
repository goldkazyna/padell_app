import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';
import '../widgets/app_back_button.dart';
import '../widgets/games/game_players_list.dart';
import '../widgets/games/game_rounds_section.dart';
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

  void _showAlert(String message, {bool isError = false}) {
    if (!mounted) return;
    showAppAlert(context, message, isError: isError);
  }

  Future<void> _handleResult(({bool success, String message}) result) async {
    if (!mounted) return;
    if (!result.success) {
      _showAlert(result.message, isError: true);
    }
  }

  Future<void> _accept(int id) async {
    final result = await context.read<GameProvider>().accept(id);
    await _handleResult(result);
  }

  Future<void> _decline(int id) async {
    final result = await context.read<GameProvider>().decline(id);
    await _handleResult(result);
  }

  Future<void> _apply(int id) async {
    final result = await context.read<GameProvider>().apply(id);
    await _handleResult(result);
  }

  Future<void> _leave(int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.gameLeaveConfirm,
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.gameActionLeave, style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await context.read<GameProvider>().leave(id);
    if (result.success && mounted) {
      Navigator.pop(context);
      return;
    }
    await _handleResult(result);
  }

  Future<void> _approve(int id, int playerRowId) async {
    final result = await context.read<GameProvider>().approve(id, playerRowId);
    await _handleResult(result);
  }

  Future<void> _reject(int id, int playerRowId) async {
    final result = await context.read<GameProvider>().reject(id, playerRowId);
    await _handleResult(result);
  }

  Future<void> _removePlayer(int id, int playerRowId) async {
    final result = await context.read<GameProvider>().removePlayer(id, playerRowId);
    await _handleResult(result);
  }

  Future<void> _start(int id) async {
    final result = await context.read<GameProvider>().start(id);
    await _handleResult(result);
  }

  Future<void> _startCancel(int id) async {
    final result = await context.read<GameProvider>().startCancel(id);
    await _handleResult(result);
  }

  Future<void> _shareRotate(int id) async {
    final result = await context.read<GameProvider>().shareRotate(id);
    await _handleResult(result);
  }

  Future<void> _shareRevoke(int id) async {
    final result = await context.read<GameProvider>().shareRevoke(id);
    await _handleResult(result);
  }

  Future<void> _copyShareToken(String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    _showAlert(AppLocalizations.of(context)!.gameShareCopied);
  }

  Future<void> _invite(int id, int userId) async {
    final result = await context.read<GameProvider>().invite(id, userId);
    await _handleResult(result);
  }

  void _showInviteSheet(Game game) {
    final phoneController = TextEditingController();
    List<Map<String, dynamic>> foundPlayers = [];
    bool isSearching = false;
    bool searched = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final l10n = AppLocalizations.of(context)!;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16, 20, 16,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.gameActionInvite,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.gameInviteSearchHint,
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: isSearching
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                              )
                            : const Icon(Icons.search, color: AppTheme.accent),
                        onPressed: isSearching
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();
                                if (phone.isEmpty) return;
                                setSheetState(() => isSearching = true);
                                final results = await context.read<GameProvider>().searchPartner(phone);
                                setSheetState(() {
                                  isSearching = false;
                                  searched = true;
                                  foundPlayers = results;
                                });
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (foundPlayers.isNotEmpty) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.3),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: foundPlayers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final player = foundPlayers[i];
                          final userId = player['id'] as int? ?? 0;
                          return GestureDetector(
                            onTap: () async {
                              Navigator.pop(ctx);
                              await _invite(game.id, userId);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _initialsFor(player['full_name'] as String? ?? ''),
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player['full_name'] as String? ?? '',
                                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${player['rating'] ?? 0} · ${player['phone'] ?? ''}',
                                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline, color: AppTheme.accent, size: 22),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else if (!isSearching && searched) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(l10n.gameInviteEmpty, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _initialsFor(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
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
                          GamePlayersList(
                            game: game,
                            onApprove: game.isCreator
                                ? (p) => _approve(game.id, p.playerId)
                                : null,
                            onReject: game.isCreator
                                ? (p) => _reject(game.id, p.playerId)
                                : null,
                            onRemove: game.isCreator
                                ? (p) {
                                    if (p.isMe) return;
                                    _removePlayer(game.id, p.playerId);
                                  }
                                : null,
                            onInviteSlot: game.isCreator && game.isOpen
                                ? (_) => _showInviteSheet(game)
                                : null,
                          ),
                          if (game.isCreator) ...[
                            const SizedBox(height: 16),
                            _buildShareCard(context, game),
                          ],
                          if (game.isInProgress || game.isFinished || game.scoreLocked) ...[
                            const SizedBox(height: 16),
                            GameRoundsSection(game: game),
                          ],
                          const SizedBox(height: 16),
                          _buildActions(context, game, provider),
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
            GestureDetector(
              onTap: () => _copyShareToken(game.shareToken!),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      game.shareToken!,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.copy, color: AppTheme.textSecondary, size: 16),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallOutlineButton(
                  label: l10n.gameShareRotate,
                  color: AppTheme.accent,
                  onTap: () => _shareRotate(game.id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallOutlineButton(
                  label: l10n.gameShareRevoke,
                  color: AppTheme.error,
                  onTap: game.shareActive ? () => _shareRevoke(game.id) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Game game, GameProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = provider.isActionLoading;
    final List<Widget> buttons = [];

    // Invited: accept / decline
    if (game.myStatus == 'invited') {
      buttons.addAll([
        _buildPrimaryButton(
          label: l10n.gameActionAccept,
          onTap: isLoading ? null : () => _accept(game.id),
          isLoading: isLoading,
        ),
        const SizedBox(height: 10),
        _buildOutlineButton(
          label: l10n.gameActionDecline,
          color: AppTheme.error,
          onTap: isLoading ? null : () => _decline(game.id),
        ),
      ]);
    }

    // Not participant, open, has free slots: apply
    if (!game.isParticipant &&
        game.myStatus != 'invited' &&
        game.isOpen &&
        game.availablePositions.isNotEmpty) {
      buttons.add(
        _buildPrimaryButton(
          label: l10n.gameActionApply,
          onTap: isLoading ? null : () => _apply(game.id),
          isLoading: isLoading,
        ),
      );
    }

    // Candidate: disabled badge
    if (game.myStatus == 'candidate') {
      buttons.add(
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.orange.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            l10n.gameApplied,
            style: TextStyle(
              color: AppTheme.orange,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    // Accepted participant, not creator, not finished: leave
    if (game.isParticipant &&
        game.myStatus == 'accepted' &&
        !game.isCreator &&
        !game.isFinished) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(height: 10));
      buttons.add(
        _buildOutlineButton(
          label: l10n.gameActionLeave,
          color: AppTheme.error,
          onTap: isLoading ? null : () => _leave(game.id),
        ),
      );
    }

    // Creator actions
    if (game.isCreator) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(height: 10));

      if (game.isOpen) {
        buttons.add(
          _buildOutlineButton(
            label: l10n.gameActionInvite,
            color: AppTheme.accent,
            onTap: isLoading ? null : () => _showInviteSheet(game),
          ),
        );
      }

      if (game.isFull && game.isOpen) {
        buttons.add(const SizedBox(height: 10));
        buttons.add(
          _buildPrimaryButton(
            label: l10n.gameActionStart,
            onTap: isLoading ? null : () => _start(game.id),
            isLoading: isLoading,
          ),
        );
      }

      if (game.isInProgress && !game.scoreLocked) {
        buttons.add(const SizedBox(height: 10));
        buttons.add(
          _buildOutlineButton(
            label: l10n.gameActionStartCancel,
            color: AppTheme.error,
            onTap: isLoading ? null : () => _startCancel(game.id),
          ),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(children: buttons);
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.accent : AppTheme.accent.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withAlpha(76),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onTap != null ? color : color.withAlpha(76), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: onTap != null ? color : color.withAlpha(76),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallOutlineButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onTap != null ? color : color.withAlpha(76), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: onTap != null ? color : color.withAlpha(76),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
