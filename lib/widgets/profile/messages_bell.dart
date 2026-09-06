import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/amigo_provider.dart';
import '../../screens/messages_screen.dart';
import '../chat_icon_button.dart';

/// Личные сообщения в шапке профиля.
///
/// Кнопка та же, что ведёт в чат турнира (`ChatIconButton`): человек уже
/// знает этот кружок с пузырём и не гадает, куда он ведёт.
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
        return ChatIconButton(
          unread: provider.unread,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessagesScreen()),
            );
            if (context.mounted) context.read<AmigoProvider>().loadUnread();
          },
        );
      },
    );
  }
}
