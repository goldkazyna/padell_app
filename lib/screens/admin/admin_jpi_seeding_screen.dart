import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';

/// Экран ручного посева solo Just Padel It (без фиксированных пар).
/// Открывается из admin_tournament_detail_screen при старте JPI-турнира без
/// зарегистрированных пар: бэкенд возвращает участников (авто-посев по
/// рейтингу) + число кортов. Организатор может перетасовать игроков по
/// слотам (свап при выборе — как на вебе), затем стартует турнир с этим
/// порядком. После успеха возвращает true.
class AdminJpiSeedingScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const AdminJpiSeedingScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<AdminJpiSeedingScreen> createState() => _AdminJpiSeedingScreenState();
}

class _AdminJpiSeedingScreenState extends State<AdminJpiSeedingScreen> {
  bool _loading = true;
  String? _error;
  bool _saving = false;

  List<Map<String, dynamic>> _participants = [];
  int _courtsCount = 0;

  /// _slots[courtIdx][slotIdx] = player_id, 0 = не выбран.
  List<List<int>> _slots = [];

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
      final data = await context
          .read<AdminService>()
          .getJpiSeeding(widget.tournamentId);
      if (!mounted) return;
      final participants =
          (data['participants'] as List? ?? []).cast<Map<String, dynamic>>();
      final courtsCount = (data['courts_count'] as num?)?.toInt() ?? 0;

      final slots = List.generate(courtsCount, (_) => <int>[0, 0, 0, 0]);
      for (int i = 0; i < participants.length && i < courtsCount * 4; i++) {
        slots[i ~/ 4][i % 4] = participants[i]['id'] as int;
      }

      setState(() {
        _participants = participants;
        _courtsCount = courtsCount;
        _slots = slots;
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

  /// Выбрать игрока в слот. Если он уже стоит в другом слоте — меняем их
  /// местами (как веб seed-select), иначе просто занимаем пустой слот.
  void _selectPlayer(int courtIdx, int slotIdx, int playerId) {
    setState(() {
      int? foundCourt;
      int? foundSlot;
      outer:
      for (int c = 0; c < _slots.length; c++) {
        for (int s = 0; s < _slots[c].length; s++) {
          if (c == courtIdx && s == slotIdx) continue;
          if (_slots[c][s] == playerId) {
            foundCourt = c;
            foundSlot = s;
            break outer;
          }
        }
      }
      final old = _slots[courtIdx][slotIdx];
      _slots[courtIdx][slotIdx] = playerId;
      if (foundCourt != null && foundSlot != null) {
        _slots[foundCourt][foundSlot] = old;
      }
    });
  }

  Future<void> _submit() async {
    final order = <int>[];
    for (int c = 0; c < _slots.length; c++) {
      for (int s = 0; s < _slots[c].length; s++) {
        final id = _slots[c][s];
        if (id == 0) {
          await showAppAlert(
            context,
            'Корт ${c + 1}: все 4 слота обязательны',
            title: 'Ошибка',
            isError: true,
          );
          return;
        }
        order.add(id);
      }
    }

    setState(() => _saving = true);
    try {
      await context
          .read<AdminService>()
          .startTournamentWithOrder(widget.tournamentId, order);
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
                if (!_loading && _error == null) _buildBottomButton(),
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
                  'Посев участников',
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

    return _buildFormView();
  }

  Widget _buildFormView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _infoBanner(
          'Зарегистрировано ${_participants.length} игроков → $_courtsCount ${_courtsWord(_courtsCount)}. '
          'Порядок предзаполнен по рейтингу — при необходимости поменяйте игроков местами.',
        ),
        const SizedBox(height: 12),
        for (int c = 0; c < _courtsCount; c++) _courtCard(c),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Начать турнир',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  String _courtsWord(int n) {
    final mod100 = n % 100;
    final mod10 = n % 10;
    if (mod100 >= 11 && mod100 <= 14) return 'кортов';
    if (mod10 == 1) return 'корт';
    if (mod10 >= 2 && mod10 <= 4) return 'корта';
    return 'кортов';
  }

  Widget _courtCard(int courtIdx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  'Корт ${courtIdx + 1}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // В 1-м раунде корт играется как слоты 0+2 против 1+3 — так делит
          // движок. Показываем это визуально как две пары, чтобы посев был
          // понятен. Индексы слотов и порядок отправки не меняем.
          _pairBlock(courtIdx, 'Пара 1', 0, 2),
          const SizedBox(height: 8),
          _vsDivider(),
          const SizedBox(height: 8),
          _pairBlock(courtIdx, 'Пара 2', 1, 3),
        ],
      ),
    );
  }

  Widget _pairBlock(int courtIdx, String label, int slotA, int slotB) {
    final sum =
        _ratingOf(_slots[courtIdx][slotA]) + _ratingOf(_slots[courtIdx][slotB]);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Рейтинг пары: $sum',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _playerDropdown(courtIdx, slotA),
          const SizedBox(height: 8),
          _playerDropdown(courtIdx, slotB),
        ],
      ),
    );
  }

  Widget _vsDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppTheme.border, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'против',
            style: TextStyle(color: AppTheme.textDim, fontSize: 11),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.border, height: 1)),
      ],
    );
  }

  /// Рейтинг игрока по id (0 — слот пуст).
  int _ratingOf(int playerId) {
    if (playerId == 0) return 0;
    for (final p in _participants) {
      if (p['id'] == playerId) {
        final r = p['rating'];
        if (r is num) return r.toInt();
        return int.tryParse('$r') ?? 0;
      }
    }
    return 0;
  }

  Widget _playerDropdown(int courtIdx, int slot) {
    final current = _slots[courtIdx][slot];
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
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
            'Игрок ${slot + 1}',
            style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
          ),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          items: [
            for (final p in _participants)
              DropdownMenuItem<int>(
                value: p['id'] as int,
                child: _playerOptionRow(p),
              ),
          ],
          onChanged: (v) {
            if (v == null) return;
            _selectPlayer(courtIdx, slot, v);
          },
        ),
      ),
    );
  }

  Widget _playerOptionRow(Map<String, dynamic> p) {
    final name = (p['name'] as String?) ?? '?';
    final rating = p['rating'];
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (rating != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$rating',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppTheme.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
