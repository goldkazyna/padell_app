import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/amigo.dart';
import '../../providers/amigo_provider.dart';
import '../../screens/amigos_screen.dart';
import '../../screens/game_detail_screen.dart';
import '../../screens/player_profile_screen.dart';
import '../../screens/tournament_detail_screen.dart';
import '../../screens/tournament_live_entry_screen.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Амигос в профиле — лента аватаров.
///
/// Списком именами не показываем: в профиле важно не «кто у меня есть», а
/// «кто сейчас на корте». Поэтому лента: первым — «Добавить», дальше свои,
/// играющие в акцентном кольце и всегда впереди (порядок задаёт сервер).
///
/// Тап по играющему открывает его трансляцию, по остальным — профиль игрока.
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

  /// Куда ведёт тап по аватару: играет — в трансляцию, собирается играть —
  /// в турнир или игру, остальные — в профиль игрока.
  void _open(Amigo amigo) {
    final status = amigo.status;

    if (status != null && status.isPlaying && status.tournamentId != null) {
      _push(TournamentLiveEntryScreen(tournamentId: status.tournamentId!));
      return;
    }
    if (status != null && status.tournamentId != null) {
      _push(TournamentDetailScreen(tournamentId: status.tournamentId!));
      return;
    }
    if (status != null && status.gameId != null) {
      _push(GameDetailScreen(gameId: status.gameId!));
      return;
    }

    _push(PlayerProfileScreen(playerId: amigo.id, playerName: amigo.name));
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AmigoProvider>(
      builder: (context, provider, _) {
        final amigos = provider.amigos;
        final playing = provider.playing.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            // Справа отступа нет: лента должна уходить под край карточки,
            // иначе не видно, что её можно листать.
            padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
            child: Column(
              // Без этого карточка растягивается на всю доступную высоту,
              // когда её кладут не в скролл.
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _header(l10n, amigos.length, playing),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 76,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 14),
                    children: [
                      _AddTile(
                        label: l10n.amigosAdd,
                        onTap: () => openAmigos(context),
                      ),
                      if (amigos.isEmpty)
                        // Пока никого — держим место, чтобы лента не выглядела
                        // обрезанной.
                        ...List.generate(3, (_) => const _GhostTile())
                      else
                        ...amigos.map(
                          (amigo) => _AmigoTile(
                            amigo: amigo,
                            onTap: () => _open(amigo),
                          ),
                        ),
                    ],
                  ),
                ),
                if (amigos.isEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      l10n.amigosProfileEmpty,
                      style: TextStyle(color: AppTheme.textDim, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(AppLocalizations l10n, int count, int playing) {
    return GestureDetector(
      onTap: () => openAmigos(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Text(
            l10n.amigos,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Когда кто-то играет — показываем это вместо общего числа:
          // ради него карточку и открывают.
          if (playing > 0)
            _PlayingBadge(count: playing, label: l10n.amigosPlayingNow)
          else if (count > 0)
            Text(
              '$count',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: AppTheme.textDim),
        ],
      ),
    );
  }
}

/// «Сейчас играют 3» — акцентный бейдж с точкой.
class _PlayingBadge extends StatelessWidget {
  final int count;
  final String label;

  const _PlayingBadge({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
            '$label $count'.toUpperCase(),
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.55,
            ),
          ),
        ],
      ),
    );
  }
}

/// Первый элемент ленты — «Добавить».
class _AddTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppTheme.accent, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Пустое место в ленте, пока амигос нет.
class _GhostTile extends StatelessWidget {
  const _GhostTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2F3A36), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Аватар амигос в ленте: кольцо у играющих, имя под аватаром.
class _AmigoTile extends StatelessWidget {
  final Amigo amigo;
  final VoidCallback onTap;

  const _AmigoTile({required this.amigo, required this.onTap});

  /// Под аватаром только имя: фамилия не влезает и не нужна.
  String get _firstName => amigo.name.trim().split(RegExp(r'\s+')).first;

  @override
  Widget build(BuildContext context) {
    final status = amigo.status;
    final playing = status?.isPlaying == true;
    final soon = status?.isSoon == true || status?.isLooking == true;

    final ringColor = playing
        ? AppTheme.accent
        : (soon ? AppTheme.orange : null);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: ringColor == null
                  ? null
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: 2),
                    ),
              child: PlayerAvatar(
                name: amigo.name,
                avatarUrl: amigo.avatar,
                // Внутри кольца аватар меньше, чтобы кольцо не липло к фото.
                size: ringColor == null ? 52 : 44,
                circle: true,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: playing ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 10.5,
                fontWeight: playing ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
