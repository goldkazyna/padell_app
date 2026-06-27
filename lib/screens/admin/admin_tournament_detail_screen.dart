import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/admin_invitation.dart';
import '../../models/admin_matches.dart';
import '../../models/admin_participant.dart';
import '../../models/admin_participants_response.dart';
import '../../models/registration_log_entry.dart';
import '../../models/admin_team.dart';
import '../../models/admin_tournament_detail.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';
import '../../widgets/moderation_countdown.dart';
import '../../widgets/verified_badge.dart';
import '../player_profile_screen.dart';
import 'admin_bali_create_pairs_screen.dart';
import 'admin_koc_create_pairs_screen.dart';
import 'admin_pairing_screen.dart';

/// Этап 3a/3b — экран управления существующим турниром.
/// Таб «Матчи» — заглушка до 3c.
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
  int _currentTab = 0; // 0 = Инфо, 1 = Участники, 2 = Приглашения, 3 = Матчи

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
  bool _verifiedOnly = false;

  bool _saving = false;
  bool _starting = false;
  bool _deleting = false;

  // Этап 3b — участники
  AdminParticipantsResponse? _participants;
  bool _loadingParticipants = false;
  String? _participantsError;

  // Приглашения
  List<AdminInvitation>? _invitations;
  bool _loadingInvitations = false;
  String? _invitationsError;

  // Журнал записей (записались / отписались)
  List<RegistrationLogEntry>? _journalRegistered;
  List<RegistrationLogEntry>? _journalUnregistered;
  bool _loadingJournal = false;
  String? _journalError;
  int _journalSubTab = 0; // 0 = записались, 1 = отписались

  // Глобальный busy-оверлей для длинных экшенов (approve/reject/remove/etc).
  bool _actionBusy = false;
  String? _actionLabel;

  // Этап 3c-1 — матчи
  AdminMatchesResponse? _matches;
  bool _loadingMatches = false;
  String? _matchesError;
  int _selectedGroupIdx = 0;
  // Round Robin: какие раунды раскрыты (override). По умолчанию раскрыт «идёт».
  final Map<int, bool> _rrRoundExpanded = {};

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
    _verifiedOnly = t.verifiedOnly;
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
            verifiedOnly: _verifiedOnly,
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
        // После запуска сгенерились раунды — кэшированный matches/participants
        // (если открывали раньше) сбрасываем, чтобы при переключении табов
        // подгрузилось свежее состояние.
        _matches = null;
        _participants = null;
        _invitations = null;
      });
      // И сразу подгружаем матчи и участников в фоне — чтобы при переходе на
      // таб не было пустого экрана.
      unawaited(_loadMatches());
      unawaited(_loadParticipants());
      await showAppAlert(context, 'Турнир запущен');
    } catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _restart() async {
    final t = _t;
    if (t == null) return;
    final l10n = AppLocalizations.of(context)!;

    final ok = await _confirm(
      title: l10n.restartTournamentConfirmTitle,
      message: l10n.restartTournamentConfirmMessage,
      okText: l10n.restartTournamentConfirmOk,
      destructive: true,
    );
    if (!ok) return;

    setState(() => _starting = true);
    try {
      final updated =
          await context.read<AdminService>().restartTournament(t.id);
      if (!mounted) return;
      _applyToForm(updated);
      setState(() {
        _t = updated;
        _starting = false;
        _matches = null;
        _participants = null;
        _invitations = null;
      });
      unawaited(_loadMatches());
      unawaited(_loadParticipants());
      if (!mounted) return;
      await showAppAlert(context, l10n.restartTournamentSuccess);
    } catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _sendPush() async {
    final t = _t;
    if (t == null) return;

    final ok = await _confirm(
      title: 'Отправить уведомление?',
      message:
          'Push о турнире получат все подходящие пользователи приложения (с учётом города и их настроек).',
      okText: 'Отправить',
    );
    if (!ok) return;

    setState(() => _starting = true);
    try {
      final msg = await context.read<AdminService>().sendTournamentPush(t.id);
      if (!mounted) return;
      setState(() => _starting = false);
      await showAppAlert(context, msg);
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.accent))
                      : _error != null
                          ? _buildError()
                          : IndexedStack(
                              index: _currentTab,
                              children: [
                                _buildInfoTab(),
                                _buildParticipantsTab(),
                                _buildInvitationsTab(),
                                _buildMatchesTab(),
                                _buildJournalTab(),
                              ],
                            ),
                ),
              ],
            ),
          ),
          if (_actionBusy) _buildBusyOverlay(),
        ],
      ),
    );
  }

  Widget _buildBusyOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black.withOpacity(0.55),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppTheme.accent,
                      strokeWidth: 2.4,
                    ),
                  ),
                  if ((_actionLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_actionLabel!,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
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
          const AppBackButton(),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.card,
            onSelected: (value) {
              if (value == 'start') _start();
              if (value == 'restart') _restart();
              if (value == 'send_push') _sendPush();
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final items = <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'start',
                  enabled: _t?.canStart ?? false,
                  child: Text(l10n.startTournamentMenu),
                ),
                PopupMenuItem<String>(
                  value: 'restart',
                  enabled: _t?.canRestart ?? false,
                  child: Text(l10n.restartTournament),
                ),
              ];
              // Личные турниры игроков не шлют пуши всем пользователям.
              if (!(_t?.isPersonal ?? false)) {
                items.add(PopupMenuItem<String>(
                  value: 'send_push',
                  enabled: _t?.status == 'open',
                  child: const Text('Отправить уведомление'),
                ));
              }
              return items;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTab('Инфо', 0),
              _buildTab('Участники', 1),
              _buildTab('Приглашения', 2),
              _buildTab('Матчи', 3),
              _buildTab('Журнал', 4),
            ],
          ),
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
          if (index == 1 && _participants == null && !_loadingParticipants) {
            _loadParticipants();
          }
          if (index == 2 && _invitations == null && !_loadingInvitations) {
            _loadInvitations();
          }
          if (index == 3 && _matches == null && !_loadingMatches) {
            _loadMatches();
          }
          if (index == 4 && _journalRegistered == null && !_loadingJournal) {
            _loadJournal();
          }
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
            _buildLockedNotice(
              noFullAccess: !t.tournamentsFullAccess,
            ),
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
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardRaised,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Только для верифицированных',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            _verifiedOnly
                                ? 'Заявки только от верифицированных игроков'
                                : 'Заявки от любых игроков',
                            style: const TextStyle(
                                color: AppTheme.textDim, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _verifiedOnly,
                      onChanged: disabled
                          ? null
                          : (v) => setState(() => _verifiedOnly = v),
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Сводка',
            children: [
              _readOnlyRow('Тип турнира', t.typeName),
              if (t.isPersonal)
                _readOnlyRow('Организатор', t.creatorName ?? '—')
              else
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

  Widget _buildLockedNotice({bool noFullAccess = false}) {
    final text = noFullAccess
        ? 'У вас нет прав на редактирование турниров. Обратитесь к админу клуба.'
        : 'Турнир уже идёт или завершён — редактирование недоступно';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppTheme.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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
    // Групповой с ручным сбором пар: вместо «Запустить» ведём на экран сбора
    // пар (там собираем пары и стартуем). Доступно пока турнир открыт.
    if (t.isAdminPairing && t.status == 'open') {
      if (children.isNotEmpty) children.add(const SizedBox(height: 10));
      children.add(_primaryButton(
        label: 'Собрать пары',
        onTap: _starting
            ? null
            : () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AdminPairingScreen(
                      tournamentId: t.id,
                      tournamentName: t.name,
                    ),
                  ),
                );
                if (ok == true) {
                  try {
                    final fresh = await context
                        .read<AdminService>()
                        .getTournamentDetail(t.id);
                    if (mounted) {
                      _applyToForm(fresh);
                      setState(() {
                        _t = fresh;
                        _matches = null;
                        _participants = null;
                      });
                    }
                  } catch (_) {}
                }
              },
        color: AppTheme.accent,
      ));
    } else if (t.canStart) {
      // Bali KOC / фикс-парный Король корта: до создания пар нельзя стартовать.
      final isBaliWithoutPairs =
          t.type == 'bali_koc' && !t.baliPairsCreated;
      final isKocWithoutPairs =
          t.type == 'king_of_court' && t.isPaired && !t.kocPairsCreated;
      final needPairs = isBaliWithoutPairs || isKocWithoutPairs;
      if (children.isNotEmpty) children.add(const SizedBox(height: 10));
      if (needPairs) {
        children.add(_primaryButton(
          label: 'Создать пары',
          onTap: _starting
              ? null
              : () async {
                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => isKocWithoutPairs
                          ? AdminKocCreatePairsScreen(
                              tournamentId: t.id,
                              tournamentName: t.name,
                            )
                          : AdminBaliCreatePairsScreen(
                              tournamentId: t.id,
                              tournamentName: t.name,
                            ),
                    ),
                  );
                  if (ok == true) {
                    // Перезагружаем карточку чтобы появилась кнопка «Запустить турнир»
                    try {
                      final fresh = await context
                          .read<AdminService>()
                          .getTournamentDetail(t.id);
                      if (mounted) setState(() => _t = fresh);
                    } catch (_) {}
                  }
                },
          color: AppTheme.accent,
        ));
      } else {
        children.add(_primaryButton(
          label: _starting ? 'Запуск...' : 'Запустить турнир',
          onTap: _starting ? null : _start,
          loading: _starting,
          color: AppTheme.accent,
        ));
      }
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
        return AppTheme.textSecondary;
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

  // ===========================================================================
  // 3b — таб «Участники»
  // ===========================================================================

  Future<void> _loadParticipants() async {
    setState(() {
      _loadingParticipants = true;
      _participantsError = null;
    });
    try {
      final r = await context
          .read<AdminService>()
          .getParticipants(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _participants = r;
        _loadingParticipants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _participantsError = '$e';
        _loadingParticipants = false;
      });
    }
  }

  Future<void> _loadInvitations() async {
    setState(() {
      _loadingInvitations = true;
      _invitationsError = null;
    });
    try {
      final list = await context
          .read<AdminService>()
          .getTournamentInvitations(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _invitations = list;
        _loadingInvitations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _invitationsError = '$e';
        _loadingInvitations = false;
      });
    }
  }

  /// Перезагрузить и список участников, и инфо (для синхронизации счётчиков).
  Future<void> _refreshAfterAction() async {
    await Future.wait([
      _loadParticipants(),
      if (_invitations != null) _loadInvitations(),
      context
          .read<AdminService>()
          .getTournamentDetail(widget.tournamentId)
          .then((t) {
        if (!mounted) return;
        setState(() => _t = t);
      }).catchError((_) {}),
    ]);
  }

  // ===========================================================================
  // Таб «Приглашения»
  // ===========================================================================

  Widget _buildInvitationsTab() {
    if (_loadingInvitations && _invitations == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_invitationsError != null && _invitations == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_invitationsError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadInvitations,
                child: const Text('Повторить',
                    style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
        ),
      );
    }

    final list = _invitations ?? const <AdminInvitation>[];
    const maxInvites = 10;
    final atLimit = list.length >= maxInvites;
    final canInvite =
        _t != null && (_t!.type != 'team' || _t!.isAdminPairing) && !atLimit;

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Приглашено: ${list.length} / $maxInvites',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    if (atLimit && (_t?.type != 'team' || (_t?.isAdminPairing ?? false))) ...[
                      const SizedBox(height: 2),
                      const Text('Лимит приглашений достигнут',
                          style: TextStyle(
                              color: AppTheme.amber, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              if (canInvite)
                ElevatedButton.icon(
                  onPressed: _openInvitePlayer,
                  icon: const Icon(Icons.mail_outline, size: 16),
                  label: const Text('Пригласить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: Text('Пока никого не пригласили',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14)),
              ),
            )
          else
            for (final inv in list) ...[
              _buildInvitationCard(inv),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  Widget _buildInvitationCard(AdminInvitation inv) {
    final p = inv.player;
    final (label, color) = switch (inv.status) {
      'accepted' => ('Принял', AppTheme.accent),
      'declined' => ('Отклонил', AppTheme.textSecondary),
      _ => ('Ожидает', AppTheme.amber),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _avatar(p),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _cancelInvitation(inv),
            icon: const Icon(Icons.close, size: 20, color: AppTheme.error),
            tooltip: 'Убрать из списка',
          ),
        ],
      ),
    );
  }

  Future<void> _cancelInvitation(AdminInvitation inv) async {
    await _runAction(
      () => context
          .read<AdminService>()
          .cancelInvitation(widget.tournamentId, inv.id),
      label: 'Убираем из списка...',
    );
  }

  Widget _buildParticipantsTab() {
    if (_loadingParticipants && _participants == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_participantsError != null && _participants == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_participantsError!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadParticipants,
                child: const Text('Повторить',
                    style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
        ),
      );
    }
    final r = _participants;
    if (r == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _refreshAfterAction,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: r.isTeam
          ? _buildTeamsList(r)
          : _buildSinglesList(r),
    );
  }

  // -------------------- Одиночные --------------------

  Widget _buildSinglesList(AdminParticipantsResponse r) {
    final pending = r.participants.where((p) => p.status == 'pending').toList();
    final approved =
        r.participants.where((p) => p.status == 'registered').toList();
    final waiting = r.participants.where((p) => p.status == 'waiting').toList();
    final taken = approved.length + pending.length;
    final isFull = taken >= r.max;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _buildParticipantsHeader(
          approved: approved.length,
          max: r.max,
          pending: pending.length,
          canModify: r.canModify,
          isFull: isFull,
          onAdd: r.canModify ? _openAddPlayer : null,
        ),
        if (pending.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPendingBlock(pending),
        ],
        const SizedBox(height: 12),
        if (approved.isEmpty)
          _buildEmptyHint('Подтверждённых участников ещё нет')
        else
          ...approved.map((p) =>
              _buildParticipantTile(p, canModify: r.canModify)),
        if (waiting.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildWaitlistBlock(waiting, r.canModify),
        ],
      ],
    );
  }

  /// Блок «Лист ожидания» — синий, с возможностью удалить.
  Widget _buildWaitlistBlock(List<AdminParticipant> waiting, bool canModify) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.blue.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppTheme.blue, size: 18),
              const SizedBox(width: 8),
              Text('Лист ожидания: ${waiting.length}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...waiting.map((p) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _avatar(p),
                      const SizedBox(width: 10),
                      Expanded(child: _nameAndMeta(p)),
                      if (canModify)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: AppTheme.textSecondary),
                          color: AppTheme.cardRaised,
                          onSelected: (v) {
                            if (v == 'profile') _openProfile(p);
                            if (v == 'to_main') _moveParticipant(p, 'registered');
                            if (v == 'moderation') _moveParticipant(p, 'pending');
                            if (v == 'call') _callPlayer(p);
                            if (v == 'whatsapp') _whatsappPlayer(p);
                            if (v == 'remove') _removeOne(p);
                          },
                          itemBuilder: (_) => [
                            _popupItem(
                                'profile',
                                const Icon(Icons.person_outline,
                                    size: 18, color: AppTheme.textSecondary),
                                'Просмотреть профиль',
                                AppTheme.textPrimary),
                            _popupItem(
                                'to_main',
                                const Icon(Icons.check_circle,
                                    size: 18, color: AppTheme.accent),
                                'Переместить в основной список',
                                AppTheme.accent),
                            _popupItem(
                                'moderation',
                                const Icon(Icons.how_to_reg,
                                    size: 18, color: AppTheme.accent),
                                'Переместить в модерацию',
                                AppTheme.textPrimary),
                            if ((p.phone ?? '').isNotEmpty) ...[
                              _popupItem(
                                  'call',
                                  const Icon(Icons.call,
                                      size: 18, color: AppTheme.accent),
                                  'Позвонить',
                                  AppTheme.textPrimary),
                              _popupItem(
                                  'whatsapp',
                                  const FaIcon(FontAwesomeIcons.whatsapp,
                                      size: 17, color: Color(0xFF25D366)),
                                  'WhatsApp',
                                  AppTheme.textPrimary),
                            ],
                            _popupItem(
                                'remove',
                                const Icon(Icons.delete_outline,
                                    size: 18, color: AppTheme.error),
                                'Удалить',
                                AppTheme.error),
                          ],
                        ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPendingBlock(List<AdminParticipant> pending) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule,
                  color: AppTheme.amber, size: 18),
              const SizedBox(width: 8),
              Text('На модерации: ${pending.length}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...pending.map(_buildPendingTile),
        ],
      ),
    );
  }

  Widget _buildPendingTile(AdminParticipant p) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _avatar(p),
            const SizedBox(width: 10),
            Expanded(child: _nameAndMeta(p)),
            if (p.moderationDeadline != null) ...[
              const SizedBox(width: 8),
              ModerationCountdown(deadline: p.moderationDeadline!, compact: true),
            ],
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary),
              color: AppTheme.cardRaised,
              onSelected: (v) {
                if (v == 'profile') _openProfile(p);
                if (v == 'call') _callPlayer(p);
                if (v == 'whatsapp') _whatsappPlayer(p);
                if (v == 'approve') _approveOne(p);
                if (v == 'waitlist') _moveParticipant(p, 'waiting');
                if (v == 'reject') _rejectOne(p);
              },
              itemBuilder: (_) => [
                _popupItem('profile',
                    const Icon(Icons.person_outline,
                        size: 18, color: AppTheme.textSecondary),
                    'Просмотреть профиль', AppTheme.textPrimary),
                if ((p.phone ?? '').isNotEmpty) ...[
                  _popupItem('call',
                      const Icon(Icons.call, size: 18, color: AppTheme.accent),
                      'Позвонить', AppTheme.textPrimary),
                  _popupItem('whatsapp',
                      const FaIcon(FontAwesomeIcons.whatsapp,
                          size: 17, color: Color(0xFF25D366)),
                      'WhatsApp', AppTheme.textPrimary),
                ],
                _popupItem('approve',
                    const Icon(Icons.check_circle,
                        size: 18, color: AppTheme.accent),
                    'Одобрить', AppTheme.accent),
                _popupItem('waitlist',
                    const Icon(Icons.hourglass_bottom,
                        size: 18, color: AppTheme.blue),
                    'Переместить в лист ожидания', AppTheme.textPrimary),
                _popupItem('reject',
                    const Icon(Icons.cancel, size: 18, color: AppTheme.error),
                    'Отклонить', AppTheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantTile(AdminParticipant p,
      {required bool canModify}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _avatar(p),
          const SizedBox(width: 10),
          Expanded(child: _nameAndMeta(p)),
          if (canModify)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary),
              color: AppTheme.cardRaised,
              onSelected: (v) {
                if (v == 'profile') _openProfile(p);
                if (v == 'call') _callPlayer(p);
                if (v == 'whatsapp') _whatsappPlayer(p);
                if (v == 'replace') _openReplacePlayer(p);
                if (v == 'to_moderation') _moveParticipant(p, 'pending');
                if (v == 'waitlist') _moveParticipant(p, 'waiting');
                if (v == 'remove') _removeOne(p);
              },
              itemBuilder: (_) => [
                _popupItem('profile',
                    const Icon(Icons.person_outline,
                        size: 18, color: AppTheme.textSecondary),
                    'Просмотреть профиль', AppTheme.textPrimary),
                if ((p.phone ?? '').isNotEmpty) ...[
                  _popupItem('call',
                      const Icon(Icons.call, size: 18, color: AppTheme.accent),
                      'Позвонить', AppTheme.textPrimary),
                  _popupItem('whatsapp',
                      const FaIcon(FontAwesomeIcons.whatsapp,
                          size: 17, color: Color(0xFF25D366)),
                      'WhatsApp', AppTheme.textPrimary),
                ],
                _popupItem('replace',
                    const Icon(Icons.swap_horiz,
                        size: 18, color: AppTheme.textSecondary),
                    'Заменить', AppTheme.textPrimary),
                _popupItem('to_moderation',
                    const Icon(Icons.how_to_reg,
                        size: 18, color: AppTheme.accent),
                    'Переместить в модерацию', AppTheme.textPrimary),
                _popupItem('waitlist',
                    const Icon(Icons.hourglass_bottom,
                        size: 18, color: AppTheme.blue),
                    'Переместить в лист ожидания', AppTheme.textPrimary),
                _popupItem('remove',
                    const Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.error),
                    'Удалить', AppTheme.error),
              ],
            ),
        ],
      ),
    );
  }

  // -------------------- Команды --------------------

  Widget _buildTeamsList(AdminParticipantsResponse r) {
    final pending = r.teams.where((t) => t.status == 'pending').toList();
    final approved = r.teams.where((t) => t.status == 'approved').toList();
    final waiting = r.teams.where((t) => t.status == 'waiting').toList();
    final taken = approved.length + pending.length;
    final isFull = taken >= r.max;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _buildParticipantsHeader(
          approved: approved.length,
          max: r.max,
          pending: pending.length,
          canModify: r.canModify,
          isFull: isFull,
          onAdd: null, // парные турниры — добавление через Web
          subtitle: 'пар',
        ),
        if (pending.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPendingTeamsBlock(pending),
        ],
        const SizedBox(height: 12),
        if (approved.isEmpty)
          _buildEmptyHint('Одобренных пар ещё нет')
        else
          ...approved.map((t) =>
              _buildTeamTile(t, canModify: r.canModify, pending: false)),
        if (waiting.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildWaitlistTeamsBlock(waiting, r.canModify),
        ],
      ],
    );
  }

  Widget _buildWaitlistTeamsBlock(List<AdminTeam> teams, bool canModify) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.blue.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppTheme.blue, size: 18),
              const SizedBox(width: 8),
              Text('Пар в листе ожидания: ${teams.length}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...teams.map((t) =>
              _buildTeamTile(t, canModify: canModify, pending: false)),
        ],
      ),
    );
  }

  Widget _buildPendingTeamsBlock(List<AdminTeam> teams) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule,
                  color: AppTheme.amber, size: 18),
              const SizedBox(width: 8),
              Text('Пар на модерации: ${teams.length}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...teams.map((t) =>
              _buildTeamTile(t, canModify: true, pending: true)),
        ],
      ),
    );
  }

  Widget _buildTeamTile(AdminTeam t,
      {required bool canModify, required bool pending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: pending ? AppTheme.card : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (t.player1 != null)
            _buildTeamPlayerRow(t.player1!, isFirst: true),
          if (t.player1 != null && t.player2 != null)
            const Divider(color: AppTheme.divider, height: 14),
          if (t.player2 != null)
            _buildTeamPlayerRow(t.player2!, isFirst: false),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              if (pending) ...[
                TextButton(
                  onPressed: () => _approveTeam(t),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Одобрить',
                      style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: () => _rejectTeam(t),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Отклонить',
                      style: TextStyle(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w700)),
                ),
              ] else if (canModify)
                TextButton(
                  onPressed: () => _removeTeam(t),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Удалить пару',
                      style: TextStyle(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamPlayerRow(AdminParticipant p, {required bool isFirst}) {
    return Row(
      children: [
        _avatar(p),
        const SizedBox(width: 10),
        Expanded(child: _nameAndMeta(p)),
      ],
    );
  }

  // -------------------- Общие виджеты --------------------

  Widget _buildParticipantsHeader({
    required int approved,
    required int max,
    required int pending,
    required bool canModify,
    required bool isFull,
    required VoidCallback? onAdd,
    VoidCallback? onInvite,
    String subtitle = 'участников',
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$approved / $max $subtitle',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                if (pending > 0) ...[
                  const SizedBox(height: 2),
                  Text('На модерации: $pending',
                      style: const TextStyle(
                          color: AppTheme.amber, fontSize: 12)),
                ],
                if (isFull) ...[
                  const SizedBox(height: 2),
                  const Text('Лимит участников достигнут',
                      style: TextStyle(
                          color: AppTheme.error, fontSize: 12)),
                ],
              ],
            ),
          ),
          if (onInvite != null) ...[
            OutlinedButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.mail_outline, size: 16),
              label: const Text('Пригласить'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (onAdd != null)
            ElevatedButton.icon(
              onPressed: isFull ? null : onAdd,
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Добавить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.cardRaised,
                disabledForegroundColor: AppTheme.textDim,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Таб «Журнал записей» (записались / отписались)
  // ===========================================================================

  Future<void> _loadJournal() async {
    setState(() {
      _loadingJournal = true;
      _journalError = null;
    });
    try {
      final r = await context
          .read<AdminService>()
          .getRegistrationJournal(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _journalRegistered = r['registered'] ?? [];
        _journalUnregistered = r['unregistered'] ?? [];
        _loadingJournal = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _journalError = '$e';
        _loadingJournal = false;
      });
    }
  }

  Widget _buildJournalTab() {
    if (_loadingJournal && _journalRegistered == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_journalError != null && _journalRegistered == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ошибка: $_journalError',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loadJournal, child: const Text('Повторить')),
          ],
        ),
      );
    }

    final reg = _journalRegistered ?? const [];
    final unreg = _journalUnregistered ?? const [];
    final entries = _journalSubTab == 0 ? reg : unreg;

    return Column(
      children: [
        // Под-вкладки (сегмент-контрол)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _journalSegment('Записались', reg.length, 0),
                _journalSegment('Отписались', unreg.length, 1),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadJournal,
            color: AppTheme.accent,
            child: entries.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      _buildEmptyHint(_journalSubTab == 0
                          ? 'Пока никто не записывался'
                          : 'Пока никто не отписывался'),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _journalRow(entries[i]),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _journalSegment(String label, int count, int index) {
    final active = _journalSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _journalSubTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              color: active ? Colors.black : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _journalRow(RegistrationLogEntry e) {
    final isReg = e.action == 'registered';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          _avatar(e.user),
          const SizedBox(width: 12),
          Expanded(child: _nameAndMeta(e.user)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isReg ? AppTheme.accent : AppTheme.error)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isReg ? 'записался' : 'отписался',
                  style: TextStyle(
                    color: isReg ? AppTheme.accent : AppTheme.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (e.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  _journalTime(e.createdAt!),
                  style: const TextStyle(
                      color: AppTheme.textDim, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _journalTime(DateTime utc) {
    final d = utc.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm $hh:$mi';
  }

  Widget _avatar(AdminParticipant p) {
    final initials = _initials(p.name);
    final hasAvatar = (p.avatarUrl ?? '').isNotEmpty;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        shape: BoxShape.circle,
        image: hasAvatar
            ? DecorationImage(
                image: NetworkImage(p.avatarUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: hasAvatar
          ? null
          : Center(
              child: Text(initials,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
    );
  }

  Widget _nameAndMeta(AdminParticipant p) {
    final pieces = <String>[];
    if (p.level != null) pieces.add('L${p.level!.toStringAsFixed(2)}');
    if (p.rating != null) pieces.add('${p.rating}');
    if ((p.phone ?? '').isNotEmpty) pieces.add(_formatPhone(p.phone));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(p.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 6),
            if (p.levelVerified)
              const VerifiedBadge(size: 13)
            else
              const Icon(Icons.shield_outlined,
                  size: 14, color: AppTheme.textDim),
          ],
        ),
        if (pieces.isNotEmpty)
          Text(pieces.join(' · '),
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  // -------------------- Действия --------------------

  PopupMenuItem<String> _popupItem(
      String value, Widget icon, String label, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  void _openProfile(AdminParticipant p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(
          playerId: p.id,
          playerName: p.name,
        ),
      ),
    );
  }

  String _digitsOnly(String phone) => phone.replaceAll(RegExp(r'[^\d]'), '');

  /// Телефон в виде «+7 777 433 38 22».
  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    var d = _digitsOnly(phone);
    if (d.length == 11 && d.startsWith('8')) d = '7${d.substring(1)}';
    if (d.length == 10) d = '7$d';
    if (d.length == 11) {
      return '+${d[0]} ${d.substring(1, 4)} ${d.substring(4, 7)} '
          '${d.substring(7, 9)} ${d.substring(9, 11)}';
    }
    return phone.trim().startsWith('+') ? phone.trim() : '+$d';
  }

  Future<void> _callPlayer(AdminParticipant p) async {
    final ph = p.phone;
    if (ph == null || ph.isEmpty) return;
    final tel = ph.startsWith('+') ? ph : '+${_digitsOnly(ph)}';
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsappPlayer(AdminParticipant p) async {
    final ph = p.phone;
    if (ph == null || ph.isEmpty) return;
    final uri = Uri.parse('https://wa.me/${_digitsOnly(ph)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _approveOne(AdminParticipant p) async {
    await _runAction(
      () => context
          .read<AdminService>()
          .approveParticipant(widget.tournamentId, p.id),
      label: 'Одобряем заявку...',
    );
  }

  Future<void> _rejectOne(AdminParticipant p) async {
    final ok = await _confirm(
      title: 'Отклонить заявку?',
      message: 'Игрок ${p.name} получит уведомление.',
      okText: 'Отклонить',
      destructive: true,
    );
    if (!ok) return;
    await _runAction(
      () => context
          .read<AdminService>()
          .rejectParticipant(widget.tournamentId, p.id),
      label: 'Отклоняем заявку...',
    );
  }

  Future<void> _removeOne(AdminParticipant p) async {
    final ok = await _confirm(
      title: 'Удалить участника?',
      message: '${p.name} будет удалён из турнира.',
      okText: 'Удалить',
      destructive: true,
    );
    if (!ok) return;
    await _runAction(
      () => context
          .read<AdminService>()
          .removeParticipant(widget.tournamentId, p.id),
      label: 'Удаляем участника...',
    );
  }

  // Универсальное перемещение: 'registered' / 'pending' / 'waiting'.
  Future<void> _moveParticipant(AdminParticipant p, String to) async {
    await _runAction(
      () => context
          .read<AdminService>()
          .moveParticipant(widget.tournamentId, p.id, to),
      label: 'Перемещаем...',
    );
  }

  Future<void> _approveTeam(AdminTeam t) async {
    await _runAction(
      () => context
          .read<AdminService>()
          .approveTeam(widget.tournamentId, t.id),
      label: 'Одобряем пару...',
    );
  }

  Future<void> _rejectTeam(AdminTeam t) async {
    final ok = await _confirm(
      title: 'Отклонить пару?',
      message: 'Заявка будет удалена.',
      okText: 'Отклонить',
      destructive: true,
    );
    if (!ok) return;
    await _runAction(
      () => context
          .read<AdminService>()
          .rejectTeam(widget.tournamentId, t.id),
      label: 'Отклоняем пару...',
    );
  }

  Future<void> _removeTeam(AdminTeam t) async {
    final ok = await _confirm(
      title: 'Удалить пару?',
      message: 'Пара будет удалена из турнира.',
      okText: 'Удалить',
      destructive: true,
    );
    if (!ok) return;
    await _runAction(
      () => context
          .read<AdminService>()
          .removeTeam(widget.tournamentId, t.id),
      label: 'Удаляем пару...',
    );
  }

  Future<void> _runAction(Future<void> Function() action,
      {String label = 'Применяем...', String? successMessage}) async {
    if (_actionBusy) return;
    setState(() {
      _actionBusy = true;
      _actionLabel = label;
    });
    try {
      await action();
      await _refreshAfterAction();
      if (mounted && successMessage != null) {
        await showAppAlert(context, successMessage, title: 'Готово');
      }
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _actionBusy = false;
          _actionLabel = null;
        });
      }
    }
  }

  // -------------------- Поиск / добавление / замена --------------------

  Future<void> _openAddPlayer() async {
    if (_actionBusy) return;

    // Перед открытием поиска ВСЕГДА перепроверяем лимит со свежими данными
    // с сервера — на случай если кто-то добавил игроков из веба и наш UI
    // ещё не обновился.
    setState(() {
      _actionBusy = true;
      _actionLabel = 'Проверяем места...';
    });
    AdminParticipantsResponse fresh;
    try {
      fresh =
          await context.read<AdminService>().getParticipants(widget.tournamentId);
      if (!mounted) return;
      setState(() => _participants = fresh);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionBusy = false;
        _actionLabel = null;
      });
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
      return;
    } finally {
      if (mounted) {
        setState(() {
          _actionBusy = false;
          _actionLabel = null;
        });
      }
    }

    if (!fresh.isTeam) {
      final taken = fresh.participants
          .where((p) => p.status == 'registered' || p.status == 'pending')
          .length;
      if (taken >= fresh.max) {
        if (!mounted) return;
        await showAppAlert(
          context,
          'Достигнут лимит участников: $taken / ${fresh.max}. '
          'Удалите кого-то или отклоните заявку, чтобы освободить место.',
          title: 'Нельзя добавить',
          isError: true,
        );
        return;
      }
    }

    if (!mounted) return;
    final selected = await _showPlayerSearchSheet(
      title: 'Добавить игрока',
    );
    if (selected == null) return;
    await _runAction(
      () => context
          .read<AdminService>()
          .addParticipant(widget.tournamentId, selected.id),
      label: 'Добавляем игрока...',
    );
  }

  Future<void> _openInvitePlayer() async {
    final selected = await _showPlayerSearchSheet(
      title: 'Пригласить игрока',
    );
    if (selected == null) return;
    await _runAction(
      () => context
          .read<AdminService>()
          .invitePlayer(widget.tournamentId, selected.id),
      label: 'Отправляем приглашение...',
      successMessage: 'Приглашение отправлено',
    );
  }

  Future<void> _openReplacePlayer(AdminParticipant old) async {
    final selected = await _showPlayerSearchSheet(
      title: 'Заменить ${old.name}',
    );
    if (selected == null) return;
    await _runAction(
      () => context.read<AdminService>().replaceParticipant(
            widget.tournamentId,
            old.id,
            selected.id,
          ),
      label: 'Заменяем игрока...',
    );
  }

  Future<AdminParticipant?> _showPlayerSearchSheet({
    required String title,
  }) async {
    return showModalBottomSheet<AdminParticipant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PlayerSearchSheet(
        title: title,
        tournamentId: widget.tournamentId,
      ),
    );
  }

  // ===========================================================================
  // 3c-1 — таб «Матчи» (Американо)
  // ===========================================================================

  Future<void> _loadMatches() async {
    setState(() {
      _loadingMatches = true;
      _matchesError = null;
    });
    try {
      final r = await context
          .read<AdminService>()
          .getMatches(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _matches = r;
        _loadingMatches = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _matchesError = '$e';
        _loadingMatches = false;
      });
    }
  }

  Widget _buildMatchesTab() {
    if (_loadingMatches && _matches == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_matchesError != null && _matches == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_matchesError!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadMatches,
                child: const Text('Повторить',
                    style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
        ),
      );
    }
    final r = _matches;
    if (r == null) return const SizedBox.shrink();

    if (r.unsupported) {
      return _buildPlaceholder(
        'Скоро',
        r.unsupportedMessage ??
            'Этот тип турнира пока не поддерживается в мобильной админке.',
      );
    }

    // Bali KOC: пары ещё не созданы — показать кнопку «Создать пары»
    if (r.pairsRequired) {
      return _buildBaliPairsRequiredView(r);
    }

    if (r.groups.isEmpty &&
        (r.playoff?.matches.isEmpty ?? true)) {
      return RefreshIndicator(
        onRefresh: _loadMatches,
        color: AppTheme.accent,
        backgroundColor: AppTheme.card,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: const [
                  Icon(Icons.sports_tennis,
                      color: AppTheme.textDim, size: 48),
                  SizedBox(height: 12),
                  Text('Раунды ещё не сгенерированы.\nЗапусти турнир.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedGroupIdx >= r.groups.length) {
      _selectedGroupIdx = 0;
    }
    final selectedGroup =
        r.groups.isNotEmpty ? r.groups[_selectedGroupIdx] : null;

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (r.summary != null) _buildMatchesSummary(r.summary!),
          if (r.groups.length > 1) ...[
            const SizedBox(height: 12),
            _buildGroupTabs(r.groups),
          ],
          if (selectedGroup != null) ...[
            const SizedBox(height: 12),
            _buildGroupCard(selectedGroup),
          ],
          if (r.playoff != null && r.playoff!.matches.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPlayoffSection(r.playoff!),
          ],
        ],
      ),
    );
  }

  /// Заглушка для Bali KOC, когда пары ещё не созданы.
  Widget _buildBaliPairsRequiredView(AdminMatchesResponse r) {
    final participants = r.participantsCount;
    final expected = r.expectedPairsCount;
    final ready = participants >= 8 && participants % 4 == 0;

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.groups_rounded,
                        color: AppTheme.accent, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Bali Format — нужны пары',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  participants > 0
                      ? 'Зарегистрировано $participants игроков → '
                          'нужно создать $expected пар.'
                      : 'Сначала зарегистрируйте участников.',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                if (!ready) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Игроков должно быть минимум 8 и кратно 4.',
                    style: TextStyle(
                        color: AppTheme.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: (_actionBusy || !ready)
                        ? null
                        : () async {
                            final ok = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => AdminBaliCreatePairsScreen(
                                  tournamentId: widget.tournamentId,
                                  tournamentName: _t?.name ?? 'Турнир',
                                ),
                              ),
                            );
                            if (ok == true) {
                              await _loadMatches();
                            }
                          },
                    icon: const Icon(Icons.shuffle_rounded, size: 18),
                    label: const Text('Создать пары'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTabs(List<AdminMatchGroup> groups) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < groups.length; i++)
            Expanded(child: _groupTabBtn(groups[i].name, i)),
        ],
      ),
    );
  }

  Widget _groupTabBtn(String label, int idx) {
    final isActive = _selectedGroupIdx == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedGroupIdx = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label.isEmpty ? 'Группа ${idx + 1}' : label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : const Color(0xFF52525B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesSummary(AdminMatchesSummary s) {
    final pct = s.matchesTotal == 0 ? 0.0 : s.matchesPlayed / s.matchesTotal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Сыграно ${s.matchesPlayed} / ${s.matchesTotal}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              if (s.allGroupMatchesPlayed)
                const Icon(Icons.check_circle,
                    color: AppTheme.accent, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppTheme.cardRaised,
              valueColor:
                  const AlwaysStoppedAnimation(AppTheme.accent),
            ),
          ),
          if (s.canGeneratePlayoff) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _actionBusy ? null : _generatePlayoff,
                icon: const Icon(Icons.emoji_events_outlined, size: 18),
                label: const Text('Сгенерировать плей-офф'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  disabledBackgroundColor:
                      AppTheme.accent.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          if (s.canGenerateNextRound) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _actionBusy ? null : _generateNextRound,
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                label: const Text('Сгенерировать следующий раунд'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  disabledBackgroundColor:
                      AppTheme.accent.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          if (s.canFinish) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _actionBusy ? null : _finish,
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Завершить турнир'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  disabledBackgroundColor:
                      AppTheme.accent.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateNextRound() async {
    if (_actionBusy) return;
    final ok = await _confirm(
      title: 'Сгенерировать следующий раунд?',
      message:
          'Игроки будут переставлены по кортам по результатам текущего раунда.',
      okText: 'Сгенерировать',
    );
    if (!ok) return;

    setState(() {
      _actionBusy = true;
      _actionLabel = 'Генерируем раунд...';
    });
    try {
      final fresh = await context
          .read<AdminService>()
          .generateNextRound(widget.tournamentId);
      if (!mounted) return;
      setState(() => _matches = fresh);
      try {
        final t = await context
            .read<AdminService>()
            .getTournamentDetail(widget.tournamentId);
        if (mounted) setState(() => _t = t);
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _actionBusy = false;
          _actionLabel = null;
        });
      }
    }
  }

  Future<void> _generatePlayoff() async {
    if (_actionBusy) return;
    final ok = await _confirm(
      title: 'Сгенерировать плей-офф?',
      message:
          'Создадутся полуфиналы и финал из топ-4 каждой группы. Действие необратимо.',
      okText: 'Сгенерировать',
    );
    if (!ok) return;

    setState(() {
      _actionBusy = true;
      _actionLabel = 'Генерируем плей-офф...';
    });
    try {
      final svc = context.read<AdminService>();
      final fresh = _matches?.type == 'team'
          ? await svc.generateTeamPlayoff(widget.tournamentId)
          : await svc.generatePlayoff(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _matches = fresh;
      });
      // Сводка/can_* в инфо-табе тоже могла поменяться
      try {
        final t = await context
            .read<AdminService>()
            .getTournamentDetail(widget.tournamentId);
        if (mounted) setState(() => _t = t);
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _actionBusy = false;
          _actionLabel = null;
        });
      }
    }
  }

  Future<void> _finish() async {
    if (_actionBusy) return;
    final ok = await _confirm(
      title: 'Завершить турнир?',
      message:
          'После завершения изменится рейтинг всех участников. Действие необратимо.',
      okText: 'Завершить',
    );
    if (!ok) return;

    setState(() {
      _actionBusy = true;
      _actionLabel = 'Завершаем турнир...';
    });
    try {
      final t = await context
          .read<AdminService>()
          .finishTournament(widget.tournamentId);
      if (!mounted) return;
      _applyToForm(t);
      setState(() {
        _t = t;
        // Сбрасываем кэш матчей — старый summary с can_finish=true устарел.
        _matches = null;
      });
      // Грузим свежий список матчей в фоне.
      unawaited(_loadMatches());
      if (!mounted) return;
      await showAppAlert(context,
          'Турнир завершён, рейтинг применён');
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _actionBusy = false;
          _actionLabel = null;
        });
      }
    }
  }

  Widget _buildGroupCard(AdminMatchGroup g) {
    final hasName = g.name.trim().isNotEmpty;
    final played = g.rounds.fold<int>(
        0, (a, r) => a + r.matches.where((m) => m.isCompleted).length);
    final total = g.rounds.fold<int>(0, (a, r) => a + r.matches.length);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasName) ...[
            Row(
              children: [
                Expanded(
                  child: Text(g.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
                Text(
                  '$played / $total',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (g.leaderboard.isNotEmpty) ...[
            _matches?.type == 'americano_flex'
                ? _buildFlexLeaderboard(g.leaderboard)
                : (_matches?.type == 'round_robin'
                    ? _buildRoundRobinLeaderboard(g.leaderboard)
                    : _buildLeaderboard(g.leaderboard)),
            const SizedBox(height: 12),
          ],
          ...g.rounds.map(_buildRoundBlock),
        ],
      ),
    );
  }

  Widget _buildFlexLeaderboard(List<AdminLeaderboardRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: FlexColumnWidth(),
          3: IntrinsicColumnWidth(),
          4: IntrinsicColumnWidth(),
          5: IntrinsicColumnWidth(),
          6: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            _flexHdr('#',
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(2, 8, 6, 8)),
            const SizedBox(),
            _flexHdr('ИГРОК',
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8)),
            _flexHdr('М'),
            _flexHdr('ОТД'),
            _flexHdr('СРЕД'),
            _flexHdr('ОЧКИ',
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.fromLTRB(6, 8, 4, 8)),
          ]),
          for (final p in rows) _flexLeaderRow(p),
        ],
      ),
    );
  }

  Widget _flexHdr(String text,
      {AlignmentGeometry alignment = Alignment.center, EdgeInsets? padding}) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      alignment: alignment,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  TableRow _flexLeaderRow(AdminLeaderboardRow p) {
    final posColor = switch (p.position) {
      1 => const Color(0xFFFACC15),
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFF97316),
      _ => const Color(0xFF52525B),
    };
    Widget cell(Widget child,
        {EdgeInsets? padding,
        AlignmentGeometry alignment = Alignment.center}) {
      return Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        alignment: alignment,
        child: child,
      );
    }

    const numStyle = TextStyle(
        color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600);
    final avg = p.avgPoints?.toStringAsFixed(2) ?? '—';

    return TableRow(children: [
      cell(
        Text('${p.position}',
            style: TextStyle(
                color: posColor,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        padding: const EdgeInsets.fromLTRB(2, 10, 6, 10),
        alignment: Alignment.centerLeft,
      ),
      cell(
        _AdminLeaderAvatar(url: p.avatarUrl, name: p.name, size: 24),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      cell(
        Text(p.name,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        alignment: Alignment.centerLeft,
      ),
      cell(Text('${p.matchesPlayed ?? 0}', style: numStyle)),
      cell(Text('${p.byeCount ?? 0}',
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500))),
      cell(Text(avg, style: numStyle)),
      cell(
        Text('${p.totalPoints}',
            style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        padding: const EdgeInsets.fromLTRB(6, 10, 4, 10),
        alignment: Alignment.centerRight,
      ),
    ]);
  }

  Widget _buildLeaderboard(List<AdminLeaderboardRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(), // #
          1: IntrinsicColumnWidth(), // avatar
          2: FlexColumnWidth(),      // name (растягивается, переносится)
          3: IntrinsicColumnWidth(), // В
          4: IntrinsicColumnWidth(), // П
          5: IntrinsicColumnWidth(), // Р (forA:against)
          6: IntrinsicColumnWidth(), // %
          7: IntrinsicColumnWidth(), // Очки
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _leaderboardHeaderRow(),
          for (final p in rows) _leaderboardRow(p),
        ],
      ),
    );
  }

  TableRow _leaderboardHeaderRow() {
    const hdrStyle = TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );
    Widget hdr(String text,
        {AlignmentGeometry alignment = Alignment.center,
        EdgeInsets? padding}) {
      return Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        alignment: alignment,
        child: Text(
          text,
          style: hdrStyle,
          textAlign: alignment == Alignment.centerLeft
              ? TextAlign.left
              : (alignment == Alignment.centerRight
                  ? TextAlign.right
                  : TextAlign.center),
        ),
      );
    }

    return TableRow(
      children: [
        hdr('#',
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(2, 8, 6, 8)),
        const SizedBox(),
        hdr('ИГРОК',
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8)),
        hdr('В'),
        hdr('П'),
        hdr('Р'),
        hdr('%'),
        hdr('ОЧКИ',
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(6, 8, 4, 8)),
      ],
    );
  }

  TableRow _leaderboardRow(AdminLeaderboardRow p) {
    final posColor = switch (p.position) {
      1 => const Color(0xFFFACC15),
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFF97316),
      _ => const Color(0xFF52525B),
    };

    Widget cell(Widget child,
        {EdgeInsets? padding,
        AlignmentGeometry alignment = Alignment.center}) {
      return Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        alignment: alignment,
        child: child,
      );
    }

    return TableRow(
      children: [
        cell(
          Text('${p.position}',
              style: TextStyle(
                  color: posColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          padding: const EdgeInsets.fromLTRB(2, 10, 6, 10),
          alignment: Alignment.centerLeft,
        ),
        cell(
          _AdminLeaderAvatar(url: p.avatarUrl, name: p.name, size: 24),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        cell(
          Text(p.name,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2)),
          padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
          alignment: Alignment.centerLeft,
        ),
        cell(Text('${p.wins}',
            style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 12,
                fontWeight: FontWeight.w700))),
        cell(Text('${p.losses}',
            style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w700))),
        cell(Text('${p.pointsFor}:${p.pointsAgainst}',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11))),
        cell(Text('${p.winPercent}%',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600))),
        cell(
          Text('${p.totalPoints}',
              style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
          padding: const EdgeInsets.fromLTRB(6, 10, 4, 10),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }

  // Таблица Round Robin — колонки как в вебе: # · Игрок · В · П · З · ПР · ±
  // (З = выигранные геймы, ПР = пропущенные, ± = разница). Без % и «Очков».
  // Дизайн (карточка, аватар, цвета мест) — как у обычной таблицы.
  Widget _buildRoundRobinLeaderboard(List<AdminLeaderboardRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(), // #
          1: IntrinsicColumnWidth(), // avatar
          2: FlexColumnWidth(),      // name
          3: IntrinsicColumnWidth(), // В
          4: IntrinsicColumnWidth(), // П
          5: IntrinsicColumnWidth(), // З
          6: IntrinsicColumnWidth(), // ПР
          7: IntrinsicColumnWidth(), // ±
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _roundRobinHeaderRow(),
          for (final p in rows) _roundRobinRow(p),
        ],
      ),
    );
  }

  TableRow _roundRobinHeaderRow() {
    const hdrStyle = TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );
    Widget hdr(String text,
        {AlignmentGeometry alignment = Alignment.center,
        EdgeInsets? padding}) {
      return Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        alignment: alignment,
        child: Text(text,
            style: hdrStyle,
            textAlign: alignment == Alignment.centerLeft
                ? TextAlign.left
                : (alignment == Alignment.centerRight
                    ? TextAlign.right
                    : TextAlign.center)),
      );
    }

    return TableRow(
      children: [
        hdr('#',
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(2, 8, 6, 8)),
        const SizedBox(),
        hdr('ИГРОК',
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8)),
        hdr('В'),
        hdr('П'),
        hdr('З'),
        hdr('ПР'),
        hdr('±',
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(6, 8, 4, 8)),
      ],
    );
  }

  TableRow _roundRobinRow(AdminLeaderboardRow p) {
    final posColor = switch (p.position) {
      1 => const Color(0xFFFACC15),
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFF97316),
      _ => const Color(0xFF52525B),
    };

    Widget cell(Widget child,
        {EdgeInsets? padding,
        AlignmentGeometry alignment = Alignment.center}) {
      return Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        alignment: alignment,
        child: child,
      );
    }

    final diff = p.pointDiff;
    final diffText = diff > 0 ? '+$diff' : '$diff';
    final diffColor = diff > 0
        ? const Color(0xFF22C55E)
        : (diff < 0 ? const Color(0xFFEF4444) : AppTheme.textSecondary);

    const statSecondary = TextStyle(
        color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600);

    return TableRow(
      children: [
        cell(
          Text('${p.position}',
              style: TextStyle(
                  color: posColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          padding: const EdgeInsets.fromLTRB(2, 10, 6, 10),
          alignment: Alignment.centerLeft,
        ),
        cell(
          _AdminLeaderAvatar(url: p.avatarUrl, name: p.name, size: 24),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        cell(
          Text(p.name,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2)),
          padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
          alignment: Alignment.centerLeft,
        ),
        cell(Text('${p.wins}',
            style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 13,
                fontWeight: FontWeight.w800))),
        cell(Text('${p.losses}',
            style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w700))),
        cell(Text('${p.pointsFor}', style: statSecondary)),
        cell(Text('${p.pointsAgainst}', style: statSecondary)),
        cell(
          Text(diffText,
              style: TextStyle(
                  color: diffColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
          padding: const EdgeInsets.fromLTRB(6, 10, 4, 10),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }

  Widget _buildRoundBlock(AdminMatchRound round) {
    // Round Robin, Americano Flex, Король корта и Bali — раундов много,
    // сворачиваем завершённые, чтобы не листать «газету». Активный («идёт»)
    // раскрыт по умолчанию; при генерации нового раунда предыдущий сам
    // свернётся (стал completed). Остальные типы — всегда раскрыты.
    final collapsible = _matches?.type == 'round_robin'
        || _matches?.type == 'americano_flex'
        || _matches?.type == 'king_of_court'
        || _matches?.type == 'bali_koc';
    final expanded = !collapsible
        ? true
        : (_rrRoundExpanded[round.id] ?? (round.status == 'in_progress'));

    final header = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('Раунд ${round.roundNumber}',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          _roundStatusBadge(round.status),
          if (collapsible) ...[
            const Spacer(),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          collapsible
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(
                      () => _rrRoundExpanded[round.id] = !expanded),
                  child: header,
                )
              : header,
          if (expanded) ...[
            ...round.matches.map((m) => _buildMatchTile(m)),
            if (round.byes.isNotEmpty) _buildByesBlock(round.byes),
          ],
        ],
      ),
    );
  }

  Widget _buildByesBlock(List<AdminMatchPlayer> byes) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        border: Border.all(color: Colors.amber.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nights_stay_outlined,
                  size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'Отдыхают в этом раунде',
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: byes
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        p.name,
                        style: TextStyle(
                          color: Colors.amber.shade100,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _roundStatusBadge(String status) {
    final (label, color) = switch (status) {
      'completed' => ('завершён', AppTheme.accent),
      'in_progress' => ('идёт', AppTheme.blue),
      _ => ('ожидание', AppTheme.textDim),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMatchTile(AdminMatch m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => _openScoreSheet(match: m),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.cardRaised,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (m.courtNumber != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Корт ${m.courtNumber}',
                      style: const TextStyle(
                          color: AppTheme.textDim, fontSize: 11)),
                ),
              _matchTeamRow(m.team1, isWinner: m.winner == 1, isCompleted: m.isCompleted),
              const SizedBox(height: 4),
              _matchTeamRow(m.team2, isWinner: m.winner == 2, isCompleted: m.isCompleted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _matchTeamRow(AdminMatchTeam team,
      {required bool isWinner, required bool isCompleted}) {
    return Row(
      children: [
        Expanded(
          child: Text(team.title,
              style: TextStyle(
                  color: isWinner
                      ? AppTheme.accent
                      : AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight:
                      isWinner ? FontWeight.w700 : FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36,
          padding: const EdgeInsets.symmetric(vertical: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isWinner
                ? AppTheme.accent.withOpacity(0.15)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isCompleted && team.score != null ? '${team.score}' : '—',
            style: TextStyle(
                color: isWinner
                    ? AppTheme.accent
                    : AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayoffSection(AdminPlayoff p) {
    final upper =
        p.matches.where((m) => !m.stage.contains('нижняя сетка')).toList();
    final lower =
        p.matches.where((m) => m.stage.contains('нижняя сетка')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: const [
            Icon(Icons.emoji_events_outlined,
                color: AppTheme.amber, size: 18),
            SizedBox(width: 8),
            Text('Плей-офф',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        if (upper.isNotEmpty) _buildAdminBracket(upper, isLower: false),
        if (lower.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildAdminBracket(lower, isLower: true),
        ],
      ],
    );
  }

  Widget _buildAdminBracket(List<AdminPlayoffMatch> matches,
      {required bool isLower}) {
    String baseStage(String s) =>
        s.replaceAll(' (нижняя сетка)', '').trim();
    int rank(String s) {
      final b = baseStage(s);
      if (b == 'Полуфинал') return 1;
      if (b == 'Финал') return 2;
      return 3;
    }

    final byStage = <String, List<AdminPlayoffMatch>>{};
    for (final m in matches) {
      byStage.putIfAbsent(baseStage(m.stage), () => []).add(m);
    }
    final stageKeys = byStage.keys.toList()
      ..sort((a, b) => rank(a).compareTo(rank(b)));

    final total = matches.length;
    final played = matches.where((m) => m.isCompleted).length;
    final title = isLower ? 'Нижняя сетка' : 'Основная сетка';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.amber.withAlpha(36),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.emoji_events_rounded,
                    color: AppTheme.amber, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ),
              Text('$played / $total',
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          for (final k in stageKeys)
            _buildAdminStageBlock(k, byStage[k]!, isLower: isLower),
        ],
      ),
    );
  }

  Widget _buildAdminStageBlock(String base, List<AdminPlayoffMatch> matches,
      {required bool isLower}) {
    String label;
    String? sub;
    if (base == 'Полуфинал') {
      label = 'ПОЛУФИНАЛ';
    } else if (base == 'Финал') {
      label = 'ФИНАЛ';
      sub = isLower ? null : 'за 1–2 место';
    } else {
      label = 'МАТЧ ЗА 3 МЕСТО';
      sub = isLower ? null : 'за 3 место';
    }

    final allDone =
        matches.isNotEmpty && matches.every((m) => m.isCompleted);
    final Color dotColor =
        allDone ? AppTheme.accent : const Color(0xFF3F3F46);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              if (sub != null) ...[
                const SizedBox(width: 6),
                Text('· $sub',
                    style: const TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
        for (final m in matches) _buildAdminPlayoffMatchCard(m),
      ],
    );
  }

  Widget _buildAdminPlayoffMatchCard(AdminPlayoffMatch m) {
    final completed = m.isCompleted;
    final hasPlayers =
        m.team1.players.isNotEmpty && m.team2.players.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: hasPlayers ? () => _openScoreSheet(playoffMatch: m) : null,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                child: Row(
                  children: [
                    if (m.courtNumber != null)
                      Text('Корт ${m.courtNumber}',
                          style: const TextStyle(
                              color: AppTheme.textDim,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (completed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_rounded,
                              color: AppTheme.accent, size: 14),
                          SizedBox(width: 3),
                          Text('Завершён',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                  ],
                ),
              ),
              _adminPlayoffTeamRow(m.team1,
                  isWinner: m.winner == 1, completed: completed),
              _adminPlayoffTeamRow(m.team2,
                  isWinner: m.winner == 2, completed: completed),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminPlayoffTeamRow(AdminMatchTeam team,
      {required bool isWinner, required bool completed}) {
    final isLoser = completed && !isWinner;
    final noTeam = team.players.isEmpty;
    final names = noTeam ? 'Ожидание…' : team.title;

    Color nameColor =
        isLoser ? AppTheme.textSecondary : AppTheme.textPrimary;
    if (noTeam) nameColor = AppTheme.textDim;
    final nameWeight = isWinner ? FontWeight.w800 : FontWeight.w600;

    final hasScore = team.score != null;
    Color bg;
    Color fg;
    Border border;
    String text = hasScore ? '${team.score}' : '—';
    if (completed && isWinner) {
      bg = AppTheme.accent.withAlpha(40);
      fg = AppTheme.accent;
      border = Border.all(color: AppTheme.accent.withAlpha(130));
    } else if (completed) {
      bg = Colors.transparent;
      fg = AppTheme.textSecondary;
      border = Border.all(color: const Color(0xFF3F3F46));
    } else {
      bg = Colors.transparent;
      fg = AppTheme.textDim;
      border = Border.all(color: const Color(0xFF3F3F46));
      text = '—';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        children: [
          if (isWinner)
            Container(
              width: 3,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(width: 11),
          Expanded(
            child: Text(
              names,
              style: TextStyle(
                  color: nameColor, fontSize: 14, fontWeight: nameWeight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 46,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(text,
                style: TextStyle(
                    color: fg, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // -------------------- Bottom sheet ввода счёта --------------------

  Future<void> _openScoreSheet({
    AdminMatch? match,
    AdminPlayoffMatch? playoffMatch,
  }) async {
    if (_actionBusy) return;

    final isPlayoff = playoffMatch != null;
    final m = match;
    final pm = playoffMatch;

    final isKoc = _matches?.type == 'king_of_court';
    final isBali = _matches?.type == 'bali_koc';
    final isTeam = _matches?.type == 'team';
    final isFlex = _matches?.type == 'americano_flex';
    final isRoundRobin = _matches?.type == 'round_robin';

    final team1Title = isPlayoff ? pm!.team1.title : m!.team1.title;
    final team2Title = isPlayoff ? pm!.team2.title : m!.team2.title;
    final initial1 = isPlayoff ? pm!.team1.score : m!.team1.score;
    final initial2 = isPlayoff ? pm!.team2.score : m!.team2.score;
    final isUpdate = isPlayoff ? pm!.isCompleted : m!.isCompleted;
    final headline = isPlayoff
        ? pm!.stage
        : 'Раунд ${_findRoundNumberForMatch(m!.id)}, ${m.courtNumber != null ? "Корт ${m.courtNumber}" : "матч #${m.id}"}';

    final result = await showModalBottomSheet<_ScoreInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ScoreSheet(
        headline: headline,
        team1Title: team1Title,
        team2Title: team2Title,
        initialScore1: initial1,
        initialScore2: initial2,
        // У плей-офф, KOC, Bali и Round Robin ничья запрещена. У team — в плей-офф
        // нельзя, в групповом этапе можно (ничья считается как одинаковые геймы).
        requireDifferent: isPlayoff || isKoc || isBali || isRoundRobin,
      ),
    );

    if (result == null) return;

    final tournamentId = widget.tournamentId;
    final matchId = isPlayoff ? pm!.id : m!.id;

    setState(() {
      _actionBusy = true;
      _actionLabel = 'Сохраняем счёт...';
    });
    try {
      if (isTeam) {
        if (isPlayoff) {
          await context.read<AdminService>().saveTeamPlayoffScore(
                tournamentId,
                matchId,
                team1Score: result.score1,
                team2Score: result.score2,
                isUpdate: isUpdate,
              );
        } else {
          await context.read<AdminService>().saveTeamGroupScore(
                tournamentId,
                matchId,
                team1Score: result.score1,
                team2Score: result.score2,
                isUpdate: isUpdate,
              );
        }
      } else if (isPlayoff) {
        await context.read<AdminService>().saveAmericanoPlayoffScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
              isUpdate: isUpdate,
            );
      } else if (isKoc) {
        await context.read<AdminService>().saveKocScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
            );
      } else if (isBali) {
        await context.read<AdminService>().saveBaliKocScore(
              tournamentId,
              matchId,
              pair1Games: result.score1,
              pair2Games: result.score2,
            );
      } else if (isFlex) {
        await context.read<AdminService>().saveAmericanoFlexScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
            );
      } else if (isRoundRobin) {
        await context.read<AdminService>().saveRoundRobinScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
            );
      } else {
        await context.read<AdminService>().saveAmericanoScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
              isUpdate: isUpdate,
            );
      }
      await _loadMatches();
      // обновим инфо-таб тоже (counts могут поменяться)
      try {
        final t = await context
            .read<AdminService>()
            .getTournamentDetail(tournamentId);
        if (mounted) setState(() => _t = t);
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionBusy = false;
          _actionLabel = null;
        });
      }
    }
  }

  int _findRoundNumberForMatch(int matchId) {
    final r = _matches;
    if (r == null) return 0;
    for (final g in r.groups) {
      for (final round in g.rounds) {
        if (round.matches.any((m) => m.id == matchId)) {
          return round.roundNumber;
        }
      }
    }
    return 0;
  }
}

// =============================================================================
// Bottom-sheet ввода счёта
// =============================================================================

class _ScoreInput {
  final int score1;
  final int score2;
  const _ScoreInput(this.score1, this.score2);
}

class _ScoreSheet extends StatefulWidget {
  final String headline;
  final String team1Title;
  final String team2Title;
  final int? initialScore1;
  final int? initialScore2;
  final bool requireDifferent;

  const _ScoreSheet({
    required this.headline,
    required this.team1Title,
    required this.team2Title,
    required this.initialScore1,
    required this.initialScore2,
    required this.requireDifferent,
  });

  @override
  State<_ScoreSheet> createState() => _ScoreSheetState();
}

class _ScoreSheetState extends State<_ScoreSheet> {
  late final TextEditingController _c1;
  late final TextEditingController _c2;
  String? _error;

  @override
  void initState() {
    super.initState();
    _c1 = TextEditingController(
        text: widget.initialScore1?.toString() ?? '');
    _c2 = TextEditingController(
        text: widget.initialScore2?.toString() ?? '');
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  void _submit() {
    final s1 = int.tryParse(_c1.text.trim());
    final s2 = int.tryParse(_c2.text.trim());
    if (s1 == null || s2 == null) {
      setState(() => _error = 'Введите оба счёта целыми числами');
      return;
    }
    if (s1 < 0 || s1 > 99 || s2 < 0 || s2 > 99) {
      setState(() => _error = 'Счёт должен быть от 0 до 99');
      return;
    }
    if (widget.requireDifferent && s1 == s2) {
      setState(() => _error = 'В плей-офф не может быть ничьей');
      return;
    }
    Navigator.of(context).pop(_ScoreInput(s1, s2));
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
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
              const SizedBox(height: 12),
              Center(
                child: Text(widget.headline,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Введите счёт',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              _scoreRow(widget.team1Title, _c1),
              const SizedBox(height: 10),
              _scoreRow(widget.team2Title, _c2),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: AppTheme.error, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppTheme.cardRaised),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Отмена',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Сохранить',
                          style:
                              TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(String title, TextEditingController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: TextField(
              controller: c,
              autofocus: c.text.isEmpty,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardRaised,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Bottom-sheet с поиском игроков
// =============================================================================

class _PlayerSearchSheet extends StatefulWidget {
  final String title;
  final int tournamentId;

  const _PlayerSearchSheet({
    required this.title,
    required this.tournamentId,
  });

  @override
  State<_PlayerSearchSheet> createState() => _PlayerSearchSheetState();
}

class _PlayerSearchSheetState extends State<_PlayerSearchSheet> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  List<AdminParticipant> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context
          .read<AdminService>()
          .searchPlayers(widget.tournamentId, q);
      if (!mounted) return;
      setState(() {
        _results = list;
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
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardRaised,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: 'Телефон или имя (от 2 символов)',
                  hintStyle: const TextStyle(color: AppTheme.textDim),
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
            child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_error!,
            style: const TextStyle(color: AppTheme.error)),
      );
    }
    if (_ctrl.text.trim().length < 2) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Введите имя или телефон для поиска',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ),
      );
    }
    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Никого не нашли',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final p = _results[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(p),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.cardRaised,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initialsOf(p.name),
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text(
                        [
                          if (p.level != null) 'L${p.level!.toStringAsFixed(2)}',
                          if (p.rating != null) '${p.rating}',
                          if ((p.phone ?? '').isNotEmpty) p.phone!,
                        ].join(' · '),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline,
                    color: AppTheme.accent, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}

// =============================================================================
// Маленький аватар с инициалами для строки таблицы лидеров
// =============================================================================

class _AdminLeaderAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  const _AdminLeaderAvatar({
    required this.url,
    required this.name,
    this.size = 24,
  });

  String get _initials {
    final cleaned =
        name.replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '');
    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
