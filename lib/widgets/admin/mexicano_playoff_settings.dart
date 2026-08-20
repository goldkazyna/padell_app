import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Настройки плей-офф Мексикано: включение, тип сетки и формат пар.
///
/// У Мексикано нет групп, нижней сетки и матча за 3-е место — сервер их для
/// этого формата не строит, поэтому набор полей свой, а не общий с Американо.
/// Формат пар нужен только для полуфиналов: финал топ-4 сервер всегда собирает
/// как 1+4 vs 2+3.
class MexicanoPlayoffSettings extends StatelessWidget {
  const MexicanoPlayoffSettings({
    super.key,
    required this.hasPlayoff,
    required this.playoffType,
    required this.playoffFormat,
    required this.onHasPlayoffChanged,
    required this.onTypeChanged,
    required this.onFormatChanged,
    this.enabled = true,
  });

  final bool hasPlayoff;

  /// `final_only` — топ-4 сразу в финал; `semifinal_final` — топ-8.
  final String playoffType;

  /// `mix` | `tops` | `balanced` — как разбиваются пары в полуфиналах.
  final String playoffFormat;

  final ValueChanged<bool> onHasPlayoffChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onFormatChanged;

  final bool enabled;

  static const List<(String, String)> _formats = [
    ('mix', 'Микс (1+8 vs 4+5, 2+7 vs 3+6)'),
    ('tops', 'Топы вместе (1+2 vs 7+8, 3+4 vs 5+6)'),
    ('balanced', 'Сбалансированный (1+4 vs 5+8, 2+3 vs 6+7)'),
  ];

  @override
  Widget build(BuildContext context) {
    final isSemi = playoffType == 'semifinal_final';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _checkbox(
          value: hasPlayoff,
          label: 'Добавить плей-офф (после основных раундов)',
          onChanged: enabled ? onHasPlayoffChanged : null,
        ),
        if (hasPlayoff) ...[
          const SizedBox(height: 10),
          _label('Тип плей-офф'),
          Row(
            children: [
              _typeButton('final_only', 'Только финал\nтоп-4'),
              const SizedBox(width: 6),
              _typeButton('semifinal_final', 'Полуфинал + финал\nтоп-8'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isSemi
                ? 'Нужно минимум 8 участников — иначе сетка не построится.'
                : 'Топ-4 играют один матч: 1+4 vs 2+3.',
            style: TextStyle(color: AppTheme.textDim, fontSize: 11),
          ),
          if (isSemi) ...[
            const SizedBox(height: 12),
            _label('Формат пар в полуфиналах'),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardRaised,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  for (final format in _formats)
                    InkWell(
                      onTap: enabled ? () => onFormatChanged(format.$1) : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              playoffFormat == format.$1
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: playoffFormat == format.$1
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                format.$2,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Цифры — места в таблице лидеров после основных раундов.',
              style: TextStyle(color: AppTheme.textDim, fontSize: 11),
            ),
          ],
        ],
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _typeButton(String value, String label) {
    final active = playoffType == value;

    return Expanded(
      child: GestureDetector(
        onTap: enabled ? () => onTypeChanged(value) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.accent.withValues(alpha: 0.15)
                : AppTheme.cardRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppTheme.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? AppTheme.accent : AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkbox({
    required bool value,
    required String label,
    required ValueChanged<bool>? onChanged,
  }) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged(!value),
      child: Opacity(
        opacity: onChanged == null ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                value ? Icons.check_box : Icons.check_box_outline_blank,
                color: value ? AppTheme.accent : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style:
                      TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
