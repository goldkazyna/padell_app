import 'package:flutter/material.dart';

import '../models/training.dart';
import '../theme/app_theme.dart';

/// Места на тренировке кружками: занятые с аватаром и именем, свободные —
/// пунктирным кружком с плюсом.
///
/// Один виджет на два экрана: у игрока свободный кружок кликабельный
/// (записаться), у тренера он просто показывает заполненность.
class TrainingSeats extends StatelessWidget {
  final Training training;

  /// Тап по свободному месту. null — кружки только показывают состав.
  final VoidCallback? onTapFree;

  const TrainingSeats({super.key, required this.training, this.onTapFree});

  @override
  Widget build(BuildContext context) {
    final taken = training.participants;
    final free = (training.capacity - taken.length).clamp(0, 99);

    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: [
        for (final p in taken)
          _Seat(
            label: _initials(p.name),
            caption: p.isMe ? 'Вы' : _shortName(p.name),
            avatar: p.avatar,
            highlighted: p.isMe,
          ),
        for (int i = 0; i < free; i++)
          _Seat.free(
            caption: 'Свободно',
            onTap: onTapFree,
          ),
      ],
    );
  }

  /// «Дана Сеитова» → «ДС». Для одного слова — первая буква.
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.elementAt(1).characters.first)
        .toUpperCase();
  }

  /// «Дана Сеитова» → «Дана С.»: полное имя в 66 пикселей не помещается.
  static String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.elementAt(1).characters.first.toUpperCase()}.';
  }
}

class _Seat extends StatelessWidget {
  final String? label;
  final String caption;
  final String? avatar;
  final bool highlighted;
  final bool isFree;
  final VoidCallback? onTap;

  const _Seat({
    required this.label,
    required this.caption,
    this.avatar,
    this.highlighted = false,
  })  : isFree = false,
        onTap = null;

  const _Seat.free({required this.caption, this.onTap})
      : label = null,
        avatar = null,
        highlighted = false,
        isFree = true;

  @override
  Widget build(BuildContext context) {
    final circle = isFree ? _freeCircle() : _takenCircle();

    return SizedBox(
      width: 66,
      child: Column(
        children: [
          onTap == null
              ? circle
              : InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: circle,
                ),
          const SizedBox(height: 6),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              color: highlighted
                  ? AppTheme.accent
                  : (isFree ? AppTheme.textDim : AppTheme.textSecondary),
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _takenCircle() {
    final hasPhoto = (avatar ?? '').isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Своё место — сплошной акцент, чужие приглушённый зелёный.
        color: highlighted ? AppTheme.accent : const Color(0xFF2E4E3C),
        border: highlighted
            ? Border.all(color: const Color(0xFF86EFAC), width: 1.5)
            : null,
        image: hasPhoto
            ? DecorationImage(image: NetworkImage(avatar!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      // Инициалы — запасной вариант, когда фото не загружено.
      child: hasPhoto
          ? null
          : Text(
              label ?? '?',
              style: TextStyle(
                color: highlighted ? const Color(0xFF06120A) : const Color(0xFFCFF3DE),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  Widget _freeCircle() {
    final active = onTap != null;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppTheme.accent : AppTheme.border,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.add,
        size: 24,
        color: active ? AppTheme.accent : AppTheme.textDim,
      ),
    );
  }
}
