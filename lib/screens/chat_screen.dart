import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/amigo.dart';
import '../providers/amigo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/amigos/chat_bubble.dart';
import '../widgets/app_back_button.dart';
import '../widgets/player_avatar.dart';

/// Переписка с игроком.
///
/// Обновление — опрос раз в несколько секунд, как в турнирном чате: вебсокеты
/// ради двух человек в диалоге не нужны, а поведение уже проверено.
class ChatScreen extends StatefulWidget {
  final int playerId;
  final String playerName;

  const ChatScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  ChatThread? _thread;
  bool _loading = true;
  bool _sending = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _pollNew());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final provider = context.read<AmigoProvider>();
    final thread = await provider.loadThread(widget.playerId);

    if (!mounted) return;
    setState(() {
      _thread = thread;
      _loading = false;
    });

    provider.markRead(widget.playerId);
    _scrollToBottom();
  }

  /// Догружаем только новое — по последнему известному id.
  Future<void> _pollNew() async {
    final thread = _thread;
    if (thread == null || thread.messages.isEmpty) return;

    final provider = context.read<AmigoProvider>();
    final fresh = await provider.loadThread(
      widget.playerId,
      afterId: thread.messages.last.id,
    );

    if (!mounted || fresh == null || fresh.messages.isEmpty) return;

    setState(() {
      _thread = thread.copyWith(messages: [...thread.messages, ...fresh.messages]);
    });

    provider.markRead(widget.playerId);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final provider = context.read<AmigoProvider>();
    final message = await provider.sendMessage(widget.playerId, text);

    if (!mounted) return;
    setState(() => _sending = false);

    if (message == null) {
      // Отказ сервера — блокировка, лимит или повтор. Текст не стираем,
      // чтобы человек не набирал заново.
      showAppAlert(context, provider.error ?? '', isError: true);
      return;
    }

    _controller.clear();
    final thread = _thread;
    if (thread != null) {
      setState(() {
        _thread = thread.copyWith(
          messages: [...thread.messages, message],
          showRules: false,
        );
      });
    }
    _scrollToBottom();
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          l10n.messageDeleteConfirm,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.deleteButton,
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context.read<AmigoProvider>().deleteMessage(message.id);
    if (!ok || !mounted) return;

    final thread = _thread;
    if (thread != null) {
      setState(() {
        _thread = thread.copyWith(
          messages: thread.messages.where((m) => m.id != message.id).toList(),
        );
      });
    }
  }

  /// Шторка действий: убрать из амигос, заблокировать, пожаловаться.
  Future<void> _actions() async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3330),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _SheetRow(
              icon: Icons.block,
              label: l10n.blockUser,
              danger: true,
              onTap: () {
                Navigator.pop(ctx);
                _block();
              },
            ),
            _SheetRow(
              icon: Icons.flag_outlined,
              label: l10n.reportUser,
              danger: true,
              onTap: () {
                Navigator.pop(ctx);
                _report();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _block() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          l10n.blockUserConfirm(widget.playerName),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.blockUserExplain,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.blockAction,
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context.read<AmigoProvider>().block(widget.playerId);
    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
    } else {
      showAppAlert(context, context.read<AmigoProvider>().error ?? '', isError: true);
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context)!;
    final comment = TextEditingController();
    String reason = 'spam';

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3330),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  l10n.reportUser,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.reportSubtitle,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 10),
                ...[
                  ('spam', l10n.reportSpam),
                  ('abuse', l10n.reportAbuse),
                  ('fraud', l10n.reportFraud),
                  ('other', l10n.reportOther),
                ].map((option) => InkWell(
                      onTap: () => setSheetState(() => reason = option.$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              reason == option.$1
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: reason == option.$1
                                  ? AppTheme.accent
                                  : AppTheme.textDim,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              option.$2,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
                TextField(
                  controller: comment,
                  maxLines: 3,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: l10n.reportComment,
                    hintStyle: TextStyle(color: AppTheme.textDim, fontSize: 13.5),
                    filled: true,
                    fillColor: AppTheme.cardRaised,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      l10n.reportSend,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (sent != true || !mounted) return;

    final provider = context.read<AmigoProvider>();
    await provider.report(widget.playerId, reason, comment: comment.text);

    if (!mounted) return;
    // Чаще всего человеку нужно не только пожаловаться, но и закрыться от
    // собеседника — поэтому спрашиваем сразу.
    final block = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          l10n.reportSentBlockAsk,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.blockAction,
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (block == true && mounted) {
      final ok = await context.read<AmigoProvider>().block(widget.playerId);
      if (ok && mounted) Navigator.pop(context);
    }
  }

  /// Дата над первым сообщением дня.
  String? _daySeparator(int index, AppLocalizations l10n) {
    final messages = _thread?.messages ?? const <ChatMessage>[];
    final current = messages[index].createdAt?.toLocal();
    if (current == null) return null;

    if (index > 0) {
      final previous = messages[index - 1].createdAt?.toLocal();
      if (previous != null &&
          previous.year == current.year &&
          previous.month == current.month &&
          previous.day == current.day) {
        return null;
      }
    }

    final now = DateTime.now();
    if (current.year == now.year &&
        current.month == now.month &&
        current.day == now.day) {
      return l10n.messageToday;
    }

    return DateFormat('d MMMM', Localizations.localeOf(context).languageCode)
        .format(current);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final thread = _thread;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _header(thread, l10n),
            if (thread?.showRules == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Text(
                  l10n.messageRules,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textDim, fontSize: 11.5, height: 1.5),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: thread?.messages.length ?? 0,
                      itemBuilder: (_, index) {
                        final message = thread!.messages[index];
                        final separator = _daySeparator(index, l10n);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (separator != null) ChatDaySeparator(label: separator),
                            ChatBubble(
                              message: message,
                              onLongPress: () => _deleteMessage(message),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (thread != null && !thread.canWrite)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  thread.blockedByMe ? l10n.messageBlockedByMe : l10n.messageBlockedMe,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.error, fontSize: 13),
                ),
              )
            else
              _composer(l10n),
          ],
        ),
      ),
    );
  }

  Widget _header(ChatThread? thread, AppLocalizations l10n) {
    final status = thread?.playerStatus;
    final meta = <String>[
      if (thread?.playerLevel != null)
        'ур. ${thread!.playerLevel!.toStringAsFixed(2)}',
      if (status?.isPlaying == true) l10n.amigoPlaying,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 10),
          PlayerAvatar(
            name: widget.playerName,
            avatarUrl: thread?.playerAvatar,
            size: 32,
            circle: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _actions,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: Icon(Icons.more_horiz, size: 18, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _composer(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: l10n.messageHint,
                hintStyle: TextStyle(color: AppTheme.textDim, fontSize: 13.5),
                filled: true,
                fillColor: AppTheme.cardRaised,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.send, size: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;

  const _SheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.error : AppTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
