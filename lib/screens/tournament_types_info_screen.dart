import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

/// Информационный экран «О турнирах»: карточка на каждый тип турнира с
/// описанием — что это, как играют, как считается результат/место.
/// Тексты — в AppLocalizations (RU + EN). Открывается из меню Профиля.
class TournamentTypesInfoScreen extends StatefulWidget {
  /// Если задан — карточка этого типа откроется раскрытой, экран
  /// проскроллится к ней. Значения совпадают с типами турнира
  /// ('americano', 'americano_flex', 'king_of_court' и т.д.).
  final String? initialType;
  const TournamentTypesInfoScreen({super.key, this.initialType});

  @override
  State<TournamentTypesInfoScreen> createState() =>
      _TournamentTypesInfoScreenState();
}

class _TournamentTypesInfoScreenState
    extends State<TournamentTypesInfoScreen> {
  final GlobalKey _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _targetKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            alignment: 0.05,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Насыщенный фиолетовый из палитры (бледный AppTheme.purple не используем).
    const purple = Color(0xFF7C3AED);

    final types = <_TypeInfo>[
      _TypeInfo('americano', Icons.shuffle_rounded, AppTheme.accent,
          l.tournamentInfoAmericanoName, l.tournamentInfoAmericanoBody),
      _TypeInfo('round_robin', Icons.sync_alt_rounded, AppTheme.orange,
          l.tournamentInfoRoundRobinName, l.tournamentInfoRoundRobinBody),
      _TypeInfo('king_of_court', Icons.emoji_events_outlined, purple,
          l.tournamentInfoKingOfCourtName, l.tournamentInfoKingOfCourtBody),
      _TypeInfo('mexicano', Icons.trending_up_rounded, AppTheme.accent,
          l.tournamentInfoMexicanoName, l.tournamentInfoMexicanoBody),
      _TypeInfo('team', Icons.account_tree_outlined, AppTheme.orange,
          l.tournamentInfoTeamName, l.tournamentInfoTeamBody),
      _TypeInfo('bali_koc', Icons.groups_rounded, purple,
          l.tournamentInfoBaliKocName, l.tournamentInfoBaliKocBody),
      _TypeInfo('americano_flex', Icons.swap_horiz_rounded, AppTheme.accent,
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
                      style: TextStyle(
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
                style: TextStyle(
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
                itemBuilder: (context, i) {
                  final isTarget = types[i].key == widget.initialType;
                  return _TypeCard(
                    key: isTarget ? _targetKey : null,
                    info: types[i],
                    initiallyOpen: isTarget,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeInfo {
  final String key; // тип турнира для связи с экраном создания
  final IconData icon;
  final Color color;
  final String name;
  final String body;
  const _TypeInfo(this.key, this.icon, this.color, this.name, this.body);
}

/// Карточка-кнопка типа турнира: по тапу раскрывается описание.
class _TypeCard extends StatefulWidget {
  final _TypeInfo info;
  final bool initiallyOpen;
  const _TypeCard({super.key, required this.info, this.initiallyOpen = false});

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок-кнопка
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Описание — раскрывается по тапу
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                info.body,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
