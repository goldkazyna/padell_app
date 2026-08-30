import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/player_profile_screen.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Блок «С кем играю» в своём профиле.
///
/// Пока показывает лучшего партнёра — с кем чаще всего выигрываешь. Тап
/// открывает карточку с разбором: сколько сыграно вместе, сколько побед,
/// поражений и процент. Оттуда же можно уйти в профиль человека.
class PartnersSection extends StatefulWidget {
  const PartnersSection({super.key});

  @override
  State<PartnersSection> createState() => _PartnersSectionState();
}

class _PartnersSectionState extends State<PartnersSection> {
  PlayerPartners? _data;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ProfileService>().getPartners();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (_) {
      if (!mounted) return;
      // Блок не главный на экране: молча прячем, чтобы ошибка не перекрывала
      // рейтинг, значки и историю.
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final best = _data?.best;
    // Пока грузится или партнёров нет — блока нет вовсе: пустой заголовок
    // «С кем играю» без строки выглядел бы сломанным.
    if (_failed || best == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'С кем играю',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _partnersCountText(_data!.partnersCount),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bestCard(best),
        ],
      ),
    );
  }

  Widget _bestCard(PartnerStat p) {
    return GestureDetector(
      onTap: () => _showPartnerSheet(context, p),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Row(
          children: [
            PlayerAvatar(name: p.name, avatarUrl: p.avatar, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Лучший партнёр',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_games(p.games)} · ${_wins(p.wins)}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Карточка партнёра: разбор совместных матчей и переход в его профиль.
Future<void> _showPartnerSheet(BuildContext context, PartnerStat p) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3330),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          PlayerAvatar(name: p.name, avatarUrl: p.avatar, size: 72, circle: true),
          const SizedBox(height: 12),
          Text(
            p.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Лучший партнёр',
            style: TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat('Вместе', '${p.games}'),
              const SizedBox(width: 8),
              _stat('Побед', '${p.wins}'),
              const SizedBox(width: 8),
              _stat('Поражений', '${p.losses}'),
              const SizedBox(width: 8),
              _stat('% побед', '${p.winrate}%'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerProfileScreen(
                      playerId: p.userId,
                      playerName: p.name,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Открыть профиль',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _stat(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );

String _games(int n) => '$n ${_plural(n, 'игра', 'игры', 'игр')}';
String _wins(int n) => '$n ${_plural(n, 'победа', 'победы', 'побед')}';
String _partnersCountText(int n) =>
    '$n ${_plural(n, 'партнёр', 'партнёра', 'партнёров')}';

String _plural(int n, String one, String few, String many) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return few;
  return many;
}
