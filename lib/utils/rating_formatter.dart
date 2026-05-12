/// Утилита форматирования рейтинга и уровня в зависимости от настройки
/// «Точные значения» (см. SettingsProvider.preciseRating).
class RatingFormatter {
  /// Рейтинг.
  /// Обычный режим: `2560`. Точный режим: `2.56`.
  static String formatRating(int rating, bool precise) {
    if (precise) {
      return (rating / 1000).toStringAsFixed(2);
    }
    return rating.toString();
  }

  /// Уровень.
  /// Обычный режим: `bucketedLevel` (как пришло с бэка, например `"2.50"`).
  /// Точный режим: `rating / 1000` с двумя знаками (например `"2.69"`).
  ///
  /// `bucketedLevel` может быть `String`, `num` или `null`.
  static String formatLevel({
    required dynamic bucketedLevel,
    required int rating,
    required bool precise,
  }) {
    if (precise) {
      return (rating / 1000).toStringAsFixed(2);
    }
    if (bucketedLevel is num) {
      return bucketedLevel.toDouble().toStringAsFixed(2);
    }
    if (bucketedLevel is String) {
      final parsed = double.tryParse(bucketedLevel);
      if (parsed != null) return parsed.toStringAsFixed(2);
      return bucketedLevel;
    }
    return '-';
  }

  /// Категория уровня "1"/"2"/"3"/"4".
  static String levelCategory(dynamic level) {
    double l;
    if (level is num) {
      l = level.toDouble();
    } else if (level is String) {
      l = double.tryParse(level) ?? 0;
    } else {
      l = 0;
    }
    if (l >= 4.0) return '4';
    if (l >= 3.0) return '3';
    if (l >= 2.0) return '2';
    return '1';
  }

  /// Изменение рейтинга со знаком: `+150` / `-150` или `+0.15` / `-0.15`.
  /// `decimals` — кол-во знаков после запятой в точном режиме (по умолчанию 2).
  static String formatRatingChange(int change, bool precise, {int decimals = 2}) {
    if (precise) {
      final v = (change / 1000);
      final sign = change > 0 ? '+' : (change < 0 ? '' : '+');
      return '$sign${v.toStringAsFixed(decimals)}';
    }
    final sign = change > 0 ? '+' : '';
    return '$sign$change';
  }

  /// `L1 · 2.50` (обычный режим) или `2.69` (точный режим).
  static String formatLevelLabel({
    required dynamic bucketedLevel,
    required int rating,
    required bool precise,
  }) {
    final lvl = formatLevel(
      bucketedLevel: bucketedLevel,
      rating: rating,
      precise: precise,
    );
    if (precise) return lvl;
    return 'L${levelCategory(bucketedLevel)} · $lvl';
  }
}
