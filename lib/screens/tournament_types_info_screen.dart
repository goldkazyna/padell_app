import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

/// Информационный экран «О турнирах»: карточка на каждый тип турнира с
/// описанием — что это, как играют, как считается результат/место.
/// Тексты — в AppLocalizations (RU + EN). Открывается из меню Профиля.
class TournamentTypesInfoScreen extends StatelessWidget {
  const TournamentTypesInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Насыщенный фиолетовый из палитры (бледный AppTheme.purple не используем).
    const purple = Color(0xFF7C3AED);

    final types = <_TypeInfo>[
      _TypeInfo(Icons.shuffle_rounded, AppTheme.accent,
          l.tournamentInfoAmericanoName, l.tournamentInfoAmericanoBody),
      _TypeInfo(Icons.sync_alt_rounded, AppTheme.orange,
          l.tournamentInfoRoundRobinName, l.tournamentInfoRoundRobinBody),
      _TypeInfo(Icons.emoji_events_outlined, purple,
          l.tournamentInfoKingOfCourtName, l.tournamentInfoKingOfCourtBody),
      _TypeInfo(Icons.trending_up_rounded, AppTheme.accent,
          l.tournamentInfoMexicanoName, l.tournamentInfoMexicanoBody),
      _TypeInfo(Icons.account_tree_outlined, AppTheme.orange,
          l.tournamentInfoTeamName, l.tournamentInfoTeamBody),
      _TypeInfo(Icons.groups_rounded, purple,
          l.tournamentInfoBaliKocName, l.tournamentInfoBaliKocBody),
      _TypeInfo(Icons.swap_horiz_rounded, AppTheme.accent,
          l.tournamentInfoFlexName, l.tournamentInfoFlexBody),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.tournamentInfoTitle,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                l.tournamentInfoHeader,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: types.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, i) => _TypeCard(info: types[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeInfo {
  final IconData icon;
  final Color color;
  final String name;
  final String body;
  const _TypeInfo(this.icon, this.color, this.name, this.body);
}

class _TypeCard extends StatelessWidget {
  final _TypeInfo info;
  const _TypeCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: info.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(info.icon, color: info.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            info.body,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
