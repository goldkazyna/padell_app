/// Форматы пар в плей-офф Американо — единый список для экранов создания и
/// настроек турнира.
///
/// Раньше каждый экран держал свой набор, и они разошлись с веб-админкой:
/// формат «Верх/низ» существовал на сервере и в вебе, а в приложении его
/// просто не было. Набор зависит от числа групп и типа сетки — ровно так же,
/// как в веб-форме.
class AmericanoPlayoffFormat {
  const AmericanoPlayoffFormat(this.value, this.label);

  final String value;
  final String label;
}

/// Доступные форматы для [groupsCount] групп и типа плей-офф [playoffType]
/// (`final_only` | `semifinal_final`). Пустой список — выбора нет.
List<AmericanoPlayoffFormat> americanoPlayoffFormats({
  required int groupsCount,
  required String playoffType,
}) {
  final isSemi = playoffType == 'semifinal_final';

  // Три и больше групп: пары по местам в группах не сложить — форматы A/B
  // видят только две группы, остальные остались бы вне сетки. Играем по
  // общей таблице.
  if (groupsCount >= 3) {
    return const [
      AmericanoPlayoffFormat(
        'table_qf',
        'Общая таблица (1+4 и 2+3 ждут в полуфинале, 5–12 играют четвертьфинал)',
      ),
    ];
  }

  if (groupsCount >= 2) {
    if (!isSemi) return const []; // финал топ-4 из двух групп формата не имеет
    return const [
      AmericanoPlayoffFormat('mix', 'Микс (A1+B2 vs A3+B4, A2+B1 vs B3+A4)'),
      AmericanoPlayoffFormat(
          'group_vs', 'Группа vs Группа (A1+A2 vs B1+B2, A3+A4 vs B3+B4)'),
      AmericanoPlayoffFormat(
          'tops', 'Топы вместе (A1+B1 vs A3+B3, A2+B2 vs A4+B4)'),
      AmericanoPlayoffFormat(
          'cross', 'Крест (A1+B4 vs B1+A4, A2+B3 vs B2+A3)'),
      AmericanoPlayoffFormat(
          'top_bottom', 'Верх/низ (A1+B3 vs A2+B4, A3+B1 vs A4+B2)'),
    ];
  }

  // Одна группа: места берутся из общей таблицы.
  if (isSemi) {
    return const [
      AmericanoPlayoffFormat('mix', 'Микс (1+8 vs 4+5, 2+7 vs 3+6)'),
      AmericanoPlayoffFormat('tops', 'Топы вместе (1+2 vs 7+8, 3+4 vs 5+6)'),
      AmericanoPlayoffFormat(
          'balanced', 'Сбалансированный (1+4 vs 5+8, 2+3 vs 6+7)'),
    ];
  }

  return const [
    AmericanoPlayoffFormat('cross', '1+4 vs 2+3 (крест)'),
    AmericanoPlayoffFormat('tops', '1+2 vs 3+4 (топы вместе)'),
    AmericanoPlayoffFormat('mix', '1+3 vs 2+4 (микс)'),
  ];
}

/// Подпись над списком — как в веб-форме.
String americanoPlayoffFormatLabel({
  required int groupsCount,
  required String playoffType,
}) {
  if (groupsCount >= 3) return 'Формат плей-офф';
  if (playoffType == 'semifinal_final') return 'Формат пар в полуфиналах';
  return 'Формат пар в финале';
}

/// Привести формат к допустимому для текущего набора: при смене числа групп
/// или типа сетки сохранённое значение может оказаться из чужого набора.
String normalizeAmericanoPlayoffFormat({
  required int groupsCount,
  required String playoffType,
  required String current,
}) {
  final options =
      americanoPlayoffFormats(groupsCount: groupsCount, playoffType: playoffType);
  if (options.isEmpty) return current;
  return options.any((o) => o.value == current) ? current : options.first.value;
}
