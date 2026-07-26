import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/tournament_ai_analysis_screen.dart';
import '../theme/app_theme.dart';

/// Кнопка «Разбор AI» — акцентная (в палитре), открывает экран AI-разбора
/// выступления в турнире. Показывать только для завершённых рейтинговых турниров.
class TournamentAiButton extends StatelessWidget {
  final int tournamentId;
  final String tournamentName;
  final int? playerId;

  /// Компактный режим — только иконка (для тесных шапок).
  final bool compact;

  const TournamentAiButton({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    this.playerId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Кнопку показываем ТОЛЬКО в своём контексте. Если открыт турнир другого
    // игрока (highlight = чужой id, напр. Рейтинг → игрок → его турнир) — прячем.
    final myId = context.read<HomeProvider>().user?.id;
    if (playerId != null && playerId != myId) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TournamentAiAnalysisScreen(
              tournamentId: tournamentId,
              tournamentName: tournamentName,
              // Разбор всегда от лица текущего пользователя, а не выделенного
              // (highlight) игрока — иначе в чужом контексте разбирало «за него».
              playerId: null,
            ),
          ),
        );
      },
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
        width: compact ? 40 : null,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                l10n.aiAnalysisButton,
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
