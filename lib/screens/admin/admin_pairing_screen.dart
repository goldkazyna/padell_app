import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';

/// Ручной сбор пар для группового турнира (pairing_mode=admin).
/// Игроки записаны поодиночке — админ собирает пары, затем стартует турнир.
class AdminPairingScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const AdminPairingScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<AdminPairingScreen> createState() => _AdminPairingScreenState();
}

class _AdminPairingScreenState extends State<AdminPairingScreen> {
  Map<String, dynamic>? _pairing;
  int? _selectedPlayerId;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data =
          await context.read<AdminService>().getPairing(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _pairing = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _run(Future<Map<String, dynamic>> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final data = await action();
      if (!mounted) return;
      setState(() {
        _pairing = data;
        _selectedPlayerId = null;
      });
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onPlayerTap(int playerId) {
    if (_busy) return;
    if (_selectedPlayerId == null) {
      setState(() => _selectedPlayerId = playerId);
    } else if (_selectedPlayerId == playerId) {
      setState(() => _selectedPlayerId = null);
    } else {
      final first = _selectedPlayerId!;
      _run(() => context
          .read<AdminService>()
          .createPair(widget.tournamentId, first, playerId));
    }
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<AdminService>().startTournament(widget.tournamentId);
      if (!mounted) return;
      await showAppAlert(context, 'Турнир запущен');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pairing;
    final unpaired = (p?['unpaired'] as List?) ?? const [];
    final teams = (p?['teams'] as List?) ?? const [];
    final maxPairs = (p?['max_pairs'] as num?)?.toInt() ?? 0;
    final pairsCount = (p?['pairs_count'] as num?)?.toInt() ?? 0;
    final canStart = p?['can_start'] == true;
    final rosterReady = p?['roster_ready'] == true;
    final approvedCount = (p?['approved_count'] as num?)?.toInt() ?? 0;
    final maxParticipants = (p?['max_participants'] as num?)?.toInt() ?? 0;
    final pendingCount = (p?['pending_count'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _progress(pairsCount, maxPairs),
                    const SizedBox(height: 12),
                    if (!rosterReady)
                      _rosterBanner(approvedCount, maxParticipants, pendingCount),
                    if (rosterReady && unpaired.length >= 2) ...[
                      _autoButton(),
                      const SizedBox(height: 16),
                    ],
                    if (rosterReady && unpaired.isNotEmpty) ...[
                      _sectionLabel('Без пары · ${unpaired.length}'),
                      const SizedBox(height: 4),
                      if (_selectedPlayerId != null)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Выберите второго игрока для пары',
                            style: TextStyle(
                                color: AppTheme.accent, fontSize: 12),
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final pl in unpaired) _playerChip(pl),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    _sectionLabel('Пары · $pairsCount'),
                    const SizedBox(height: 8),
                    if (teams.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Пар пока нет',
                            style: TextStyle(
                                color: AppTheme.textDim, fontSize: 13)),
                      )
                    else
                      for (final t in teams) _pairCard(t),
                  ],
                ),
              ),
            _bottomBar(canStart),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Сбор пар',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text(widget.tournamentName,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(int pairs, int max) {
    final ratio = max > 0 ? (pairs / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Собрано $pairs из $max пар',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppTheme.cardRaised,
            valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
          ),
        ),
      ],
    );
  }

  Widget _rosterBanner(int approved, int max, int pending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Сбор пар откроется при полном составе',
              style: TextStyle(
                  color: AppTheme.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Подтверждено $approved из $max'
            '${pending > 0 ? ' · $pending на модерации' : ''}.\n'
            'Сначала подтвердите всех участников, затем собирайте пары.',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _autoButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy
            ? null
            : () => _run(() =>
                context.read<AdminService>().autoPair(widget.tournamentId)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accent,
          side: const BorderSide(color: AppTheme.accent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.shuffle_rounded, size: 18),
        label: const Text('Случайные пары (баланс по рейтингу)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3));

  Widget _playerChip(dynamic pl) {
    final id = (pl['id'] as num).toInt();
    final name = pl['name'] as String? ?? '—';
    final rating = (pl['rating'] as num?)?.toInt() ?? 0;
    final selected = _selectedPlayerId == id;
    return GestureDetector(
      onTap: () => _onPlayerTap(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                style: TextStyle(
                    color:
                        selected ? AppTheme.accent : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text('$rating',
                style: TextStyle(
                    color: AppTheme.textDim, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _pairCard(dynamic t) {
    final id = (t['id'] as num).toInt();
    final p1 = t['player1'] as Map<String, dynamic>?;
    final p2 = t['player2'] as Map<String, dynamic>?;
    final avg = (t['rating_avg'] as num?)?.toInt() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p1?['name'] ?? '—'}  +  ${p2?['name'] ?? '—'}',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text('Средний рейтинг: $avg',
                    style: TextStyle(
                        color: AppTheme.textDim, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: _busy
                ? null
                : () => _run(() => context
                    .read<AdminService>()
                    .deletePair(widget.tournamentId, id)),
            icon: Icon(Icons.close_rounded,
                color: AppTheme.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(bool canStart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: (canStart && !_busy) ? _start : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            canStart ? 'Начать турнир' : 'Соберите все пары',
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
