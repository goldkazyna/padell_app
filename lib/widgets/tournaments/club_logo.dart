import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Квадратный логотип клуба с закруглениями.
/// Если есть URL — подгружаем картинку, иначе инициалы на цветовом фоне.
class ClubLogoTile extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  final double radius;

  const ClubLogoTile({
    super.key,
    required this.url,
    required this.name,
    this.size = 36,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) {
    final widget = SizedBox(
      width: size,
      height: size,
      child: url != null && url!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );
    return widget;
  }

  Widget _buildInitials() {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase());
    final bg = _colorForName(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _colorForName(String n) {
    final colors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF5B21B6),
      const Color(0xFF9A3412),
      const Color(0xFF065F46),
      const Color(0xFF831843),
    ];
    return colors[n.hashCode.abs() % colors.length];
  }
}
