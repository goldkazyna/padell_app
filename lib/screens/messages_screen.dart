import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/amigo.dart';
import '../providers/amigo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/player_avatar.dart';
import 'chat_screen.dart';

/// Список переписок.
///
/// Непрочитанные наверху — иначе важное тонет под свежей болтовнёй.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AmigoProvider>().loadConversations(),
    );
  }

  String _time(DateTime? at, AppLocalizations l10n) {
    if (at == null) return '';
    final local = at.toLocal();
    final now = DateTime.now();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;

    if (sameDay) return DateFormat('HH:mm').format(local);

    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return l10n.messageYesterday;
    }

    return DateFormat('d MMM', Localizations.localeOf(context).languageCode)
        .format(local);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<AmigoProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 12),
                      Text(
                        l10n.messages,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.accent,
                    backgroundColor: AppTheme.card,
                    onRefresh: provider.loadConversations,
                    child: provider.isLoadingConversations &&
                            provider.conversations.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(color: AppTheme.accent),
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                            children: [
                              if (provider.conversations.isEmpty)
                                _empty(l10n)
                              else
                                _list(provider.conversations, l10n),
                            ],
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

  Widget _empty(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Center(
        child: Text(
          l10n.messagesEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13.5,
            height: 1.55,
          ),
        ),
      ),
    );
  }

  Widget _list(List<ConversationSummary> rows, AppLocalizations l10n) {
    final children = <Widget>[];

    for (var i = 0; i < rows.length; i++) {
      children.add(_row(rows[i], l10n));
      if (i != rows.length - 1) {
        children.add(Divider(height: 1, thickness: 0.5, color: AppTheme.divider));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(ConversationSummary row, AppLocalizations l10n) {
    final playing = row.playerStatus?.isPlaying == true;
    final preview = row.lastText == null
        ? ''
        : '${row.lastIsMine ? l10n.messageYouPrefix : ''}${row.lastText}';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              playerId: row.playerId,
              playerName: row.playerName,
            ),
          ),
        );
        if (mounted) context.read<AmigoProvider>().loadConversations();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              decoration: playing
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent, width: 1.5),
                    )
                  : null,
              padding: playing ? const EdgeInsets.all(2) : EdgeInsets.zero,
              child: PlayerAvatar(
                name: row.playerName,
                avatarUrl: row.playerAvatar,
                size: playing ? 34 : 38,
                circle: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.playerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: row.lastIsMine
                          ? AppTheme.textDim
                          : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _time(row.lastAt, l10n),
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                if (row.unread > 0) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${row.unread}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
