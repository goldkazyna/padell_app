import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../utils/app_alert.dart';

/// Круглая кнопка «поделиться» 34×34 — пара к [AppBackButton] в шапке
/// вложенного экрана.
///
/// Сама открывает системный лист: текст и ссылку передаёт вызывающий. На
/// iPad лист требует якорь, иначе не открывается вовсе, — берём позицию
/// самой кнопки.
class AppShareButton extends StatelessWidget {
  /// Что уходит в мессенджер: короткая строка со ссылкой.
  final String text;

  /// Заголовок сообщения об ошибке — экранный, поэтому приходит снаружи.
  final String errorTitle;

  const AppShareButton({
    super.key,
    required this.text,
    required this.errorTitle,
  });

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      await Share.share(text, sharePositionOrigin: origin);
    } catch (e) {
      if (!context.mounted) return;
      showAppAlert(context, '$e', title: errorTitle, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _share(context),
      // Center сжимает кнопку до её размера: в actions у AppBar приходят
      // жёсткие ограничения, и без него круг растягивается.
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: AppTheme.border)),
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
