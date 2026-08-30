import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Сворачиваемый блок со списком внутри.
///
/// Нужен там, где список длинный и в развёрнутом виде топит остальные
/// настройки: города, клубы. Заголовок с подписью слева, шеврон справа —
/// он поворачивается вниз, когда блок открыт. Правила — в
/// docs/DESIGN_SYSTEM.md.
class AppExpandableSection extends StatefulWidget {
  final String title;

  /// Короткая сводка справа от заголовка: «Все города», «2 выключено».
  /// Видна в свёрнутом виде — по ней понятно, стоит ли открывать.
  final String? summary;

  /// Пояснение под заголовком. Показывается только в раскрытом виде.
  final String? description;

  final List<Widget> children;
  final bool initiallyExpanded;

  const AppExpandableSection({
    super.key,
    required this.title,
    required this.children,
    this.summary,
    this.description,
    this.initiallyExpanded = false,
  });

  @override
  State<AppExpandableSection> createState() => _AppExpandableSectionState();
}

class _AppExpandableSectionState extends State<AppExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    const line = Color(0xFF2A3330);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.summary != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.summary!,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Свёрнутый блок не строит содержимое вовсе: в списке клубов
          // три десятка строк с логотипами, и держать их скрытыми в дереве
          // — лишняя работа на каждом кадре.
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: line),
                      if (widget.description != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                          child: Text(
                            widget.description!,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      for (int i = 0; i < widget.children.length; i++) ...[
                        if (i > 0) const Divider(height: 1, color: line),
                        widget.children[i],
                      ],
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
