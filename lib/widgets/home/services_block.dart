import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../utils/profile_incomplete_guard.dart';
import '../../screens/club_select_screen.dart';
import '../../screens/clubs_list_screen.dart';
import '../../screens/club_cards_screen.dart';
import '../../screens/create_game_screen.dart';
import '../../screens/games_screen.dart';

/// Блок «Сервисы» на главной — сетка 4×2 быстрых входов.
/// Иконки монохромные (единый цвет). [onOpenTournaments] переключает нижнюю
/// навигацию на вкладку «Турниры».
class ServicesBlock extends StatelessWidget {
  final VoidCallback onOpenTournaments;
  const ServicesBlock({super.key, required this.onOpenTournaments});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final items = <_ServiceData>[
      _ServiceData(
        icon: Icons.calendar_month_outlined,
        label: l.serviceBooking,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ClubSelectScreen())),
      ),
      _ServiceData(
        icon: Icons.apartment_outlined,
        label: l.serviceClubs,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ClubsListScreen(title: l.serviceClubs))),
      ),
      _ServiceData(
        icon: Icons.groups_outlined,
        label: l.serviceCommunity,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ClubsListScreen(
                    type: 'community', title: l.serviceCommunity))),
      ),
      _ServiceData(
        icon: Icons.shopping_bag_outlined,
        label: l.serviceShop,
        onTap: () => showAppAlert(context, l.serviceComingSoon),
      ),
      _ServiceData(
        icon: Icons.person_add_alt_1_outlined,
        label: l.serviceCreateGame,
        onTap: () {
          if (!ensureProfileComplete(context)) return;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateGameScreen()));
        },
      ),
      _ServiceData(
        icon: Icons.sports_esports_outlined,
        label: l.serviceGames,
        onTap: () {
          if (!ensureProfileComplete(context)) return;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GamesScreen()));
        },
      ),
      _ServiceData(
        icon: Icons.credit_card_outlined,
        label: l.serviceClubCards,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ClubCardsScreen())),
      ),
      _ServiceData(
        icon: Icons.emoji_events_outlined,
        label: l.serviceTournaments,
        onTap: onOpenTournaments,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.servicesTitle,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (int i = 0; i < 4; i++)
              Expanded(child: _ServiceTile(data: items[i])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 4; i < 8; i++)
              Expanded(child: _ServiceTile(data: items[i])),
          ],
        ),
      ],
    );
  }
}

class _ServiceData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _ServiceData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ServiceTile extends StatelessWidget {
  final _ServiceData data;
  const _ServiceTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            // Плашка-чип как у «Ближайшего турнира»: фон карточки + тонкая рамка.
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
              ),
              // Зелёный по запросу (близок к AppTheme.accent 0xFF22C47A, но точнее).
              child: Icon(data.icon, color: const Color(0xFF22C55E), size: 26),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: Text(
                data.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
