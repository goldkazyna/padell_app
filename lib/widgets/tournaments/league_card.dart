import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../models/league.dart';
import '../../theme/app_theme.dart';
import 'club_logo.dart';

/// Карточка лиги в списке турниров.
///
/// Собрана по образцу карточки турнира: те же рамка, отступы, шкала и
/// подписи. Отличают её метка «ЛИГА» слева вверху и шкала этапов вместо
/// шкалы мест — иначе лигу не отличить от обычного турнира.
class LeagueCard extends StatelessWidget {
  final League league;
  final VoidCallback onTap;

  const LeagueCard({super.key, required this.league, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: league.isRegistered
                ? AppTheme.accent.withValues(alpha: 0.35)
                : AppTheme.border,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopRow(context),
            const SizedBox(height: 10),
            // Логотип клуба рядом с названием — как в шапке клуба над
            // списком турниров: без него карточка не читалась как «клубная».
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClubLogoTile(
                  url: league.clubLogo,
                  name: league.clubName ?? 'Лига',
                  size: 38,
                  radius: 9,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        league.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildMetaRow(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildClubRow(),
            const SizedBox(height: 10),
            _buildStagesRow(),
            if (league.nextStage?.startDate != null) ...[
              const SizedBox(height: 8),
              _buildNextStage(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Метка «ЛИГА», период и отметка о записи — как верхняя строка турнира.
  Widget _buildTopRow(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final start = league.startDate;
    final end = league.endDate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ЛИГА',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (start != null)
                Text(
                  end != null
                      ? '${DateFormat('d MMM', locale).format(start)} — ${DateFormat('d MMM', locale).format(end)}'
                      : 'старт ${DateFormat('d MMM', locale).format(start)}',
                  style: TextStyle(
                    color: AppTheme.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        // Своё место важнее отметки о записи: если игрок уже играл,
        // он смотрит на карточку именно ради него.
        if (league.myPlace != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              league.totalPlayers != null
                  ? '${league.myPlace} из ${league.totalPlayers}'
                  : 'место ${league.myPlace}',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else if (league.isRegistered)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 14),
              const SizedBox(width: 4),
              const Text(
                'вы в составе',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Клуб · формат этапов · цена — та же строка, что у турнира.
  /// Формат · этапы · цена — та же строка, что у карточки турнира,
  /// где стоит «Американо · 18 000 ₸».
  Widget _buildMetaRow() {
    return Row(
      children: [
        if (league.formatName != null) ...[
          Flexible(
            child: Text(
              league.formatName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                // Тот же синий, что у Americano Flex в карточке турнира.
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _dot(),
        ],
        Text(
          '${league.stagesTotal} ${_stagesWord(league.stagesTotal)}',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        if ((league.price ?? 0) > 0) ...[
          _dot(),
          Text(
            '${league.price} ₸',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }

  /// Клуб отдельной строкой с иконкой места — как «📍 ADD Padel Almaty»
  /// под названием турнира.
  Widget _buildClubRow() {
    return Row(
      children: [
        Icon(Icons.place_outlined, size: 13, color: AppTheme.textDim),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            [league.clubName, league.clubCity].whereType<String>().join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppTheme.textDim, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('·', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
      );

  /// Шкала пройденных этапов — на месте шкалы свободных мест у турнира.
  Widget _buildStagesRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) => Container(
                    width: c.maxWidth * league.progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'этап ${league.stagesDone} из ${league.stagesTotal}',
          style: TextStyle(
            color: AppTheme.textDim,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          league.myPoints != null
              ? '${league.myPoints} очков'
              : '${league.players} в составе',
          style: TextStyle(
            color: league.myPoints != null ? AppTheme.accent : AppTheme.textDim,
            fontSize: 11,
            fontWeight: league.myPoints != null ? FontWeight.w700 : FontWeight.w400,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStage(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = league.nextStage!.startDate!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, color: AppTheme.accent, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Этап ${league.nextStage!.stage} · '
              '${DateFormat('d MMMM, HH:mm', locale).format(date)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stagesWord(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'этап';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'этапа';
    return 'этапов';
  }
}
