import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Переключатель разделов экрана — две-три равные пилюли в одной капсуле.
///
/// Не путать с [AppTabs]: те переключают вкладки внутри одного раздела
/// («Открытые / Мои / Архив») и подчёркиваются. Этот переключает сам
/// раздел — то, что могло бы быть отдельными экранами («Турниры / Лиги»).
/// Когда на экране есть оба уровня, разная форма спасает от путаницы.
class AppSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int current;
  final ValueChanged<int> onChanged;

  /// Иконки разделов — по одной на подпись. Пусто — только текст.
  final List<IconData>? icons;

  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.current,
    required this.onChanged,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(child: _segment(i)),
        ],
      ),
    );
  }

  Widget _segment(int index) {
    final active = index == current;
    final icon = (icons != null && index < icons!.length) ? icons![index] : null;
    final color = active ? AppTheme.accent : const Color(0xFF71717A);

    return GestureDetector(
      onTap: () {
        if (index != current) onChanged(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 7),
            ],
            Text(
              labels[index],
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
