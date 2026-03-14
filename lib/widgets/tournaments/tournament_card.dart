import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';

class TournamentCard extends StatelessWidget {
  final String day;
  final String month;
  final String time;
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
    required this.time,
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
      time: t.time,
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
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Date strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E1E1E), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Day
                Text(
                  day,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                // Month
                Text(
                  month,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                // Dot separator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A4A4A),
                    shape: BoxShape.circle,
                  ),
                ),
                // Time
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 12),
                // Tournament name
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Badge + Club row
                Row(
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Club
                    Text(
                      club,
                      style: const TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Meta + Action button row
                Row(
                  children: [
                    // Meta items
                    Expanded(
                      child: Row(
                        children: [
                          _buildMetaItem(Icons.people_outline, participants),
                          const SizedBox(width: 12),
                          _buildMetaItem(Icons.payments_outlined, price),
                          const SizedBox(width: 12),
                          _buildMetaItem(Icons.trending_up, level),
                        ],
                      ),
                    ),
                    // Action button
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (isRegistered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accent, width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: AppTheme.accent, size: 14),
            SizedBox(width: 5),
            Text(
              'Записан',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Мест нет',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Записаться',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
