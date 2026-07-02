import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;

  const ChatMessageBubble({super.key, required this.message, this.onLongPress});

  static const double _avatar = 36;
  static const double _gap = 10;

  // Насыщенная палитра для аватара-заглушки (организатор — всегда зелёный).
  static const List<Color> _palette = [
    AppTheme.blue,
    Color(0xFF7C3AED),
    AppTheme.orange,
  ];

  Color get _avatarColor => message.isAdmin
      ? AppTheme.accent
      : _palette[message.user.id.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    return message.isMine ? _buildMine() : _buildOther(context);
  }

  // ---- Своё сообщение: справа, зелёный пузырь, без аватара/имени ----
  Widget _buildMine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bubble(mine: true),
          const SizedBox(height: 4),
          _time(),
        ],
      ),
    );
  }

  // ---- Чужое сообщение: аватар слева, имя+бейдж над пузырём, время под ним ----
  Widget _buildOther(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Имя + бейдж — выровнены по левому краю пузыря (отступ на аватар).
          Padding(
            padding: const EdgeInsets.only(left: _avatar + _gap, bottom: 4),
            child: _nameRow(l10n),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatarWidget(),
              const SizedBox(width: _gap),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bubble(mine: false),
                    const SizedBox(height: 4),
                    _time(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nameRow(AppLocalizations l10n) {
    final levelLabel = message.user.levelLabel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            message.user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: message.isAdmin ? AppTheme.accent : AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (message.isAdmin)
          _badge(
            l10n.chatOrganizerBadge,
            color: AppTheme.accent,
            bg: AppTheme.accentSoft,
          )
        else if (levelLabel != null)
          _badge(
            levelLabel,
            color: AppTheme.textSecondary,
            bg: AppTheme.cardRaised,
          ),
      ],
    );
  }

  Widget _badge(String text, {required Color color, required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _avatarWidget() {
    final fallback = Container(
      width: _avatar,
      height: _avatar,
      decoration: BoxDecoration(color: _avatarColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          message.user.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    final url = message.user.avatar ?? '';
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: _avatar,
        height: _avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }

  Widget _bubble({required bool mine}) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: mine ? Colors.white : AppTheme.textPrimary,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _time() {
    return Text(
      message.timeLabel,
      style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
    );
  }
}
