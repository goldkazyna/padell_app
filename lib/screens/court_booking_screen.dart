import 'package:flutter/material.dart';
import '../models/club.dart';
import '../theme/app_theme.dart';

class CourtBookingScreen extends StatelessWidget {
  final Club club;
  final int courtId;
  final String courtName;
  final String date;
  final String startTime;
  final double price;
  final List<dynamic> coaches;
  final List<dynamic> slots;
  final int slotIndex;

  const CourtBookingScreen({
    super.key,
    required this.club,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.price,
    required this.coaches,
    required this.slots,
    required this.slotIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Бронирование',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: const Center(
        child: Text(
          'Форма бронирования — следующий шаг',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
