import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';

class TournamentCard extends StatelessWidget {
  final String day;
  final String month;
  final String name;
  final String type;
  final Color typeColor;
  final String club;
  final String participants;
  final String price;
  final String level;
  final bool isRegistered;
  final bool isFull;

  const TournamentCard({
    super.key,
    required this.day,
    required this.month,
    required this.name,
    required this.type,
    required this.typeColor,
    required this.club,
    required this.participants,
    required this.price,
    required this.level,
    this.isRegistered = false,
    this.isFull = false,
  });

  factory TournamentCard.fromTournament(Tournament t) {
    return TournamentCard(
      day: t.dayOfMonth,
      month: t.monthShort,
      name: t.name,
      type: t.typeName,
      typeColor: t.typeColor,
      club: t.club.name,
      participants: t.participantsText,
      price: t.priceText,
      level: t.levelText,
      isRegistered: t.isRegistered,
      isFull: t.isFull,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Дата
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Контент
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название и тип
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Тип бейдж
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Клуб
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      club,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Инфо строка
                Row(
                  children: [
                    _buildInfoChip(Icons.people_outline, participants),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.payments_outlined, price),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.trending_up, level),
                  ],
                ),
                const SizedBox(height: 12),

                // Кнопка
                _buildActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (isRegistered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.accent.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppTheme.accent, size: 16),
            SizedBox(width: 6),
            Text(
              'Вы записаны',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.error.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Мест нет',
          style: TextStyle(
            color: AppTheme.error,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Записаться',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}