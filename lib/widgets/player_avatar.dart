import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Аватар игрока: фото, а если его нет или картинка не загрузилась — инициалы.
///
/// Раньше эта конструкция копировалась в каждый список игроков, и в половине
/// мест аватара просто не было — человек в рейтинге с фото, а в поиске уже
/// безликий кружок. Правила — в docs/DESIGN_SYSTEM.md.
class PlayerAvatar extends StatelessWidget {
  final String? avatarUrl;

  /// Имя нужно, чтобы собрать инициалы, когда фото нет.
  final String name;

  final double size;

  /// Квадрат со скруглением (списки) или круг (карточки, чипы).
  final bool circle;

  /// Подсветка своей строки: рамка и цвет инициалов под акцент.
  final bool highlighted;

  const PlayerAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 40,
    this.circle = false,
    this.highlighted = false,
  });

  /// Первые буквы имени и фамилии: «Денис Дудников» → «ДД».
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = highlighted ? AppTheme.accent : AppTheme.textPrimary;

    final placeholder = Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.accent.withValues(alpha: 0.16)
            : const Color(0xFF2A3330),
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      clipBehavior: Clip.antiAlias,
      child: (avatarUrl != null && avatarUrl!.isNotEmpty)
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              // Битая ссылка не должна оставлять пустой квадрат.
              errorBuilder: (_, _, _) => placeholder,
            )
          : placeholder,
    );
  }
}
