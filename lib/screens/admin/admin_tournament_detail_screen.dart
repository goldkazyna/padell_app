import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/admin_tournament_detail.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/main_tab_bar.dart';

/// Этап 3a — экран управления существующим турниром.
/// Активен только таб «Инфо». «Участники» и «Матчи» — заглушки до 3b/3c.
class AdminTournamentDetailScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const AdminTournamentDetailScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<AdminTournamentDetailScreen> createState() =>
      _AdminTournamentDetailScreenState();
}

class _AdminTournamentDetailScreenState
    extends State<AdminTournamentDetailScreen> {
  int _currentTab = 0; // 0 = Инфо, 1 = Участники, 2 = Матчи

  bool _loading = true;
  String? _error;
  AdminTournamentDetail? _t;

  // Контроллеры формы — создаём один раз и переиспользуем
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _maxParticipants = TextEditingController();
  final _price = TextEditingController();
  DateTime? _startDate;
  double _minLevel = 1.0;
  double _maxLevel = 5.0;

  bool _saving = false;
  bool _starting = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _maxParticipants.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final t = await context
          .read<AdminService>()
          .getTournamentDetail(widget.tournamentId);
      if (!mounted) return;
      _applyToForm(t);
      setState(() {
        _t = t;
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

  void _applyToForm(AdminTournamentDetail t) {
    _name.text = t.name;
    _description.text = t.description ?? '';
    _maxParticipants.text = t.maxParticipants.toString();
    _price.text = t.price != null
        ? (t.price! % 1 == 0 ? t.price!.toInt().toString() : t.price.toString())
        : '';
    _startDate = t.startDate;
    _minLevel = t.minLevel <= 0 ? 1.0 : t.minLevel;
    _maxLevel = t.maxLevel <= 0 ? 5.0 : t.maxLevel;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    final t = _t;
    if (t == null) return;

    final name = _name.text.trim();
    if (name.isEmpty) {
      await showAppAlert(context, 'Название не может быть пустым',
          title: 'Ошибка', isError: true);
      return;
    }
    if (_startDate == null) {
      await showAppAlert(context, 'Укажите дату и время старта',
          title: 'Ошибка', isError: true);
      return;
    }
    final maxP = int.tryParse(_maxParticipants.text.trim());
    if (maxP == null || maxP < 2) {
      await showAppAlert(context, 'Макс. участников должно быть минимум 2',
          title: 'Ошибка', isError: true);
      return;
    }
    if (_minLevel > _maxLevel) {
      await showAppAlert(context, 'Минимальный уровень больше максимального',
          title: 'Ошибка', isError: true);
      return;
    }
    final priceText = _price.text.trim();
    final price = priceText.isEmpty ? null : double.tryParse(priceText);
    if (priceText.isNotEmpty && price == null) {
      await showAppAlert(context, 'Цена должна быть числом',
          title: 'Ошибка', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await context.read<AdminService>().updateTournament(
            t.id,
            name: name,
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            startDate: _startDate!,
            minLevel: _minLevel,
            maxLevel: _maxLevel,
            maxParticipants: maxP,
            price: price,
          );
      if (!mounted) return;
      _applyToForm(updated);
      setState(() {
        _t = updated;
        _saving = false;
      });
      await showAppAlert(context, 'Изменения сохранены');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _start() async {
    final t = _t;
    if (t == null) return;

    final ok = await _confirm(
      title: 'Запустить турнир?',
      message:
          'После запуска регистрация закроется и сформируются раунды. Отменить запуск нельзя.',
      okText: 'Запустить',
    );
    if (!ok) return;

    setState(() => _starting = true);
    try {
      final updated =
          await context.read<AdminService>().startTournament(t.id);
      if (!mounted) return;
      _applyToForm(updated);
      setState(() {
        _t = updated;
        _starting = false;
      });
      await showAppAlert(context, 'Турнир запущен');
    } catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _delete() async {
    final t = _t;
    if (t == null) return;

    final ok = await _confirm(
      title: 'Удалить турнир?',
      message: 'Этот черновик будет удалён без возможности восстановления.',
      okText: 'Удалить',
      destructive: true,
    );
    if (!ok) return;

    setState(() => _deleting = true);
    try {
      await context.read<AdminService>().deleteTournament(t.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String okText,
    bool destructive = false,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        content: Text(message,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              okText,
              style: TextStyle(
                color: destructive ? AppTheme.error : AppTheme.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return res == true;
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ?? DateTime.now().add(const Duration(days: 1));
    final firstDate = DateTime.now().subtract(const Duration(days: 1));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.card,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.card,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _startDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: const MainTabBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent))
                  : _error != null
                      ? _buildError()
                      : IndexedStack(
                          index: _currentTab,
                          children: [
                            _buildInfoTab(),
                            _buildPlaceholder(
                              'Участники',
                              'Этап 3b — модерация заявок, добавление и удаление участников.',
                            ),
                            _buildPlaceholder(
                              'Матчи',
                              'Этап 3c — ввод счёта, генерация раундов и плей-офф.',
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = _t?.name ?? widget.tournamentName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: AppTheme.textPrimary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Управление турниром',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
        ),
        child: Row(
          children: [
            _buildTab('Инфо', 0),
            _buildTab('Участники', 1),
            _buildTab('Матчи', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () {
        if (_currentTab != index) {
          setState(() => _currentTab = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: const Text('Повторить',
                  style: TextStyle(color: AppTheme.accent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined,
                color: AppTheme.textDim, size: 56),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Info tab
  // ---------------------------------------------------------------------------

  Widget _buildInfoTab() {
    final t = _t!;
    final disabled = !t.canEdit;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildStatusCard(t),
          if (disabled) ...[
            const SizedBox(height: 12),
            _buildLockedNotice(),
          ],
          const SizedBox(height: 16),
          _buildSection(
            title: 'Основное',
            children: [
              _label('Название'),
              _textField(_name, hint: 'Например: Турнир выходного дня',
                  enabled: !disabled),
              const SizedBox(height: 12),
              _label('Описание'),
              _textField(_description, hint: 'Можно оставить пустым',
                  maxLines: 3, enabled: !disabled),
              const SizedBox(height: 12),
              _label('Дата и время старта'),
              _dateField(disabled: disabled),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Параметры',
            children: [
              _label('Уровень игроков'),
              const SizedBox(height: 4),
              _levelSliders(disabled: disabled),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Макс. участников'),
                        _textField(_maxParticipants,
                            hint: '8',
                            keyboardType: TextInputType.number,
                            enabled: !disabled,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Цена ₸'),
                        _textField(_price,
                            hint: '0',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            enabled: !disabled),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Сводка',
            children: [
              _readOnlyRow('Тип турнира', t.typeName),
              _readOnlyRow('Клуб', t.club?.name ?? '—'),
              _readOnlyRow('Участников',
                  '${t.participantsCount} / ${t.maxParticipants}'),
              if (t.pendingCount > 0)
                _readOnlyRow('На модерации', '${t.pendingCount}'),
              if (t.courts.isNotEmpty)
                _readOnlyRow('Корты', t.courts.join(', ')),
              if (t.hasPlayoff)
                _readOnlyRow(
                    'Плей-офф',
                    [
                      'Включён',
                      if (t.hasLowerBracket) 'нижняя сетка',
                      if (t.hasBronzeMatch) 'матч за 3-е',
                    ].join(' · ')),
            ],
          ),
          const SizedBox(height: 24),
          _buildActions(t),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AdminTournamentDetail t) {
    final color = _statusColor(t.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.statusName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  t.startDate != null
                      ? _fmtDateTime(t.startDate!)
                      : 'Дата не задана',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: AppTheme.amber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Турнир уже идёт или завершён — редактирование недоступно',
              style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );

  Widget _textField(
    TextEditingController c, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: c,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppTheme.textDim, fontSize: 13),
        filled: true,
        fillColor: AppTheme.cardRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppTheme.accent, width: 1.2),
        ),
      ),
    );
  }

  Widget _dateField({required bool disabled}) {
    final text = _startDate != null
        ? _fmtDateTime(_startDate!)
        : 'Не выбрано';
    return GestureDetector(
      onTap: disabled ? null : _pickStartDate,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_outlined,
                color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: _startDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textDim,
                      fontSize: 14)),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.textDim, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _levelSliders({required bool disabled}) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 64,
              child: Text('Мин',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ),
            Expanded(
              child: Slider(
                value: _minLevel.clamp(1.0, 5.75),
                min: 1.0,
                max: 5.75,
                divisions: 19,
                activeColor: AppTheme.accent,
                inactiveColor: AppTheme.cardRaised,
                label: _minLevel.toStringAsFixed(2),
                onChanged: disabled
                    ? null
                    : (v) => setState(() {
                          _minLevel = double.parse(v.toStringAsFixed(2));
                          if (_minLevel > _maxLevel) _maxLevel = _minLevel;
                        }),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                _minLevel.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(
              width: 64,
              child: Text('Макс',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ),
            Expanded(
              child: Slider(
                value: _maxLevel.clamp(1.0, 5.75),
                min: 1.0,
                max: 5.75,
                divisions: 19,
                activeColor: AppTheme.accent,
                inactiveColor: AppTheme.cardRaised,
                label: _maxLevel.toStringAsFixed(2),
                onChanged: disabled
                    ? null
                    : (v) => setState(() {
                          _maxLevel = double.parse(v.toStringAsFixed(2));
                          if (_maxLevel < _minLevel) _minLevel = _maxLevel;
                        }),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                _maxLevel.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AdminTournamentDetail t) {
    final children = <Widget>[];

    if (t.canEdit) {
      children.add(_primaryButton(
        label: _saving ? 'Сохранение...' : 'Сохранить',
        onTap: _saving ? null : _save,
        loading: _saving,
      ));
    }
    if (t.canStart) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 10));
      children.add(_primaryButton(
        label: _starting ? 'Запуск...' : 'Запустить турнир',
        onTap: _starting ? null : _start,
        loading: _starting,
        color: AppTheme.accent,
      ));
    }
    if (t.canDelete) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 10));
      children.add(_primaryButton(
        label: _deleting ? 'Удаление...' : 'Удалить турнир',
        onTap: _deleting ? null : _delete,
        loading: _deleting,
        color: AppTheme.error,
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return Column(children: children);
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
    bool loading = false,
    Color color = AppTheme.accent,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppTheme.textDim;
      case 'open':
        return AppTheme.accent;
      case 'closed':
        return AppTheme.amber;
      case 'in_progress':
        return AppTheme.blue;
      case 'completed':
        return AppTheme.purple;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _fmtDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} $hh:$mi';
  }
}
