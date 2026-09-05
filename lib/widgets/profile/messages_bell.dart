import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/amigo_provider.dart';
import '../../screens/messages_screen.dart';
import '../../theme/app_theme.dart';

/// Иконка личных сообщений с числом непрочитанных — в шапке профиля.
///
/// Счётчик красный, как и у колокольчика уведомлений рядом: это одна и та же
/// мысль «на тебя что-то ждёт», и разный цвет читался бы как разный смысл.
class MessagesBell extends StatefulWidget {
  const MessagesBell({super.key});

  @override
  State<MessagesBell> createState() => _MessagesBellState();
}

class _MessagesBellState extends State<MessagesBell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AmigoProvider>().loadUnread(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AmigoProvider>(
      builder: (context, provider, _) {
        final unread = provider.unread;

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessagesScreen()),
            );
            if (context.mounted) context.read<AmigoProvider>().loadUnread();
          },
          child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 17,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.background, width: 2),
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
