import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_participant.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';

/// Запись парой: организатор заводит сразу двоих.
///
/// Куда ляжет пара — в пары формата или в команды турнира — решает сервер.
/// Экрану достаточно знать, что пара есть и кто остался без пары.
class AdminPairRegistrationScreen extends StatefulWidget {
  const AdminPairRegistrationScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  final int tournamentId;
  final String tournamentName;

  @override
  State<AdminPairRegistrationScreen> createState() =>
      _AdminPairRegistrationScreenState();
}

class _AdminPairRegistrationScreenState
    extends State<AdminPairRegistrationScreen> {
  List<dynamic> _pairs = const [];
  List<dynamic> _unpaired = const [];
  AdminParticipant? _player1;
  AdminParticipant? _player2;
  bool _loading = true;
  bool _busy = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AdminService>().pairsState(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _pairs = (data['pairs'] as List?) ?? const [];
        _unpaired = (data['unpaired'] as List?) ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  void _apply(Map<String, dynamic> data) {
    setState(() {
      _pairs = (data['pairs'] as List?) ?? const [];
      _unpaired = (data['unpaired'] as List?) ?? const [];
      _player1 = null;
      _player2 = null;
      _busy = false;
      _changed = true;
    });
  }

  Future<void> _addPair() async {
    final p1 = _player1;
    final p2 = _player2;
    if (p1 == null || p2 == null || _busy) return;

    setState(() => _busy = true);
    try {
      _apply(await context
          .read<AdminService>()
          .addPair(widget.tournamentId, p1.id, p2.id));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      await showAppAlert(context, '$e', title: 'Не получилось', isError: true);
    }
  }

  Future<void> _removePair(int pairId) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      _apply(await context
          .read<AdminService>()
          .removePair(widget.tournamentId, pairId));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      await showAppAlert(context, '$e', title: 'Не получилось', isError: true);
    }
  }

  Future<void> _pick(bool first) async {
    final chosen = await showModalBottomSheet<AdminParticipant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlayerPicker(tournamentId: widget.tournamentId),
    );
    if (chosen == null) return;
    setState(() {
      if (first) {
        _player1 = chosen;
      } else {
        _player2 = chosen;
      }
    });
  }

  bool get _canAdd =>
      !_busy && _player1 != null && _player2 != null && _player1!.id != _player2!.id;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Center(child: AppBackButton()),
          ),
          title: const Text('Пары',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Text(
                    widget.tournamentName,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  _addBlock(),
                  if (_pairs.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _label('Пары · ${_pairs.length}'),
                    const SizedBox(height: 10),
                    ..._pairs.map(_pairRow),
                  ],
                  if (_unpaired.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _label('Без пары · ${_unpaired.length}'),
                    const SizedBox(height: 10),
                    ..._unpaired.map(_unpairedRow),
                    const SizedBox(height: 10),
                    Text(
                      'Пока эти игроки не в парах, турнир не стартует: '
                      'по кортам раскладываются пары.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.textDim),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: .9,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDim,
        ),
      );

  Widget _addBlock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _slot('Игрок 1', _player1, () => _pick(true)),
          const SizedBox(height: 10),
          _slot('Игрок 2', _player2, () => _pick(false)),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _canAdd ? _addPair : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                disabledBackgroundColor: AppTheme.cardRaised,
                foregroundColor: const Color(0xFF08130C),
                disabledForegroundColor: AppTheme.textDim,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF08130C)))
                  : const Text('Добавить пару',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(String label, AdminParticipant? player, VoidCallback onTap) {
    return InkWell(
      onTap: _busy ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                player?.name ?? label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: player == null ? FontWeight.w500 : FontWeight.w700,
                  color:
                      player == null ? AppTheme.textDim : AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.search, size: 20, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }

  Widget _pairRow(dynamic pair) {
    final p = pair as Map<String, dynamic>;
    final name1 = (p['player1'] as Map?)?['name'] ?? '—';
    final name2 = (p['player2'] as Map?)?['name'] ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$name1 / $name2',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
          ),
          IconButton(
            onPressed: _busy ? null : () => _confirmRemove(p),
            icon: Icon(Icons.close, size: 20, color: AppTheme.error),
            tooltip: 'Разбить пару',
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(Map<String, dynamic> pair) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Разбить пару',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        content: Text(
          'Игроки останутся в списке участников — их можно собрать заново '
          'с кем-то другим.',
          style: TextStyle(
              color: AppTheme.textPrimary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Разбить',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) await _removePair(pair['id'] as int);
  }

  Widget _unpairedRow(dynamic player) {
    final p = player as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.amber.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 18, color: AppTheme.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              (p['name'] as String?) ?? '—',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Поиск игрока для пары. Ищет и среди уже записанных: их как раз и надо
/// с кем-то спарить.
class _PlayerPicker extends StatefulWidget {
  const _PlayerPicker({required this.tournamentId});

  final int tournamentId;

  @override
  State<_PlayerPicker> createState() => _PlayerPickerState();
}

class _PlayerPickerState extends State<_PlayerPicker> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<AdminParticipant> _results = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final found = await context
          .read<AdminService>()
          .searchPlayers(widget.tournamentId, query, forPair: true);
      if (!mounted) return;
      setState(() {
        _results = found;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Телефон или имя игрока',
                hintStyle: TextStyle(color: AppTheme.textDim),
                filled: true,
                fillColor: AppTheme.card,
                prefixIcon: Icon(Icons.search, color: AppTheme.textDim),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_searching)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .45,
                ),
                child: _results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          _controller.text.trim().length < 2
                              ? 'Введите хотя бы два символа'
                              : 'Никого не нашлось',
                          style: TextStyle(color: AppTheme.textDim),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final player = _results[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(player.name,
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            subtitle: player.phone == null
                                ? null
                                : Text(player.phone!,
                                    style: TextStyle(color: AppTheme.textDim)),
                            trailing: player.rating == null
                                ? null
                                : Text('${player.rating}',
                                    style: TextStyle(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w700)),
                            onTap: () => Navigator.of(context).pop(player),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
