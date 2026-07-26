import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Единая primary-кнопка приложения: зелёная заливка (AppTheme.accent),
/// ЧЁРНЫЙ текст и иконки, скругление 14.
///
/// По умолчанию — на всю ширину родителя, высота 52.
/// [compact] — маленькая инлайн-пилюля для карточек (размер по контенту).
/// [loading] — показывает спиннер и блокирует нажатие.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Ведущая иконка (слева от текста).
  final IconData? icon;

  /// Хвостовая иконка (справа, напр. стрелка →).
  final IconData? trailingIcon;

  final bool loading;

  /// На всю ширину родителя (актуально для не-compact).
  final bool expand;

  /// Компактная инлайн-пилюля (для карточек).
  final bool compact;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  });

  static const Color _fg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 16 : 20;
    final double fontSize = compact ? 14 : 16;

    final Widget content = loading
        ? SizedBox(
            height: iconSize + 2,
            width: iconSize + 2,
            child: const CircularProgressIndicator(strokeWidth: 2, color: _fg),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: _fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _fg,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                Icon(trailingIcon, size: iconSize, color: _fg),
              ],
            ],
          );

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: AppTheme.accent,
      foregroundColor: _fg,
      disabledBackgroundColor: AppTheme.accent.withValues(alpha: 0.45),
      disabledForegroundColor: Colors.black45,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
          : const EdgeInsets.symmetric(horizontal: 16),
      minimumSize: compact ? Size.zero : null,
      tapTargetSize: compact
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
    );

    final Widget button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: content,
    );

    if (compact) return button;
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: button,
    );
  }
}
