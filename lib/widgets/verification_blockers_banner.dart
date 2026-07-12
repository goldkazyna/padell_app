import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/edit_profile_screen.dart';
import '../theme/app_theme.dart';

/// Баннер «почему рейтинг не верифицирован» — показывается на экранах
/// СВОЕГО юзера если у него есть `verificationBlockers`.
///
/// Если массив пустой → возвращает SizedBox.shrink().
/// Если есть блокеры — янтарная плашка с конкретными причинами и
/// кнопками-действиями.
class VerificationBlockersBanner extends StatelessWidget {
  final List<String> blockers;
  final VoidCallback? onTournamentsTap;

  const VerificationBlockersBanner({
    super.key,
    required this.blockers,
    this.onTournamentsTap,
  });

  @override
  Widget build(BuildContext context) {
    if (blockers.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.amber, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.verificationNotConfirmedTitle,
                  style: TextStyle(
                    color: AppTheme.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final code in blockers) ...[
            _BlockerRow(
              code: code,
              onTournamentsTap: onTournamentsTap,
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _BlockerRow extends StatelessWidget {
  final String code;
  final VoidCallback? onTournamentsTap;

  const _BlockerRow({required this.code, this.onTournamentsTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (IconData icon, String title, String desc, VoidCallback action) =
        switch (code) {
      'no_avatar' => (
          Icons.account_circle_outlined,
          l.verificationNoAvatarTitle,
          l.verificationNoAvatarDesc,
          () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            );
            if (context.mounted) {
              context.read<HomeProvider>().refresh();
            }
          },
        ),
      'no_tournaments' => (
          Icons.emoji_events_outlined,
          l.verificationNoTournamentsTitle,
          l.verificationNoTournamentsDesc,
          () {
            if (onTournamentsTap != null) onTournamentsTap!();
          },
        ),
      _ => (
          Icons.info_outline,
          l.verificationNotConfirmedTitle,
          code,
          () {},
        ),
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.amber, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
