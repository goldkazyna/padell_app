import 'dart:ui';
import 'package:flutter/material.dart';

/// Карточка пункта меню профиля. Цвет получается подмешиванием акцента к
/// тёмной базе (Color.lerp). Диагональный градиент + гланц + стеклянный
/// чип-иконка, лёгкая реакция на нажатие.
class ProfileCard extends StatefulWidget {
  final String title;
  final String sub;
  final IconData icon;
  final Color accent;
  final int badge;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.title,
    required this.sub,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.badge = 0,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _pressed = false;

  static Color _mix(Color base, Color accent, double t) =>
      Color.lerp(base, accent, t)!;

  static const _baseTop = Color(0xFF142019);
  static const _baseBot = Color(0xFF0E1714);
  static const _baseBorder = Color(0xFF243029);

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final start = _mix(_baseTop, accent, _pressed ? 0.64 : 0.56);
    final end = _mix(_baseBot, accent, 0.20);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [start, end],
            ),
            border: Border.all(
                color: _mix(_baseBorder, accent, 0.45), width: 1),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.26),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Контент задаёт высоту карточки.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    _iconChip(start),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.sub,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(Icons.chevron_right,
                        size: 20, color: Colors.white.withValues(alpha: 0.7)),
                  ],
                ),
              ),
              // Гланц — светлый блик поверх верхних 48% карточки.
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.48,
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconChip(Color cardColor) {
    final chip = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 22),
        ),
      ),
    );

    if (widget.badge <= 0) return chip;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        chip,
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            constraints: const BoxConstraints(minWidth: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF0606A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cardColor, width: 2),
            ),
            child: Text(
              '${widget.badge}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
