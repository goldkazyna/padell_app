import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/tournament_chat.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/chat_message_bubble.dart';

class TournamentChatScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;
  final TournamentChat chat;

  const TournamentChatScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.chat,
  });

  @override
  State<TournamentChatScreen> createState() => _TournamentChatScreenState();
}

class _TournamentChatScreenState extends State<TournamentChatScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  late final ChatProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ChatProvider>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _provider.loadInitial(widget.tournamentId);
      if (!mounted) return;
      _provider.startPolling(widget.tournamentId);
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _provider.startPolling(widget.tournamentId);
    } else if (state == AppLifecycleState.paused) {
      _provider.stopPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.clear();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    final ok = await _provider.send(widget.tournamentId, text);
    if (!mounted) return;
    if (ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    } else {
      showAppAlert(context, AppLocalizations.of(context)!.chatSendFailed);
    }
  }

  String _modeLabel(AppLocalizations l10n) {
    switch (widget.chat.writeMode) {
      case 'admin':
        return l10n.chatModeAdmin;
      case 'everyone':
        return l10n.chatModeEveryone;
      default:
        return l10n.chatModeParticipants;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
            padding: EdgeInsets.only(left: 8), child: AppBackButton()),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tournamentName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            Text(_modeLabel(l10n),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, p, _) {
                if (p.isLoading && p.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (p.messages.isEmpty) {
                  return Center(
                    child: Text(l10n.chatEmpty,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => p.fetchNewer(widget.tournamentId),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: p.messages.length,
                    itemBuilder: (_, i) {
                      final m = p.messages[i];
                      final canDelete = m.isMine || widget.chat.isAdmin;
                      return ChatMessageBubble(
                        message: m,
                        onLongPress: canDelete
                            ? () => _confirmDelete(m.id, l10n)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          _buildComposer(l10n),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int messageId, AppLocalizations l10n) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppTheme.error),
          title: Text(l10n.chatDelete,
              style: const TextStyle(color: AppTheme.error)),
          onTap: () {
            Navigator.pop(ctx);
            _provider.delete(widget.tournamentId, messageId);
          },
        ),
      ),
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    if (!widget.chat.canWrite) {
      // Две ветки: режим «только организатор» и я не админ → «только
      // организатор»; иначе (турнир завершён) → «только чтение».
      final label = (widget.chat.writeMode == 'admin' && !widget.chat.isAdmin)
          ? l10n.chatLockedOnlyAdmin
          : l10n.chatReadOnlyFinished;
      return Container(
        width: double.infinity,
        color: AppTheme.card,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppTheme.card,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  hintStyle: const TextStyle(color: AppTheme.textDim),
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
