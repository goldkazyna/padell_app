import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../theme/app_theme.dart';
import '../widgets/achievements/achievement_badge.dart';
import '../widgets/achievements/achievement_sheet.dart';
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
        const SizedBox(height: 20),
        // Порядок групп задан явно, чтобы «Первые шаги» всегда были сверху.
        for (final entry in achievementGroups.entries)
          ..._group(entry.value, items.where((a) => a.group == entry.key).toList()),
      ],
    );
  }

  List<Widget> _group(String title, List<Achievement> items) {
    if (items.isEmpty) return const [];

    return [
      Text(
        title,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
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
