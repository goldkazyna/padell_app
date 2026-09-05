import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/amigo.dart';
import '../../theme/app_theme.dart';

/// Пузырь сообщения в личной переписке.
///
/// Свои — акцент 14% справа, чужие — [AppTheme.cardRaised] слева. Сплошной
/// зелёной заливкой свои красить нельзя: чёрный текст на зелёном в приложении
/// означает кнопку, и пузырь читался бы как нажимаемый.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  /// Долгий тап по своему сообщению — удалить.
  final VoidCallback? onLongPress;

  const ChatBubble({super.key, required this.message, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final time = message.createdAt == null
        ? ''
        : DateFormat('HH:mm').format(message.createdAt!.toLocal());

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: mine ? onLongPress : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
          decoration: BoxDecoration(
            color: mine
                ? AppTheme.accent.withValues(alpha: 0.14)
                : AppTheme.cardRaised,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(mine ? 14 : 5),
              bottomRight: Radius.circular(mine ? 5 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: TextStyle(color: AppTheme.textDim, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Разделитель дня по центру переписки.
class ChatDaySeparator extends StatelessWidget {
  final String label;

  const ChatDaySeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
      ),
    );
  }
}
