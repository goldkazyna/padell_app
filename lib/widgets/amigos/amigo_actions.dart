import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/amigo_provider.dart';
import '../../screens/chat_screen.dart';
import '../../theme/app_theme.dart';

/// Две кнопки в чужом профиле: «В амигос» и «Написать».
///
/// Стоят выше статистики: действие важнее цифр, за цифрами человек листает
/// ниже. После добавления первая кнопка становится второстепенной — строка не
/// исчезает, чтобы можно было так же легко отменить.
class AmigoActions extends StatefulWidget {
  final int playerId;
  final String playerName;

  const AmigoActions({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<AmigoActions> createState() => _AmigoActionsState();
}

class _AmigoActionsState extends State<AmigoActions> {
  bool? _isAmigo;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  /// Состояние берём из уже загруженного списка: отдельной ручки «я на него
  /// подписан?» нет и заводить её ради одной кнопки не нужно.
  Future<void> _sync() async {
    final provider = context.read<AmigoProvider>();
    if (provider.amigos.isEmpty) {
      await provider.loadAmigos();
    }

    if (!mounted) return;
    setState(() {
      _isAmigo = provider.amigos.any((a) => a.id == widget.playerId);
    });
  }

  Future<void> _toggle() async {
    if (_busy) return;
    // Отклик до запроса: сервер отвечает не сразу, и без крутилки человек
    // жмёт кнопку второй раз.
    setState(() => _busy = true);

    final provider = context.read<AmigoProvider>();
    final ok = _isAmigo == true
        ? await provider.unfollow(widget.playerId)
        : await provider.follow(widget.playerId);

    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _isAmigo = !(_isAmigo ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final added = _isAmigo == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _Button(
              label: added ? l10n.amigosAdded : l10n.amigosAdd,
              filled: !added,
              busy: _busy,
              onTap: _toggle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Button(
              label: l10n.messageWrite,
              filled: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    playerId: widget.playerId,
                    playerName: widget.playerName,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String label;
  final bool filled;
  final bool busy;
  final VoidCallback? onTap;

  const _Button({
    required this.label,
    required this.filled,
    this.busy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: const Color(0xFF2A3330)),
        ),
        child: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  // На прозрачной кнопке чёрная крутилка не видна.
                  color: filled ? Colors.black : AppTheme.textSecondary,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.black : AppTheme.textSecondary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
