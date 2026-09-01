import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Вкладки внутри экрана — как «Открытые / Мои / Архив» в турнирах.
///
/// Подчёркивание, а не пилюли: пилюля рядом с фильтрами-пилюлями читается как
/// ещё один фильтр, а не как раздел экрана. Строка вкладок отделена от
/// содержимого тонкой линией и прокручивается вбок, если заголовки не влезли.
class AppTabs extends StatelessWidget {
  final List<String> labels;
  final int current;
  final ValueChanged<int> onChanged;

  /// Счётчик у вкладки: «Этапы 8». null — без счётчика.
  final List<int?>? counts;

  const AppTabs({
    super.key,
    required this.labels,
    required this.current,
    required this.onChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) _tab(i),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final active = index == current;
    final count = counts != null && index < counts!.length ? counts![index] : null;

    return GestureDetector(
      onTap: () {
        if (index != current) onChanged(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labels[index],
              style: TextStyle(
                color: active ? AppTheme.accent : const Color(0xFF52525B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.accent.withValues(alpha: 0.16)
                      : const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: active ? AppTheme.accent : const Color(0xFF52525B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
