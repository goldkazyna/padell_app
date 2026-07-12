import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/tournament_chat.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/tournament_chat_view.dart';

class TournamentChatScreen extends StatelessWidget {
  final int tournamentId;
  final String tournamentName;
  final TournamentChat chat;

  const TournamentChatScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.chat,
  });

  String _modeLabel(AppLocalizations l10n) {
    switch (chat.writeMode) {
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
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(tournamentName,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(_modeLabel(l10n),
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: TournamentChatView(tournamentId: tournamentId, chat: chat),
    );
  }
}
