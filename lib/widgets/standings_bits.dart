import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Мелочи, общие для всех турнирных таблиц: имя игрока и легенда колонок.
///
/// Таблицы живут в трёх экранах (админка, live, результаты) и раньше
/// расходились в мелочах. Здесь собрано то, что должно выглядеть одинаково.

/// Имя игрока в две строки: имя сверху, фамилия снизу.
///
/// В одну строку «Аркадий Абдулов» съедает половину ширины таблицы, и на
/// цифры места не остаётся. Разбиваем по первому пробелу: остаток уходит
/// вниз целиком — двойные фамилии и отчества не теряются.
class StandingsName extends StatelessWidget {
  final String name;
  final double fontSize;
  final Color? color;

  /// Что показать справа от имени — галочка верификации, метка группы.
  final List<Widget> trailing;

  const StandingsName({
    super.key,
    required this.name,
    this.fontSize = 13,
    this.color,
    this.trailing = const [],
  });

  /// [имя, остаток] — вторая строка пустая, если пробела нет.
  static List<String> split(String full) {
    final trimmed = full.trim();
    final space = trimmed.indexOf(' ');
    if (space <= 0) return [trimmed, ''];

    return [
      trimmed.substring(0, space),
      trimmed.substring(space + 1).trim(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final parts = split(name);
    final textColor = color ?? AppTheme.textPrimary;

    final first = Text(
      parts[0],
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing.isEmpty)
          first
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: first),
              const SizedBox(width: 5),
              ...trailing,
            ],
          ),
        if (parts[1].isNotEmpty)
          Text(
            parts[1],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
      ],
    );
  }
}

/// Расшифровка однобуквенных заголовков под таблицей.
///
/// В шапке колонки подписаны одной буквой — иначе «Пропущено» растягивает
/// таблицу шире экрана. Что значит каждая буква, объясняем здесь.
class StandingsLegend extends StatelessWidget {
  /// Пары «буква — значение» в порядке колонок.
  final List<(String, String)> items;
  final EdgeInsets padding;

  const StandingsLegend({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.fromLTRB(4, 8, 4, 2),
  });

  /// Набор для таблиц с забитыми/пропущенными.
  static const scoring = <(String, String)>[
    ('В', 'победы'),
    ('П', 'поражения'),
    ('Н', 'ничьи'),
    ('З', 'забито'),
    ('Пр', 'пропущено'),
    ('±', 'разница'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 10,
        runSpacing: 3,
        children: [
          for (final (letter, meaning) in items)
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: letter,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: ' — $meaning'),
              ]),
              style: TextStyle(color: AppTheme.textDim, fontSize: 10),
            ),
        ],
      ),
    );
  }
}
