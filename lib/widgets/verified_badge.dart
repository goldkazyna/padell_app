import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'level_verification_sheet.dart';

Future<void> _openVerificationSheet(
  BuildContext context,
  int userId,
  String playerName,
) {
  return LevelVerificationSheet.show(
    context,
    userId: userId,
    playerName: playerName,
  );
}

/// Бейдж «Верифицирован» — компактная галочка. Показывать только
/// когда verified == true.
///
/// Если переданы [userId] и [playerName] — бейдж становится кликабельным:
/// тап открывает модалку с деталями верификации (кто/когда/уровень).
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool withTooltip;
  final int? userId;
  final String? playerName;

  const VerifiedBadge({
    super.key,
    this.size = 14,
    this.withTooltip = true,
    this.userId,
    this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size + 2,
      height: size + 2,
      decoration: const BoxDecoration(
        color: AppTheme.blue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check, color: Colors.white, size: size * 0.7),
    );

    Widget result = badge;
    if (withTooltip) {
      result = Tooltip(
        message: 'Тапни, чтобы посмотреть кто верифицировал',
        child: badge,
      );
    }

    if (userId != null && (playerName ?? '').isNotEmpty) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openSheet(context),
        child: result,
      );
    }

    return result;
  }

  Future<void> _openSheet(BuildContext context) async {
    // Лениво импортируем, чтобы избежать циклической зависимости.
    await _openVerificationSheet(context, userId!, playerName!);
  }
}

/// Статус верификации для inline-использования:
/// verified → маленький бейдж с галкой,
/// не verified → amber-текст «Не верифицирован».
class LevelVerificationStatus extends StatelessWidget {
  final bool verified;
  final double badgeSize;
  final double fontSize;

  const LevelVerificationStatus({
    super.key,
    required this.verified,
    this.badgeSize = 13,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return VerifiedBadge(size: badgeSize);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: badgeSize, color: AppTheme.amber),
        const SizedBox(width: 3),
        Text(
          'Не верифицирован',
          style: TextStyle(
            color: AppTheme.amber,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
