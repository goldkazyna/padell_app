import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'my_bookings_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String clubName;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.clubName,
  });

  String _fmtPrice(num p) {
    return p.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    final court = booking['court'] as String? ?? '';
    final date = booking['date'] as String? ?? '';
    final startTime = booking['start_time'] as String? ?? '';
    final endTime = booking['end_time'] as String? ?? '';
    final courtPrice = (booking['court_price'] as num?) ?? 0;
    final coachName = booking['coach_name'] as String?;
    final coachPrice = (booking['coach_price'] as num?) ?? 0;
    final totalPrice = (booking['total_price'] as num?) ?? courtPrice;

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
                  color: AppTheme.accent.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: AppTheme.accent),
              ),
              const SizedBox(height: 20),

              const Text(
                'Бронь подтверждена!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Вы успешно забронировали корт',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 28),

              // Детали
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
                ),
                child: Column(
                  children: [
                    _row('Клуб', clubName),
                    _row('Корт', court),
                    _row('Дата', date),
                    _row('Время', '$startTime — $endTime'),
                    if (coachName != null) _row('Тренер', coachName, color: const Color(0xFFA78BFA)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF2A2A2A), height: 1),
                    ),
                    _row('Корт', '${_fmtPrice(courtPrice)} ₸', color: AppTheme.accent),
                    if (coachName != null && coachPrice > 0)
                      _row('Тренер', '${_fmtPrice(coachPrice)} ₸', color: const Color(0xFFA78BFA)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF2A2A2A), height: 1),
                    ),
                    _row('Итого', '${_fmtPrice(totalPrice)} ₸',
                        color: AppTheme.accent, bold: true, big: true),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Кнопки
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Мои бронирования',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                      border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
                    ),
                    child: const Center(
                      child: Text('На главную',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
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

  Widget _row(String label, String value, {Color? color, bool bold = false, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 13,
            color: bold ? const Color(0xFFE4E4E7) : const Color(0xFF71717A),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          )),
          Text(value, style: TextStyle(
            fontSize: big ? 18 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: color ?? AppTheme.textPrimary,
          )),
        ],
      ),
    );
  }
}
