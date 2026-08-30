import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/league.dart';
import '../../services/admin_league_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import 'admin_league_detail_screen.dart';

/// Лиги клуба в админке приложения: список и создание.
class AdminLeaguesScreen extends StatefulWidget {
  final String? clubName;

  const AdminLeaguesScreen({super.key, this.clubName});

  @override
  State<AdminLeaguesScreen> createState() => _AdminLeaguesScreenState();
}

class _AdminLeaguesScreenState extends State<AdminLeaguesScreen> {
  List<League> _leagues = [];
  bool _loading = true;
  String? _error;

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
      final leagues = await context.read<AdminLeagueService>().list();
      if (!mounted) return;
      setState(() {
        _leagues = leagues;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openCreate() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateLeagueSheet(),
    );

    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: AppBackButton(),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Лиги',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (widget.clubName != null)
              Text(widget.clubName!,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Создать лигу', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Не удалось загрузить',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      TextButton(onPressed: _load, child: const Text('Повторить')),
                    ],
                  ),
                )
              : _leagues.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.accent,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: _leagues.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _LeagueRow(
                          league: _leagues[i],
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminLeagueDetailScreen(leagueId: _leagues[i].id),
                              ),
                            );
                            _load();
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 42, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 14),
              Text('Лиг пока нет',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.5)),
              const SizedBox(height: 6),
              Text(
                'Лига — несколько турниров подряд с общим составом и одной '
                'таблицей. Игроки записываются один раз.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
}

class _LeagueRow extends StatelessWidget {
  final League league;
  final VoidCallback onTap;

  const _LeagueRow({required this.league, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    league.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    league.statusName,
                    style: const TextStyle(
                        color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: league.progress,
                minHeight: 5,
                backgroundColor: const Color(0xFF2A3330),
                valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Этапов: ${league.stagesDone} из ${league.stagesTotal}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${league.players} в составе',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            if (league.nextStage?.startDate != null) ...[
              const SizedBox(height: 6),
              Text(
                'Следующий этап ${DateFormat('d MMMM, HH:mm', 'ru').format(league.nextStage!.startDate!)}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Создание лиги: минимум полей, остальное правится потом.
class _CreateLeagueSheet extends StatefulWidget {
  const _CreateLeagueSheet();

  @override
  State<_CreateLeagueSheet> createState() => _CreateLeagueSheetState();
}

class _CreateLeagueSheetState extends State<_CreateLeagueSheet> {
  final _name = TextEditingController();
  final _stages = TextEditingController(text: '8');
  final _players = TextEditingController(text: '12');
  final _price = TextEditingController();
  DateTime? _start;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _stages.dispose();
    _players.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null) return;

    setState(() => _start = date);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      await showAppAlert(context, 'Введите название лиги');
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<AdminLeagueService>().create(
            name: name,
            stagesPlanned: int.tryParse(_stages.text.trim()) ?? 8,
            maxPlayers: int.tryParse(_players.text.trim()),
            price: int.tryParse(_price.text.trim()),
            startDate: _start,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3330),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Новая лига',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Этапы будут турнирами Americano Flex. Состав лиги попадёт в каждый этап.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 16),
            _field(_name, 'Название', hint: 'Например: Сентябрь Кап'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(_stages, 'Этапов', number: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_players, 'Мест', number: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_price, 'Цена этапа', number: true)),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _start == null
                          ? 'Дата старта (необязательно)'
                          : DateFormat('d MMMM y', 'ru').format(_start!),
                      style: TextStyle(
                        color: _start == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Создать лигу',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {String? hint, bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13),
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
