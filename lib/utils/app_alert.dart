import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Показать модальное окно с сообщением. Заменяет SnackBar везде в проекте —
/// мы решили отказаться от SnackBar в пользу явных диалогов.
///
/// [title] — необязательный заголовок (если null, показывается только текст).
/// [isError] — окрашивает заголовок/иконку в красный.
Future<void> showAppAlert(
  BuildContext context,
  String message, {
  String? title,
  bool isError = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final accent = isError ? AppTheme.error : AppTheme.accent;
      return AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: title == null
            ? null
            : Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline
                        : Icons.info_outline,
                    color: accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );
}
