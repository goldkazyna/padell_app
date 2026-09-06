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

/// Раскладка блока «Сервисы».
enum ServicesLayout {
  /// Ряды по две зоны с подписью — один в один меню профиля.
  wide,

  /// Четыре колонки, иконка в квадратной плашке.
  quad,

  /// Четыре колонки, иконка акцентом без плашки — как в макете.
  quadBare,
}

/// Показывать ли на главной все три раскладки сразу — чтобы выбрать на
/// живом экране, а не по картинке. Выбрали — ставим [kServicesLayout]
/// и возвращаем false.
const bool kServicesPreview = true;

/// Что показываем, когда выбор сделан.
const ServicesLayout kServicesLayout = ServicesLayout.quad;

/// «Сервисы» на главной: восемь зон на корте.
///
/// Заменило сетку 4×2 из одинаковых квадратов. Там все восемь входов кричали
/// одинаково громко, а под иконкой было только слово — «Клубные карты» и
/// «Сертификаты» весили столько же, сколько «Лиги». Здесь та же панель, что
/// в меню профиля: главная и профиль читаются как одно приложение.
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

  /// Восемь входов одним списком: раскладка меняется, состав — нет.
  List<_Service> _services(AppLocalizations l) => [
        _Service(
          // Та же иконка, что у раздела «Лиги» в турнирах: одна вещь —
          // один значок.
          icon: Icons.leaderboard_outlined,
          title: l.leaguesTitle,
          subtitle: l.serviceLeaguesSub,
          accent: true,
          onTap: () => _open(const LeaguesScreen()),
        ),
        _Service(
          icon: Icons.apartment_outlined,
          title: l.serviceClubs,
          subtitle: l.serviceClubsSub,
          onTap: () => _open(ClubsListScreen(title: l.serviceClubs)),
        ),
        _Service(
          icon: Icons.fitness_center_outlined,
          title: l.serviceTrainings,
          subtitle: l.serviceTrainingsSub,
          // Есть занятия — показываем их число, нет — метку новой фичи.
          value: _trainings > 0 ? '$_trainings' : null,
          tag: _trainings > 0 ? null : 'NEW',
          onTap: () => _open(const TrainingsScreen(), needProfile: true),
        ),
        _Service(
          icon: Icons.sports_esports_outlined,
          title: l.serviceGames,
          subtitle: l.serviceGamesSub,
          // Игр нет — числа нет: ноль зовёт зря.
          value: _games > 0 ? '$_games' : null,
          onTap: () => _open(const GamesScreen(), needProfile: true),
        ),
        _Service(
          icon: Icons.groups_outlined,
          title: l.serviceCommunity,
          subtitle: l.serviceCommunitySub,
          onTap: () => _open(ClubsListScreen(
            type: 'community',
            title: l.serviceCommunity,
          )),
        ),
        _Service(
          icon: Icons.credit_card_outlined,
          title: l.serviceClubCards,
          subtitle: l.serviceClubCardsSub,
          onTap: () => _open(const ClubCardsScreen()),
        ),
        _Service(
          icon: Icons.workspace_premium_outlined,
          title: l.serviceCertificates,
          subtitle: l.serviceCertificatesSub,
          onTap: () => _open(const CertificatesScreen()),
        ),
        _Service(
          icon: Icons.shopping_bag_outlined,
          title: l.serviceShop,
          subtitle: l.serviceShopSub,
          onTap: () => showAppAlert(context, l.serviceComingSoon),
        ),
      ];

  CourtMenuZone _zone(
    _Service s, {
    bool compact = false,
    bool bare = false,
  }) {
    return CourtMenuZone(
      icon: s.icon,
      title: s.title,
      subtitle: s.subtitle,
      accent: s.accent,
      compact: compact,
      bareIcon: bare,
      value: s.value,
      valueColor: AppTheme.accent,
      tag: s.tag,
      onTap: s.onTap,
    );
  }

  /// Ряды по две зоны — как в меню профиля.
  Widget _wide(List<_Service> items) => CourtMenuPanel(
        rows: [
          for (int r = 0; r < 4; r++)
            CourtMenuRow(
              left: _zone(items[r * 2]),
              right: _zone(items[r * 2 + 1]),
              divider: r < 3,
            ),
        ],
      );

  /// Четыре колонки в два ряда.
  Widget _quad(List<_Service> items, {required bool bare}) => CourtMenuPanel(
        rows: [
          for (int r = 0; r < 2; r++)
            CourtMenuRow.cells(
              divider: r == 0,
              cells: [
                for (int c = 0; c < 4; c++)
                  _zone(items[r * 4 + c], compact: true, bare: bare),
              ],
            ),
        ],
      );

  Widget _panel(ServicesLayout layout, List<_Service> items) {
    return switch (layout) {
      ServicesLayout.wide => _wide(items),
      ServicesLayout.quad => _quad(items, bare: false),
      ServicesLayout.quadBare => _quad(items, bare: true),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = _services(l);

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
        if (!kServicesPreview)
          _panel(kServicesLayout, items)
        else ...[
          // Временно: три раскладки подряд, чтобы выбрать на живом экране.
          const _PreviewLabel('А · по две зоны, как в профиле'),
          _panel(ServicesLayout.wide, items),
          const SizedBox(height: 18),
          const _PreviewLabel('Б · четыре колонки, иконки в плашках'),
          _panel(ServicesLayout.quad, items),
          const SizedBox(height: 18),
          const _PreviewLabel('В · четыре колонки, иконки без плашек'),
          _panel(ServicesLayout.quadBare, items),
        ],
      ],
    );
  }
}

/// Один вход в раздел: состав не зависит от того, как его разложили.
class _Service {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final String? tag;
  final bool accent;
  final VoidCallback onTap;

  _Service({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
    this.tag,
    this.accent = false,
  });
}

/// Подпись над раскладкой — только на время выбора.
class _PreviewLabel extends StatelessWidget {
  final String text;

  const _PreviewLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
