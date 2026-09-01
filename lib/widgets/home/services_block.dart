import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/game_provider.dart';
import '../../services/training_service.dart';
import '../../utils/app_alert.dart';
import '../../utils/profile_incomplete_guard.dart';
import '../../screens/leagues_screen.dart';
import '../../screens/clubs_list_screen.dart';
import '../../screens/club_cards_screen.dart';
import '../../screens/create_game_screen.dart';
import '../../screens/games_screen.dart';
import '../../screens/trainings_screen.dart';
import '../../screens/certificates_screen.dart';

/// Блок «Сервисы» на главной — сетка 4×2 быстрых входов.
/// Иконки монохромные (единый цвет). [onOpenTournaments] переключает нижнюю
/// навигацию на вкладку «Турниры».
class ServicesBlock extends StatefulWidget {
  final VoidCallback onOpenTournaments;

  /// Счётчик «потяните, чтобы обновить» с главной. Меняется — перечитываем
  /// число тренировок: свой RefreshIndicator у блока не работает, он внутри
  /// чужого списка.
  final int refreshTick;

  const ServicesBlock({
    super.key,
    required this.onOpenTournaments,
    this.refreshTick = 0,
  });

  @override
  State<ServicesBlock> createState() => _ServicesBlockState();
}

class _ServicesBlockState extends State<ServicesBlock> {
  /// Сколько тренировок открыто для записи. Счётчик живёт здесь, а не на
  /// главной: после возврата с экрана тренировок его нужно перечитать —
  /// иначе бейдж показывает число, которого уже нет.
  int _availableTrainings = 0;

  /// Сколько игр в ленте — тем же бейджем, что у тренировок.
  int _openGames = 0;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
    _loadGames();
  }

  @override
  void didUpdateWidget(covariant ServicesBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      _loadTrainings();
      _loadGames();
    }
  }

  Future<void> _loadTrainings() async {
    final counts = await context.read<TrainingService>().getCounts();
    if (!mounted) return;
    setState(() => _availableTrainings = counts.available);
  }

  Future<void> _loadGames() async {
    final count = await context.read<GameProvider>().countFeed();
    if (!mounted) return;
    setState(() => _openGames = count);
  }

  Future<void> _openTrainings() async {
    if (!ensureProfileComplete(context)) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrainingsScreen()),
    );
    _loadTrainings();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final items = <_ServiceData>[
      _ServiceData(
        // Та же иконка, что у раздела «Лиги» в турнирах: одна вещь —
        // один значок, иначе плитка и раздел читаются как разное.
        icon: Icons.leaderboard_outlined,
        label: l.leaguesTitle,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LeaguesScreen())),
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
        icon: Icons.fitness_center_outlined,
        label: 'Тренировки',
        // Есть занятия — показываем их число, нет — метку новой фичи.
        badge: _availableTrainings > 0 ? '$_availableTrainings' : 'NEW',
        badgeIsNew: _availableTrainings == 0,
        onTap: _openTrainings,
      ),
      _ServiceData(
        icon: Icons.sports_esports_outlined,
        label: l.serviceGames,
        // Игр нет — бейджа нет: ноль в красном кружке зовёт зря.
        badge: _openGames > 0 ? '$_openGames' : '',
        onTap: () {
          if (!ensureProfileComplete(context)) return;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GamesScreen()))
              .then((_) => _loadGames());
        },
      ),
      _ServiceData(
        icon: Icons.credit_card_outlined,
        label: l.serviceClubCards,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ClubCardsScreen())),
      ),
      _ServiceData(
        icon: Icons.workspace_premium_outlined,
        label: l.serviceCertificates,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CertificatesScreen())),
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

  /// Надпись в кружке поверх иконки. Пусто — кружка нет.
  final String badge;

  /// Метка новой фичи: кружок шире и с другим текстом.
  final bool badgeIsNew;

  _ServiceData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = '',
    this.badgeIsNew = false,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFF2A3330), width: 0.5),
                  ),
                  // Зелёный по запросу (близок к AppTheme.accent 0xFF22C47A).
                  child:
                      Icon(data.icon, color: const Color(0xFF22C55E), size: 26),
                ),
                if (data.badge.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: data.badgeIsNew ? -10 : -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.background, width: 1.5),
                      ),
                      child: Text(
                        data.badge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: data.badgeIsNew ? 9 : 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: data.badgeIsNew ? 0.3 : 0,
                        ),
                      ),
                    ),
                  ),
              ],
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
