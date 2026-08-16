/// Значок игрока: что это, сколько сделано и получен ли.
class Achievement {
  final String code;
  final String title;
  final String description;
  final String icon;
  final String group;
  final int progress;
  final int target;
  final DateTime? unlockedAt;

  const Achievement({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.group,
    required this.progress,
    required this.target,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  /// Доля выполнения от 0 до 1 — для полоски прогресса.
  double get progressRatio =>
      target <= 0 ? 0 : (progress / target).clamp(0.0, 1.0);

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final unlocked = json['unlocked_at'] as String?;
    return Achievement(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'emoji_events',
      group: json['group'] as String? ?? 'first_steps',
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
      unlockedAt: unlocked == null ? null : DateTime.tryParse(unlocked),
    );
  }
}

/// Названия групп значков в порядке показа на экране.
const achievementGroups = <String, String>{
  'first_steps': 'Первые шаги',
  'wins': 'Победы',
  'rating': 'Рейтинг',
  'variety': 'Кругозор',
  'together': 'Вместе',
};
