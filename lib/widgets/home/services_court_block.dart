import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/game_provider.dart';
import '../../screens/certificates_screen.dart';
import '../../screens/club_cards_screen.dart';
import '../../screens/clubs_list_screen.dart';
import '../../screens/games_screen.dart';
import '../../screens/leagues_screen.dart';
import '../../screens/trainings_screen.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../utils/profile_incomplete_guard.dart';
import '../court_menu_panel.dart';

/// «Сервисы» на главной: восемь зон на корте.
///
/// Заменило сетку 4×2 из одинаковых квадратов. Там все восемь входов кричали
/// одинаково громко, а под иконкой было только слово — «Клубные карты» и
/// «Сертификаты» весили столько же, сколько «Лиги». Здесь тот же блок, что
/// в меню профиля: у каждой зоны есть подпись, число или метка, и главная с
/// профилем читаются как одно приложение.
class ServicesCourtBlock extends StatefulWidget {
  /// Счётчик «потяните, чтобы обновить» с главной: свой RefreshIndicator
  /// у блока не работает — он внутри чужого списка.
  final int refreshTick;

  const ServicesCourtBlock({super.key, this.refreshTick = 0});

  @override
  State<ServicesCourtBlock> createState() => _ServicesCourtBlockState();
}

class _ServicesCourtBlockState extends State<ServicesCourtBlock> {
  /// Сколько тренировок открыто для записи. Счётчик живёт здесь: после
  /// возврата с экрана его нужно перечитать, иначе показывает число,
  /// которого уже нет.
  int _trainings = 0;

  /// Сколько игр в ленте.
  int _games = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ServicesCourtBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) _load();
  }

  /// Счётчики тянем по отдельности: любой может не ответить, и это не повод
  /// оставлять весь блок без цифр.
  Future<void> _load() async {
    final trainings = context.read<TrainingService>();
    final games = context.read<GameProvider>();

    try {
      final counts = await trainings.getCounts();
      if (mounted) setState(() => _trainings = counts.available);
    } catch (_) {}

    try {
      final count = await games.countFeed();
      if (mounted) setState(() => _games = count);
    } catch (_) {}
  }

  Future<void> _open(Widget screen, {bool needProfile = false}) async {
    if (needProfile && !ensureProfileComplete(context)) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

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
        const SizedBox(height: 14),
        CourtMenuPanel(
          rows: [
            CourtMenuRow.cells(
              cells: [
                CourtMenuZone(
                  // Та же иконка, что у раздела «Лиги» в турнирах: одна
                  // вещь — один значок.
                  icon: Icons.leaderboard_outlined,
                  accent: true,
                  compact: true,
                  title: l.leaguesTitle,
                  subtitle: l.serviceLeaguesSub,
                  onTap: () => _open(const LeaguesScreen()),
                ),
                CourtMenuZone(
                  icon: Icons.apartment_outlined,
                  compact: true,
                  title: l.serviceClubs,
                  subtitle: l.serviceClubsSub,
                  onTap: () => _open(ClubsListScreen(title: l.serviceClubs)),
                ),
                CourtMenuZone(
                  icon: Icons.fitness_center_outlined,
                  compact: true,
                  title: l.serviceTrainings,
                  subtitle: l.serviceTrainingsSub,
                  // Есть занятия — показываем их число, нет — метку новой
                  // фичи.
                  value: _trainings > 0 ? '$_trainings' : null,
                  tag: _trainings > 0 ? null : 'NEW',
                  onTap: () =>
                      _open(const TrainingsScreen(), needProfile: true),
                ),
                CourtMenuZone(
                  icon: Icons.sports_esports_outlined,
                  compact: true,
                  title: l.serviceGames,
                  subtitle: l.serviceGamesSub,
                  // Игр нет — числа нет: ноль зовёт зря.
                  value: _games > 0 ? '$_games' : null,
                  onTap: () => _open(const GamesScreen(), needProfile: true),
                ),
              ],
            ),
            CourtMenuRow.cells(
              divider: false,
              cells: [
                CourtMenuZone(
                  icon: Icons.groups_outlined,
                  compact: true,
                  title: l.serviceCommunity,
                  subtitle: l.serviceCommunitySub,
                  onTap: () => _open(ClubsListScreen(
                    type: 'community',
                    title: l.serviceCommunity,
                  )),
                ),
                CourtMenuZone(
                  icon: Icons.credit_card_outlined,
                  compact: true,
                  title: l.serviceClubCards,
                  subtitle: l.serviceClubCardsSub,
                  onTap: () => _open(const ClubCardsScreen()),
                ),
                CourtMenuZone(
                  icon: Icons.workspace_premium_outlined,
                  compact: true,
                  title: l.serviceCertificates,
                  subtitle: l.serviceCertificatesSub,
                  onTap: () => _open(const CertificatesScreen()),
                ),
                CourtMenuZone(
                  icon: Icons.shopping_bag_outlined,
                  compact: true,
                  title: l.serviceShop,
                  subtitle: l.serviceShopSub,
                  onTap: () => showAppAlert(context, l.serviceComingSoon),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
