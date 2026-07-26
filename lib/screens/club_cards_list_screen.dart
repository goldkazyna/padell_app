import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club_card.dart';
import '../services/club_card_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/club_card_visual.dart';
import '../widgets/floating_tab_bar.dart';
import '../widgets/refreshable_message.dart';
import 'club_cards_screen.dart' show ClubCardLogo;
import 'club_card_detail_screen.dart';

/// Экран 2 — карты выбранного клуба (Активные / Архив).
class ClubCardsListScreen extends StatefulWidget {
  final ClubCardsGroup group;
  const ClubCardsListScreen({super.key, required this.group});

  @override
  State<ClubCardsListScreen> createState() => _ClubCardsListScreenState();
}

class _ClubCardsListScreenState extends State<ClubCardsListScreen> {
  int _tab = 0; // 0 = активные, 1 = архив
  late ClubCardsGroup _group = widget.group;

  /// Обновление: перечитываем все карты и берём группу этого же клуба.
  Future<void> _refresh() async {
    try {
      final groups = await context.read<ClubCardService>().getClubCards();
      final match =
          groups.where((g) => g.club.id == _group.club.id).toList();
      if (!mounted) return;
      if (match.isNotEmpty) {
        setState(() => _group = match.first);
      }
    } catch (_) {
      // молча — тянут-обновить не должен ронять экран
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final club = _group.club;
    final cards = _tab == 0 ? _group.activeCards : _group.archivedCards;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leadingWidth: 58,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            ClubCardLogo(name: club.name, logo: club.logo, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                club.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      body: Stack(children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(
              children: [
                _Tab(
                  label: l.clubCardsActive,
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 22),
                _Tab(
                  label: l.clubCardsArchive,
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: cards.isEmpty
                ? RefreshableMessage(
                    onRefresh: _refresh,
                    child: Text(
                      _tab == 0 ? l.clubCardsNoActive : l.clubCardsArchiveEmpty,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppTheme.accent,
                    backgroundColor: AppTheme.card,
                    child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 11),
                    itemBuilder: (_, i) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ClubCardDetailScreen(card: cards[i], club: club),
                        ),
                      ),
                      child: ClubCardVisual(card: cards[i], club: club),
                    ),
                  ),
                  ),
          ),
        ],
      ),
      const FloatingTabBar(),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accent : const Color(0xFF5C665F),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Плитка карты в списке (переиспользуется).
class ClubCardTile extends StatelessWidget {
  final ClubCard card;
  final VoidCallback onTap;
  const ClubCardTile({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dim = card.isActual ? 1.0 : 0.55;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: dim,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _KindChip(card: card),
                  const Spacer(),
                  Text(
                    card.code,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFeatures: const [],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                card.typeName ?? clubCardKindLabel(l, card),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (card.isCounter) ...[
                Text.rich(
                  TextSpan(
                    text: l.clubCardRemaining(
                        card.balance ?? 0, card.initialBalance ?? 0),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                _Progress(
                    value: (card.initialBalance ?? 0) > 0
                        ? (card.balance ?? 0) / (card.initialBalance ?? 1)
                        : 0,
                    active: card.isActual),
              ] else if (card.isDiscount) ...[
                Text(
                  '−${card.discountPercent ?? 0}%',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    _expiryLabel(l, card),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  if (card.isExpired)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        l.clubCardExpired,
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  final ClubCard card;
  const _KindChip({required this.card});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final disc = card.isDiscount;
    final color = disc ? const Color(0xFFF59E0B) : AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        clubCardKindLabel(l, card),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final double value;
  final bool active;
  const _Progress({required this.value, required this.active});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: const Color(0xFF12211A),
        valueColor: AlwaysStoppedAnimation(
            active ? AppTheme.accent : const Color(0xFF4B5852)),
      ),
    );
  }
}

/// Локализованное название типа карты по kind (фоллбэк — kindName с бэка).
String clubCardKindLabel(AppLocalizations l, ClubCard card) {
  switch (card.kind) {
    case 'visits':
      return l.clubCardKindVisits;
    case 'trainer':
      return l.clubCardKindTrainer;
    case 'discount_court':
      return l.clubCardKindDiscountCourt;
    case 'discount_trainer':
      return l.clubCardKindDiscountTrainer;
    default:
      return card.kindName ?? '';
  }
}

/// «до 31.08.2026» / «Бессрочная».
String _expiryLabel(AppLocalizations l, ClubCard card) {
  if (card.expiresAt == null) return l.clubCardUnlimited;
  return '${l.clubCardValidUntilShort} ${formatCardDate(card.expiresAt!)}';
}

/// «yyyy-MM-dd» → «dd.MM.yyyy».
String formatCardDate(String iso) {
  final d = iso.split('-');
  if (d.length != 3) return iso;
  return '${d[2]}.${d[1]}.${d[0]}';
}
