import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';

class UpcomingList extends StatelessWidget {
  final List<Tournament> tournaments;
  final Function(Tournament)? onTap;

  const UpcomingList({
    super.key,
    required this.tournaments,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: tournaments.asMap().entries.map((entry) {
        final index = entry.key;
        final t = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < tournaments.length - 1 ? 8 : 0),
          child: _buildItem(t),
        );
      }).toList(),
    );
  }

  Widget _buildItem(Tournament t) {
    return GestureDetector(
      onTap: () => onTap?.call(t),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    t.dayOfMonth,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    t.monthShort,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.club.name} · ${t.time}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              t.participantsText,
              style: TextStyle(
                color: t.isFull ? AppTheme.error : AppTheme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: const Center(
        child: Text(
          'Нет предстоящих турниров',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
