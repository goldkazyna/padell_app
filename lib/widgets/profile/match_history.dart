import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';

class MatchHistory extends StatelessWidget {
  const MatchHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final matches = profile.matches;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'История матчей',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (profile.isLoadingMatches && matches.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              )
            else if (matches.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF2A2A2A), width: 0.5),
                ),
                child: const Text(
                  'Пока нет матчей',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...List.generate(matches.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(bottom: i < matches.length - 1 ? 8 : 0),
                  child: _MatchCard(match: matches[i]),
                );
              }),
            if (profile.hasMoreMatches) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: profile.isLoadingMatches
                      ? null
                      : () => profile.loadMoreMatches(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Color(0xFF2A2A2A), width: 0.5),
                    ),
                  ),
                  child: profile.isLoadingMatches
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Загрузить ещё',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final isWin = match.isWin;
    final resultColor = isWin ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final dateParts = _parseDate(match.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        children: [
          // Дата
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  dateParts['day']!,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateParts['month']!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Инфо
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.tournamentName,
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
                  match.formatName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (match.partner != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          color: AppTheme.textSecondary, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.partner!.name,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Счёт и результат
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: resultColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  match.score,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isWin ? 'Победа' : 'Поражение',
                style: TextStyle(
                  color: resultColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _parseDate(String date) {
    const months = [
      '', 'ЯНВ', 'ФЕВ', 'МАР', 'АПР', 'МАЙ', 'ИЮН',
      'ИЮЛ', 'АВГ', 'СЕН', 'ОКТ', 'НОЯ', 'ДЕК',
    ];

    try {
      final parts = date.split('-');
      final month = int.parse(parts[1]);
      final day = parts[2];
      return {'day': day, 'month': months[month]};
    } catch (_) {
      return {'day': '--', 'month': '---'};
    }
  }
}
