import 'package:flutter/material.dart';

/// Лёгкий pressable-фидбек: opacity 1.0 → 0.85 при нажатии.
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Opacity(
        opacity: _pressed ? 0.85 : 1.0,
        child: widget.child,
      ),
    );
  }
}
