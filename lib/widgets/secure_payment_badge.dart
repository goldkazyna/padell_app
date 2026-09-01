import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Блок «Безопасная оплата» — иконка-щит + надпись и монохромные значки
/// VISA / Mastercard / Apple Pay. Используется на главной и на экране брони.
///
/// [showGooglePay] добавляет четвёртый значок — там, где шлюз его правда
/// принимает (оплата турнира). На главной значков намеренно три: это
/// витрина доверия, а не список способов.
class SecurePaymentBadge extends StatelessWidget {
  final bool showGooglePay;

  const SecurePaymentBadge({super.key, this.showGooglePay = false});

  static const Color _labelGrey = Color(0xFF6E6E78);
  static const Color _markGrey = Color(0xFF8C8C94);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shield_outlined, size: 13, color: _labelGrey),
            SizedBox(width: 6),
            Text(
              'БЕЗОПАСНАЯ ОПЛАТА',
              style: TextStyle(
                color: _labelGrey,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 22,
          runSpacing: 12,
          children: [
            const Text(
              'VISA',
              style: TextStyle(
                color: _markGrey,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
            // Символ Mastercard — два пересекающихся круга (монохром)
            SizedBox(
              width: 34,
              height: 22,
              child: Stack(
                children: [
                  Positioned(left: 0, top: 1, child: _circle(_markGrey)),
                  Positioned(
                      right: 0, top: 1, child: _circle(_markGrey.withAlpha(150))),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                FaIcon(FontAwesomeIcons.apple, size: 18, color: _markGrey),
                SizedBox(width: 3),
                Text(
                  'Pay',
                  style: TextStyle(
                    color: _markGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (showGooglePay) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  FaIcon(FontAwesomeIcons.google, size: 15, color: _markGrey),
                  SizedBox(width: 4),
                  Text(
                    'Pay',
                    style: TextStyle(
                      color: _markGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _circle(Color c) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
