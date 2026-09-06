import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Заголовок раздела: одно начертание на все экраны.
///
/// [subtitle] — серая приписка сразу за названием («12 из 30», «8 партнёров»),
/// [trailing] — действие справа акцентом («Все»).
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final VoidCallback? onInfoTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTrailingTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Text(
                subtitle!,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
            if (onInfoTap != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onInfoTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent.withAlpha(25),
                    border: Border.all(
                      color: AppTheme.accent.withAlpha(90),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '?',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
