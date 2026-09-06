import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/amigo.dart';
import '../../theme/app_theme.dart';
import '../court_grid_background.dart';
import '../player_avatar.dart';

/// «Сейчас на корте» — верх экрана амигос.
///
/// Ради этого блока экран и открывают: важно не «кто у меня в списке», а
/// «кто играет прямо сейчас». Фон — та же фактура корта, что в меню профиля.
class AmigoLiveBlock extends StatelessWidget {
  final List<Amigo> amigos;

  /// Тап по имени или аватару — выбор «трансляция или профиль».
  final void Function(Amigo) onOpen;

  /// Кнопка «смотреть» — сразу в трансляцию, без вопросов.
  final void Function(Amigo) onWatch;

  const AmigoLiveBlock({
    super.key,
    required this.amigos,
    required this.onOpen,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16281F), Color(0xFF0D1714)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CourtGridBackground(coverage: 0.6)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(l10n),
                  const SizedBox(height: 12),
                  for (final amigo in amigos)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: amigo == amigos.last ? 0 : 12,
                      ),
                      child: _PlayerLine(
                        amigo: amigo,
                        watchLabel: l10n.amigoWatch,
                        onOpen: () => onOpen(amigo),
                        onWatch: () => onWatch(amigo),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
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
                l10n.amigosPlayingNow.toUpperCase(),
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
        if (amigos.length > 1)
          Text(
            '${amigos.length}',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _PlayerLine extends StatelessWidget {
  final Amigo amigo;
  final String watchLabel;
  final VoidCallback onOpen;
  final VoidCallback onWatch;

  const _PlayerLine({
    required this.amigo,
    required this.watchLabel,
    required this.onOpen,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onOpen,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: PlayerAvatar(
              name: amigo.name,
              avatarUrl: amigo.avatar,
              size: 44,
              circle: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onOpen,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amigo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amigo.status?.subtitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Отдельная кнопка: смотреть игру хотят чаще, чем открывать профиль,
        // и ради этого лишний вопрос задавать незачем.
        GestureDetector(
          onTap: onWatch,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              watchLabel,
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
