import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Круглая кнопка чата с числом непрочитанных.
///
/// Один вид на всё приложение: в шапке турнира и в шапке профиля. Раньше это
/// были две разные кнопки — 40 и 34 пикселя, разные иконки и бейджи, — и
/// люди не узнавали в профиле ту же кнопку, по которой заходят в чат турнира.
class ChatIconButton extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;

  const ChatIconButton({
    super.key,
    required this.onTap,
    this.unread = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            child: Icon(
              CupertinoIcons.chat_bubble,
              color: AppTheme.textPrimary,
              size: 22,
            ),
          ),
          if (unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                  // Тёмное кольцо-отбивка от кнопки (как на макете).
                  border: Border.all(color: AppTheme.background, width: 2),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
