import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/achievement.dart';
import '../../screens/achievements_screen.dart';
import '../../services/achievement_service.dart';
import '../../theme/app_theme.dart';
import '../achievements/achievement_badge.dart';

/// Блок значков в своём профиле.
///
/// Сначала полученные, затем ближайшие к получению — так виден и результат,
/// и следующая цель. Полный список открывается по кнопке «Все».
class AchievementsSection extends StatefulWidget {
  const AchievementsSection({super.key});

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  List<Achievement>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AchievementService>().mine();
      if (!mounted) return;
      setState(() => _items = _ordered(items));
    } catch (_) {
      if (!mounted) return;
      // Значки — не главное на экране профиля: молча прячем блок,
      // чтобы ошибка не перекрывала рейтинг и историю.
      setState(() => _failed = true);
    }
  }

  /// Полученные вперёд, дальше — по близости к цели.
  List<Achievement> _ordered(List<Achievement> items) {
    final unlocked = items.where((a) => a.isUnlocked).toList();
    final rest = items.where((a) => !a.isUnlocked).toList()
      ..sort((a, b) => b.progressRatio.compareTo(a.progressRatio));

    return [...unlocked, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();

    final items = _items;
    final unlockedCount = items?.where((a) => a.isUnlocked).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Достижения',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unlockedCount != null) ...[
                const SizedBox(width: 8),
                Text(
                  '$unlockedCount из ${items!.length}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
              const Spacer(),
              if (items != null)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  ),
                  child: Text(
                    'Все',
                    style: TextStyle(color: AppTheme.accent, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 132,
            child: items == null
                ? _skeleton()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => AchievementBadge(achievement: items[i]),
                  ),
          ),
        ],
      ),
    );
  }

  /// Пока грузится — та же карусель заглушками, чтобы блок не прыгал.
  Widget _skeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
