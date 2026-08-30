import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../theme/app_theme.dart';
import '../widgets/achievements/achievement_badge.dart';
import '../widgets/achievements/achievement_sheet.dart';
import '../widgets/achievements/medal_art.dart';
import '../widgets/app_back_button.dart';
import '../widgets/floating_tab_bar.dart';

/// Все значки игрока по группам.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AchievementService>().mine();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text('Достижения',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      // Таблетка нижнего меню остаётся поверх содержимого, как на остальных
      // вложенных экранах: с достижений уходят обратно в разделы, а не назад.
      body: Stack(children: [
        RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.card,
          onRefresh: _load,
          child: _body(),
        ),
        const FloatingTabBar(),
      ]),
    );
  }

  Widget _body() {
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Text('Не удалось загрузить',
                    style: TextStyle(color: AppTheme.textSecondary)),
                TextButton(
                  onPressed: _load,
                  child: Text('Повторить',
                      style: TextStyle(color: AppTheme.accent)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final items = _items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    final unlocked = items.where((a) => a.isUnlocked).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      children: [
        Text(
          'Получено $unlocked из ${items.length}',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Чем ниже раздел, тем реже значок',
          style: TextStyle(color: AppTheme.textDim, fontSize: 12),
        ),
        const SizedBox(height: 18),
        // Разделы по сложности, а не по теме: цвет медали и был главным
        // вопросом игроков — теперь он и есть заголовок раздела.
        for (final entry in achievementTiers.entries)
          ..._tier(entry.key, entry.value,
              items.where((a) => a.tier == entry.key).toList()),
      ],
    );
  }

  List<Widget> _tier(String tier, String explain, List<Achievement> items) {
    if (items.isEmpty) return const [];

    final metal = MedalMetal.of(tier);
    final done = items.where((a) => a.isUnlocked).length;

    return [
      Row(
        children: [
          // Кружок того же металла, что и медали раздела.
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [metal.light, metal.dark],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            MedalMetal.nameOf(tier),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x0FFFFFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$done из ${items.length}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        explain,
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.35),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 20,
        children: items
            .map((a) => AchievementBadge(
                  achievement: a,
                  onTap: () => showAchievementSheet(context, a),
                ))
            .toList(),
      ),
      const SizedBox(height: 26),
    ];
  }
}
