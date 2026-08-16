import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';
import 'medal_art.dart';

/// Медаль: чеканный диск с гравировкой.
///
/// Полученная — металл с переливом и светом сверху-слева. Незакрытая — тёмный
/// диск, которому прогресс дорисовывает ободок по кругу: видно, сколько
/// осталось до того, как медаль «отольётся».
class Medal extends StatelessWidget {
  const Medal({super.key, required this.achievement, this.size = 64});

  final Achievement achievement;
  final double size;

  @override
  Widget build(BuildContext context) {
    return achievement.isUnlocked ? _struck() : _blank();
  }

  /// Отчеканенная медаль.
  Widget _struck() {
    final metal = MedalMetal.of(achievement.tier);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          startAngle: math.pi * 1.15,
          endAngle: math.pi * 3.15,
          colors: [
            metal.base, metal.light, metal.dark,
            metal.shine, metal.dark, metal.light,
          ],
          stops: const [0, .21, .43, .61, .79, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: size * .22,
            offset: Offset(0, size * .08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Блик: свет падает сверху-слева, как на настоящем металле.
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-.35, -.5),
                radius: .95,
                colors: [Color(0x59FFFFFF), Color(0x00FFFFFF)],
                stops: [0, .5],
              ),
            ),
          ),
          // Кант по краю — грань чеканки.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withAlpha(52),
                width: size * .047,
              ),
            ),
          ),
          _engraving(metal.ink),
        ],
      ),
    );
  }

  /// Незакрытая: тёмный диск и ободок прогресса.
  Widget _blank() {
    const ringGap = 7.0;

    return SizedBox(
      width: size + ringGap,
      height: size + ringGap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size + ringGap, size + ringGap),
            painter: _ProgressRing(achievement.progressRatio),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardRaised,
              border: Border.all(color: Colors.white.withAlpha(13)),
            ),
            child: Center(child: _engraving(AppTheme.textDim.withAlpha(115))),
          ),
        ],
      ),
    );
  }

  /// Гравировка: рисунок или выбитое число.
  Widget _engraving(Color ink) {
    final number = medalNumbers[achievement.code];
    if (number != null) {
      return Text(
        number,
        style: TextStyle(
          color: ink,
          fontSize: size * .40,
          fontWeight: FontWeight.w900,
          letterSpacing: -size * .012,
          height: 1,
        ),
      );
    }

    final path = medalEngravings[achievement.code];
    if (path == null) {
      return Icon(Icons.emoji_events, size: size * .42, color: ink);
    }

    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path fill-rule="evenodd" clip-rule="evenodd" d="$path"/></svg>',
      width: size * .52,
      height: size * .52,
      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
    );
  }
}

/// Ободок, который прогресс дорисовывает медали по часовой стрелке.
class _ProgressRing extends CustomPainter {
  _ProgressRing(this.ratio);

  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - 1.5;
    final stroke = 3.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withAlpha(18),
    );

    if (ratio <= 0) return;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.amber,
    );
  }

  @override
  bool shouldRepaint(_ProgressRing old) => old.ratio != ratio;
}
