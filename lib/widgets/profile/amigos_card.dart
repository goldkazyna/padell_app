import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/amigo_provider.dart';
import '../../screens/amigos_screen.dart';
import '../../screens/tournament_live_entry_screen.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Карточка амигос в профиле — вход во всё: список, активность, переписка.
///
/// Аватарки в стопке — те, кто прямо сейчас на корте; тап по любой открывает
/// трансляцию этого игрока, а не его профиль: смотреть игру хочется чаще.
class AmigosCard extends StatefulWidget {
  const AmigosCard({super.key});

  @override
  State<AmigosCard> createState() => _AmigosCardState();
}

class _AmigosCardState extends State<AmigosCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AmigoProvider>().loadSummary(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AmigoProvider>(
      builder: (context, provider, _) {
        final playing = provider.playing;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                InkWell(
                  onTap: () => openAmigos(context),
                  child: Row(
                    children: [
                      Text(
                        l10n.amigosMyTitle,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.count}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, size: 18, color: AppTheme.textDim),
                    ],
                  ),
                ),
                if (provider.count == 0) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.amigosProfileEmpty,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                    ),
                  ),
                ] else if (playing.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
                  ),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${l10n.amigosPlayingNow} ${playing.length}'.toUpperCase(),
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ...playing.take(5).map(
                            (amigo) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                onTap: () {
                                  final id = amigo.status?.tournamentId;
                                  if (id == null) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TournamentLiveEntryScreen(tournamentId: id),
                                    ),
                                  );
                                },
                                child: PlayerAvatar(
                                  name: amigo.name,
                                  avatarUrl: amigo.avatar,
                                  size: 30,
                                  circle: true,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
