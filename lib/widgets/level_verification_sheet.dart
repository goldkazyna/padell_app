import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/rating_service.dart';
import '../theme/app_theme.dart';

/// Модалка «Кто и когда верифицировал уровень игрока».
/// Открывать через [LevelVerificationSheet.show].
class LevelVerificationSheet extends StatefulWidget {
  final int userId;
  final String playerName;

  const LevelVerificationSheet({
    super.key,
    required this.userId,
    required this.playerName,
  });

  /// Удобный хелпер: сам открывает bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int userId,
    required String playerName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LevelVerificationSheet(
        userId: userId,
        playerName: playerName,
      ),
    );
  }

  @override
  State<LevelVerificationSheet> createState() => _LevelVerificationSheetState();
}

class _LevelVerificationSheetState extends State<LevelVerificationSheet> {
  bool _loading = true;
  VerificationInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await context
          .read<RatingService>()
          .getVerification(widget.userId);
      if (!mounted) return;
      setState(() {
        _info = v;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.cardRaised,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Icon(Icons.verified_outlined,
                      color: AppTheme.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Верификация уровня',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.playerName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildBody(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Не удалось загрузить: $_error',
          style: const TextStyle(color: AppTheme.error, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }
    final info = _info;

    // Случай 1: уровень не верифицирован вообще.
    if (info == null || !info.verified) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.amber, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Уровень этого игрока ещё не подтверждался клубом.',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    // Случай 2: верифицирован, но истории нет (старые игроки до того,
    // как мы стали писать).
    if (info.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.blue.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_outlined,
                color: AppTheme.blue, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Уровень подтверждён клубом.',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    // Случай 3: верифицирован + есть история. Показываем все записи.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (info.history.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Записей в истории: ${info.history.length}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        for (int i = 0; i < info.history.length; i++) ...[
          _buildHistoryCard(
            info.history[i],
            isLatest: i == 0,
          ),
          if (i < info.history.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildHistoryCard(LevelVerification v, {required bool isLatest}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? AppTheme.blue.withOpacity(0.4)
              : AppTheme.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLatest)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'ПОСЛЕДНЕЕ ПОДТВЕРЖДЕНИЕ',
                style: TextStyle(
                  color: AppTheme.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          if (v.levelSetTo != null)
            _row('Установленный уровень', _fmtLevel(v.levelSetTo!)),
          if (v.verifiedByName.isNotEmpty)
            _row('Кто подтвердил', v.verifiedByName),
          if ((v.clubName ?? '').isNotEmpty) _row('Клуб', v.clubName!),
          if (v.verifiedAt != null) _row('Когда', _fmtDate(v.verifiedAt!)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtLevel(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('00') ? v.toInt().toString() : s;
  }

  String _fmtDate(DateTime d) {
    final local = d.toLocal();
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hh:$mi';
  }
}
