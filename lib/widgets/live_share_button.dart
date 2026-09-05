import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../l10n/app_localizations.dart';

/// Кнопка «поделиться трансляцией» в шапке live-экранов.
///
/// Шлёт ссылку на лендинг `/live/{id}` — он открывает тот же live-экран
/// в приложении у того, кто перешёл, а без приложения уводит в магазин.
/// Круг 34×34 — как [AppBackButton], они стоят в одной строке.
class LiveShareButton extends StatelessWidget {
  final int tournamentId;
  final String tournamentName;

  const LiveShareButton({
    super.key,
    required this.tournamentId,
    this.tournamentName = '',
  });

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final url = 'https://padel-p.kz/live/$tournamentId';
    final title = tournamentName.isEmpty ? '' : '«$tournamentName»\n';
    final text = '${l10n.liveShareText}\n$title$url';

    // iOS/iPad share-sheet требует якорь — без него на планшете не открывается.
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      await Share.share(text, sharePositionOrigin: origin);
    } catch (e) {
      if (!context.mounted) return;
      showAppAlert(
        context,
        '$e',
        title: l10n.shareFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _share(context),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: AppTheme.border),
            ),
          ),
          child: Icon(
            Icons.ios_share,
            size: 17,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
