import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Красивый ввод кода из отдельных боксов (как OTP в большинстве приложений).
/// Под капотом — один скрытый TextField, поверх рисуются [length] боксов.
class OtpCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  /// Цвет активного бокса/курсора (зелёный для входа, красный для удаления).
  final Color activeColor;
  final bool autofocus;

  const OtpCodeInput({
    super.key,
    this.length = 4,
    required this.onChanged,
    this.onCompleted,
    this.activeColor = AppTheme.accent,
    this.autofocus = true,
  });

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final focused = _focusNode.hasFocus;

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            final filled = i < text.length;
            final isActive = focused && i == text.length;
            return Container(
              width: 62,
              height: 66,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive
                      ? widget.activeColor
                      : (filled
                          ? widget.activeColor.withValues(alpha: 0.4)
                          : const Color(0xFF2A2A2A)),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Text(
                filled ? text[i] : '',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        // Прозрачный TextField поверх — ловит тапы и ввод с клавиатуры.
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              showCursor: false,
              enableInteractiveSelection: false,
              onTap: () => setState(() {}),
              onChanged: _onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
