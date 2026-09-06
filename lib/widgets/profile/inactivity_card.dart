import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';

/// Напоминание о простое — под статистикой матчей.
///
/// Рейтинг тает у тех, кто перестал играть: на 60-й день без игры снимается
/// 50, дальше по 50 каждый месяц. Человек должен узнать об этом заранее и от
/// приложения, а не обнаружить просадку в таблице.
///
/// Тон спокойный: это напоминание, а не штраф. Красным — только когда
/// списание уже случилось.

class InactivityCard extends StatelessWidget {
  const InactivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final idle = context.watch<ProfileProvider>().inactivity;

    if (!idle.warn) return const SizedBox.shrink();

    return _card(context, idle);
  }

  Widget _card(BuildContext context, PlayerInactivity idle) {
    final l10n = AppLocalizations.of(context)!;

    final accent = idle.decayed ? AppTheme.error : AppTheme.amber;
    final title = idle.decayed
        ? l10n.inactivityDecayedTitle(idle.amount)
        : l10n.inactivityTitle(idle.idleDays);
    final text = idle.decayed
        ? l10n.inactivityDecayedText
        : l10n.inactivityText(idle.daysUntilDecay, idle.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                idle.decayed
                    ? Icons.trending_down_rounded
                    : Icons.schedule_rounded,
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
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
}
