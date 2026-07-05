import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';

/// Экран создания фиксированных пар для «Just Padel It» (is_paired).
/// Открывается из admin_tournament_detail_screen, когда турнир just_padel_it с
/// фиксированными парами и пары ещё не созданы. После успеха возвращает true.
class AdminJpiCreatePairsScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const AdminJpiCreatePairsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<AdminJpiCreatePairsScreen> createState() =>
      _AdminJpiCreatePairsScreenState();
}

class _AdminJpiCreatePairsScreenState extends State<AdminJpiCreatePairsScreen> {
  bool _loading = true;
  String? _error;
  bool _saving = false;

  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _existingPairs = [];

  int _expectedPairsCount = 0;
  bool _canCreate = false;
  bool _locked = false;

  /// _selected[i] = [player1_id, player2_id], 0 = не выбран.
  List<List<int>> _selected = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await context.read<AdminService>().getJpiPairs(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _participants =
            (data['participants'] as List? ?? []).cast<Map<String, dynamic>>();
        _existingPairs =
            (data['pairs'] as List? ?? []).cast<Map<String, dynamic>>();
        _expectedPairsCount = (data['expected_pairs_count'] as int?) ?? 0;
        _canCreate = (data['can_create'] as bool?) ?? false;
        _locked = (data['locked'] as bool?) ?? false;
        _selected = List.generate(_expectedPairsCount, (_) => <int>[0, 0]);
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

  void _autoAssign() {
    final sorted = [..._participants];
    sorted.sort((a, b) {
      final ra = (a['rating'] is num) ? (a['rating'] as num).toInt() : 0;
      final rb = (b['rating'] is num) ? (b['rating'] as num).toInt() : 0;
      return rb.compareTo(ra);
    });
    final n = sorted.length;
    for (int i = 0; i < n ~/ 2; i++) {
      final strong = sorted[i]['id'] as int;
      final weak = sorted[n - 1 - i]['id'] as int;
      _selected[i] = [strong, weak];
    }
    setState(() {});
  }

  Set<int> _takenExcept(int pairIdx, int slot) {
    final taken = <int>{};
    for (int i = 0; i < _selected.length; i++) {
      for (int s = 0; s < 2; s++) {
        if (i == pairIdx && s == slot) continue;
        final id = _selected[i][s];
        if (id != 0) taken.add(id);
      }
    }
    return taken;
  }

  Future<void> _submit() async {
    final pairs = <List<int>>[];
    for (int i = 0; i < _selected.length; i++) {
      final p1 = _selected[i][0];
      final p2 = _selected[i][1];
      if (p1 == 0 || p2 == 0) {
        await showAppAlert(
          context,
          'Пара ${i + 1}: оба игрока обязательны',
          title: 'Ошибка',
          isError: true,
        );
        return;
      }
      pairs.add([p1, p2]);
    }

    setState(() => _saving = true);
    try {
      await context
          .read<AdminService>()
          .saveJpiPairs(widget.tournamentId, pairs);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: const MainTabBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
            if (_saving)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                const Text(
                  'Создать пары',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.tournamentName,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_locked) {
      return _buildLockedView();
    }

    return _buildFormView();
  }

  Widget _buildLockedView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _infoBanner(
          'Пары уже созданы. После старта турнира их менять нельзя.',
          isWarning: false,
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _existingPairs.length; i++)
          _pairCardReadonly(i, _existingPairs[i]),
      ],
    );
  }

  Widget _buildFormView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _infoBanner(
          'Зарегистрировано ${_participants.length} игроков → нужно создать $_expectedPairsCount пар.',
          isWarning: false,
        ),
        if (!_canCreate) ...[
          const SizedBox(height: 8),
          _infoBanner(
            'Игроков должно быть минимум 8 и кратно 4.',
            isWarning: true,
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _canCreate ? _autoAssign : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accent,
              side: const BorderSide(color: AppTheme.accent),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.shuffle_rounded, size: 18),
            label: const Text('Авто (сильный + слабый)'),
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _expectedPairsCount; i++) _pairCardForm(i),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_canCreate && !_saving) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Сохранить пары',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pairCardReadonly(int idx, Map<String, dynamic> pair) {
    final p1 = pair['player1'] as Map<String, dynamic>?;
    final p2 = pair['player2'] as Map<String, dynamic>?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              'Пара ${idx + 1}',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (p1?['name'] as String?) ?? '?',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  (p2?['name'] as String?) ?? '?',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pairCardForm(int idx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Пара ${idx + 1}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _playerDropdown(idx, 0),
          const SizedBox(height: 8),
          _playerDropdown(idx, 1),
        ],
      ),
    );
  }

  Widget _playerDropdown(int pairIdx, int slot) {
    final current = _selected[pairIdx][slot];
    final taken = _takenExcept(pairIdx, slot);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: current == 0 ? null : current,
          isExpanded: true,
          dropdownColor: AppTheme.card,
          icon: const Icon(Icons.expand_more, color: AppTheme.textSecondary),
          hint: Text(
            slot == 0 ? 'Игрок 1' : 'Игрок 2',
            style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
          ),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          items: [
            for (final p in _participants)
              DropdownMenuItem<int>(
                value: p['id'] as int,
                enabled:
                    !taken.contains(p['id'] as int) || p['id'] as int == current,
                child: _playerOptionRow(p, disabled: taken.contains(p['id'])),
              ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _selected[pairIdx][slot] = v;
            });
          },
        ),
      ),
    );
  }

  Widget _playerOptionRow(Map<String, dynamic> p, {required bool disabled}) {
    final name = (p['name'] as String?) ?? '?';
    final level = p['level'];
    final rating = p['rating'];
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: disabled ? AppTheme.textDim : AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (level != null)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'L$level',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (rating != null) ...[
          const SizedBox(width: 6),
          Text(
            '$rating',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoBanner(String text, {required bool isWarning}) {
    final color = isWarning ? AppTheme.amber : AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
