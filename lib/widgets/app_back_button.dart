import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Единая круглая кнопка «назад» 34×34 — используется на всех вложенных
/// экранах приложения. Стиль взят из EditProfileScreen.
///
/// По умолчанию делает [Navigator.of(context).maybePop()]. Если нужен
/// собственный обработчик (например, проверка изменений) — передать [onTap].
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      // Center сжимает кнопку до её размера: в leading у AppBar приходят
      // жёсткие ограничения, и без него круг растягивался на всю область —
      // на экране лиги кнопка выглядела вдвое больше, чем на остальных.
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: AppTheme.border),
            ),
          ),
          child: Icon(
            Icons.chevron_left,
            size: 20,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
