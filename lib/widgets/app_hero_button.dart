import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Главная кнопка экрана: акцентный градиент, иконка в квадрате, шеврон.
///
/// Отличается от [AppPrimaryButton] намеренно — так выделяется одно, самое
/// важное действие экрана («Позвать на турнир»). Но зелёный берётся из
/// токена темы: раньше тут жил свой оттенок `#22C55E`, и рядом с обычной
/// акцентной кнопкой они выглядели из разных наборов.
///
/// Текст и иконка чёрные — как и на любой заливке акцентом в приложении.
class AppHeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  /// Крутилка вместо иконки, пока идёт запрос.
  final bool busy;

  const AppHeroButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.busy = false,
  });

  /// Тёмный конец градиента — тот же акцент, уведённый в темноту.
  static Color get _deep =>
      Color.lerp(AppTheme.accent, const Color(0xFF06120C), 0.62)!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.accent, _deep],
          ),
          boxShadow: [
            BoxShadow(
              // Свечение слабее прежнего: кнопка и так самая яркая на экране.
              color: AppTheme.accent.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: busy
                  ? const Padding(
                      padding: EdgeInsets.all(7),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(icon, color: Colors.black, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 22),
          ],
        ),
      ),
    );
  }
}
