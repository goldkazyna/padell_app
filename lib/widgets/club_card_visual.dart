import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/club_card.dart';

/// «#RRGGBB» / «#AARRGGBB» → Color (или null).
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

Color _shade(Color c, double p) =>
    p >= 0 ? Color.lerp(c, Colors.white, p)! : Color.lerp(c, Colors.black, -p)!;

/// Премиум-карта клуба (Вариант 2): фон/акцент/прогресс — из цветов клуба.
class ClubCardVisual extends StatelessWidget {
  final ClubCard card;
  final ClubCardClubBrief club;
  const ClubCardVisual({super.key, required this.card, required this.club});

  static const _defBg = Color(0xFF1C2421);
  static const _defAccent = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bg = parseHexColor(club.cardBgColor) ?? _defBg;
    final accent = parseHexColor(club.cardAccentColor) ?? _defAccent;
    final progress = parseHexColor(club.cardProgressColor) ?? _defAccent;
    final opacity = card.isActual ? 1.0 : 0.55;

    return Opacity(
      opacity: opacity,
      child: AspectRatio(
        aspectRatio: 1.72,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [_shade(bg, 0.14), bg, _shade(bg, -0.26)],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Акцент-полоса слева
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [accent, _shade(accent, -0.4)],
                    ),
                  ),
                ),
              ),
              // Контент
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 15, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _LogoBadge(name: club.name, logo: club.logo),
                        const Spacer(),
                        _KindBadge(card: card),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      card.typeName ?? _kindLabel(l, card),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (card.isCounter) ...[
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '${card.balance ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${card.initialBalance ?? 0}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (card.initialBalance ?? 0) > 0
                              ? ((card.balance ?? 0) / (card.initialBalance ?? 1))
                                  .clamp(0.0, 1.0)
                              : 0,
                          minHeight: 6,
                          backgroundColor: Colors.black.withValues(alpha: 0.32),
                          valueColor: AlwaysStoppedAnimation(progress),
                        ),
                      ),
                    ] else if (card.isDiscount)
                      Text(
                        '−${card.discountPercent ?? 0}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          card.code,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 12.5,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          card.expiresAt == null
                              ? l.clubCardUnlimited
                              : '${l.clubCardValidUntilShort} ${_fmtDate(card.expiresAt!)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (card.isExpired) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          l.clubCardExpired,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final String name;
  final String? logo;
  const _LogoBadge({required this.name, this.logo});

  @override
  Widget build(BuildContext context) {
    final abbr = name.isNotEmpty
        ? name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join().toUpperCase()
        : '?';
    final hasLogo = logo != null && logo!.isNotEmpty;
    return Container(
      width: 42,
      height: 42,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        // без белой рамки: под лого — прозрачно, под инициалами — лёгкая тёмная плашка
        color: hasLogo ? null : Colors.black.withValues(alpha: 0.22),
      ),
      child: hasLogo
          ? Image.network(logo!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(abbr))
          : _fallback(abbr),
    );
  }

  Widget _fallback(String t) => Center(
        child: Text(t,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
      );
}

class _KindBadge extends StatelessWidget {
  final ClubCard card;
  const _KindBadge({required this.card});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        _kindLabel(l, card),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

String _kindLabel(AppLocalizations l, ClubCard card) {
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

String _fmtDate(String iso) {
  final d = iso.split('-');
  if (d.length != 3) return iso;
  return '${d[2]}.${d[1]}.${d[0]}';
}
