import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../secure_payment_badge.dart';

/// Блок оплаты участия в турнире.
///
/// Человек платит вперёд, поэтому блок обязан ответить на три вопроса
/// сразу: сколько, чем и что будет после оплаты. Сумма стоит в самой
/// кнопке, значки платёжных систем — те же, что на главной, а обещание
/// «сразу в списке» снимает главный страх: «заплачу и буду ждать
/// модерации».
///
/// Стоит в карточке турнира на месте бывшей кнопки оплаты по ссылке клуба
/// — сразу под ценой, до списка участников.
class TournamentPayButton extends StatelessWidget {
  final TournamentPaymentInfo payment;

  /// Оплатить за себя.
  final VoidCallback onPay;

  /// Оплатить за себя и друга. null — записывать друга нельзя.
  final VoidCallback? onPayWithFriend;

  const TournamentPayButton({
    super.key,
    required this.payment,
    required this.onPay,
    this.onPayWithFriend,
  });

  /// «14 000 ₸» — с пробелами по три цифры, без копеек.
  static String formatPrice(double amount) {
    final whole = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(whole[i]);
    }
    return '${buffer.toString()} ₸';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 18),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      l10n.payParticipation,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Сумма отделена точкой: цена — часть решения, а не
                  // сюрприз на следующем экране.
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatPrice(payment.amount),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),

          if (onPayWithFriend != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onPayWithFriend,
                icon: const Icon(Icons.group_add_outlined, size: 18),
                label: Text(
                  '${l10n.payForTwo} · ${formatPrice(payment.amount * 2)}',
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  side: const BorderSide(color: AppTheme.accent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 14, color: AppTheme.accent.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.payAfterHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Значки платёжных систем — те же, что на главной и в брони.
          SecurePaymentBadge(showGooglePay: payment.hasGooglePay),
        ],
      ),
    );
  }
}
