import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Локализованное название типа турнира по slug-у с бэкенда.
String localizeTournamentType(BuildContext context, String type, {String? fallback}) {
  final l = AppLocalizations.of(context)!;
  switch (type) {
    case 'americano':
      return l.tournamentTypeAmericano;
    case 'mexicano':
      return l.tournamentTypeMexicano;
    case 'king_of_court':
      return l.tournamentTypeKingOfCourt;
    case 'bali_koc':
      return l.tournamentTypeBaliKoc;
    case 'team':
      return l.tournamentTypeTeam;
    case 'classic':
      return l.tournamentTypeClassic;
    default:
      return fallback ?? type;
  }
}
