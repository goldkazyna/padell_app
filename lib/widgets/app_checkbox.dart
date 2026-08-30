import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Единственный вид чекбокса в приложении.
///
/// Квадрат 24×24 со скруглением 6: снятый — прозрачный с серой рамкой,
/// отмеченный — залит акцентным зелёным с чёрной галочкой. Раньше такой
/// чекбокс жил прямо в экране настроек уведомлений, и любой новый список
/// рисовал что-то своё. Правила — в docs/DESIGN_SYSTEM.md.
class AppCheckbox extends StatelessWidget {
  final bool checked;

  /// Размер стороны. Меняется редко — только если строка сама по себе крупнее.
  final double size;

  const AppCheckbox({super.key, required this.checked, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? AppTheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? AppTheme.accent : const Color(0xFF3A3A3A),
          width: 1.5,
        ),
      ),
      child: checked
          ? Icon(Icons.check, color: Colors.black, size: size * 0.67)
          : null,
    );
  }
}
