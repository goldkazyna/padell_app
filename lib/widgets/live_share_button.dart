import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_share_button.dart';

/// Кнопка «поделиться трансляцией» в шапке live-экранов.
///
/// Шлёт ссылку на лендинг `/live/{id}` — он открывает тот же live-экран
/// в приложении у того, кто перешёл, а без приложения уводит в магазин.
/// Сам круг — общий [AppShareButton]: рядом с ним такая же кнопка у лиги.
class LiveShareButton extends StatelessWidget {
  final int tournamentId;
  final String tournamentName;

  const LiveShareButton({
    super.key,
    required this.tournamentId,
    this.tournamentName = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = tournamentName.isEmpty ? '' : '\u00ab$tournamentName\u00bb\n';

    return AppShareButton(
      text: '${l10n.liveShareText}\n$title'
          'https://padel-p.kz/live/$tournamentId',
      errorTitle: l10n.shareFailed,
    );
  }
}
