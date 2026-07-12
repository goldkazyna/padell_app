import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'my_bookings_screen.dart';

/// Экран после закрытия онлайн-оплаты без оплаты.
/// Показываем явно, что оплата не прошла и бронь осталась неоплаченной.
class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Иконка
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    size: 44, color: AppTheme.error),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.paymentNotCompletedTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.paymentNotCompleted,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
              ),

              const Spacer(flex: 3),

              // Кнопка «Мои брони»
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(l10n.myBookings,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Кнопка «На главную»
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
                    ),
                    child: Center(
                      child: Text(l10n.goHome,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
