import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';
import '../tournament_types_info_screen.dart';
import 'admin_tournament_detail_screen.dart';

/// Этап 4 — создание турнира. На этом этапе поддерживается только
/// Король корта. Когда понадобятся другие типы — добавляем визуальный
/// выбор типа и расширяем форму.
class AdminCreateTournamentScreen extends StatefulWidget {
  final int? clubId; // null = личный (приватный) турнир обычного игрока
  final String clubName;

  const AdminCreateTournamentScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<AdminCreateTournamentScreen> createState() =>
      _AdminCreateTournamentScreenState();
}

class _AdminCreateTournamentScreenState
    extends State<AdminCreateTournamentScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _prizes = TextEditingController();
  bool _hasPrizes = false;
  final _telegramUrl = TextEditingController();
  final _maxParticipants = TextEditingController(text: '16');
  final _price = TextEditingController();
  final _reserveCount = TextEditingController(text: '0');
  final _waitlistSize = TextEditingController(text: '0');
  final _moderationHours = TextEditingController();
  final _moderationMinutes = TextEditingController();
  final _roundsCount = TextEditingController(text: '7');
  // Кол-во кортов вручную для Americano Flex (пусто = авто floor(игроки/4)).
  final _flexCourts = TextEditingController();
  // Кол-во кортов вручную для Team (Групповой + плей-офф); пусто = авто ceil(игроки/4).
  final _teamCourts = TextEditingController();
  // Парный Americano Flex (фиксированные пары, собирает админ).
  bool _flexIsPaired = false;

  String _type = 'americano'; // americano / king_of_court / round_robin / bali_koc / team / americano_flex / just_padel_it
  DateTime? _startDate;
  double _minLevel = 1.5;
  double _maxLevel = 4.0;
  String _status = 'open'; // draft / open
  int? _durationHours; // длительность турнира в часах (необязательно)
  bool _isRated = true; // рейтинговый ли турнир (влияет на рейтинг игроков)
  bool _verifiedOnly = false; // только для верифицированных игроков
  bool _chatEnabled = true; // включён ли чат турнира
  String _chatWriteMode = 'participants'; // admin | participants | everyone

  // Клуб-площадка (необязательно) — где физически играют, отдельно от
  // организующего клуба (widget.clubId).
  int? _venueClubId;
  String? _venueClubName;

  // Какие секции-аккордеоны раскрыты. По умолчанию открыта только «Основное».
  final Set<String> _openSections = {'basic'};

  // Поле Американо
  int _groupsCount = 1;
  bool _hasPlayoff = false;
  bool _jpiRankByWins = false;
  String _playoffType = 'final_only'; // final_only / semifinal_final
  String _playoffFormat = 'cross';
  bool _hasLowerBracket = false;
  bool _hasBronzeMatch = false;

  // Поля Team (Групповой + Плей-офф) — отдельный state, чтобы не путать с
  // Американо. По умолчанию 2 группы, выходят 2 пары.
  int _teamGroupsCount = 2;
  int _teamsAdvance = 2;
  bool _teamHasPlayoff = true; // по умолчанию с плей-офф (как было)
  bool _teamHasLowerBracket = false;
  bool _teamHasBronzeMatch = false;
  // self — пары регистрируются сами; admin — игроки записываются по одному,
  // пары собирает админ перед стартом.
  String _pairingMode = 'self';

  // Корты — кол-во вычисляется как ceil(max_participants / 4) (как в Web)
  late final List<TextEditingController> _courtNames =
      List.generate(32, (i) => TextEditingController(text: 'Корт ${i + 1}'));

  bool _saving = false;
  String? _saveLabel;

  // Максимум кортов для Flex — по числу игроков (каждому корту нужно 4).
  int get _flexMaxCourts {
    final maxP = int.tryParse(_maxParticipants.text.trim()) ?? 16;
    return (maxP / 4).floor().clamp(1, 32);
  }

  int get _courtsCount {
    if (_type == 'americano_flex') {
      // Flex: ручной ввод, иначе авто floor(игроки/4). Корт = 4 игрока.
      final manual = int.tryParse(_flexCourts.text.trim());
      if (manual != null && manual >= 1) return manual.clamp(1, _flexMaxCourts);
      return _flexMaxCourts;
    }
    final maxP = int.tryParse(_maxParticipants.text.trim()) ?? 16;
    if (_type == 'team') {
      // Ручной ввод кортов; пусто = авто ceil(игроки/4).
      final manual = int.tryParse(_teamCourts.text.trim());
      if (manual != null && manual >= 1) return manual.clamp(1, 32);
    }
    final n = (maxP / 4).ceil();
    return n.clamp(1, 32);
  }

  @override
  void initState() {
    super.initState();
    _maxParticipants.addListener(_onMaxOrGroupsChanged);
    _flexCourts.addListener(() {
      if (mounted) setState(() {}); // пересчитать поля кортов
    });
    _teamCourts.addListener(() {
      if (mounted) setState(() {}); // пересчитать поля кортов
    });
    _updateRoundsCount();
  }

  void _onMaxOrGroupsChanged() {
    _updateRoundsCount();
    if (mounted) setState(() {}); // пересчитать кол-во кортов
  }

  void _updateRoundsCount() {
    if (_type == 'mexicano') {
      if (_roundsCount.text.trim().isEmpty) _roundsCount.text = '7';
      return;
    }
    if (_type != 'americano') return;
    final maxP = int.tryParse(_maxParticipants.text.trim()) ?? 0;
    if (maxP <= 0 || _groupsCount <= 0) return;
    final perGroup = (maxP / _groupsCount).floor();
    final rounds = (perGroup - 1).clamp(1, 30);
    _roundsCount.text = '$rounds';
  }

  @override
  void dispose() {
    _maxParticipants.removeListener(_onMaxOrGroupsChanged);
    _name.dispose();
    _description.dispose();
    _prizes.dispose();
    _telegramUrl.dispose();
    _maxParticipants.dispose();
    _price.dispose();
    _reserveCount.dispose();
    _waitlistSize.dispose();
    _moderationHours.dispose();
    _moderationMinutes.dispose();
    _roundsCount.dispose();
    _flexCourts.dispose();
    _teamCourts.dispose();
    for (final c in _courtNames) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _ensureOpen('basic');
      await showAppAlert(context, 'Укажите название турнира',
          title: 'Ошибка', isError: true);
      return;
    }
    if (_startDate == null) {
      await showAppAlert(context, 'Выберите дату и время старта',
          title: 'Ошибка', isError: true);
      return;
    }
    if (!_startDate!.isAfter(DateTime.now())) {
      _ensureOpen('basic');
      await showAppAlert(context, 'Дата старта должна быть в будущем',
          title: 'Ошибка', isError: true);
      return;
    }
    if (_minLevel > _maxLevel) {
      _ensureOpen('players');
      await showAppAlert(context, 'Минимальный уровень больше максимального',
          title: 'Ошибка', isError: true);
      return;
    }
    final maxP = int.tryParse(_maxParticipants.text.trim());
    if (maxP == null || maxP < 2 || maxP > 128) {
      _ensureOpen('players');
      await showAppAlert(
        context,
        'Макс. участников: целое число от 2 до 128',
        title: 'Ошибка',
        isError: true,
      );
      return;
    }
    final priceText = _price.text.trim();
    final price = priceText.isEmpty ? null : double.tryParse(priceText);
    if (priceText.isNotEmpty && price == null) {
      _ensureOpen('basic');
      await showAppAlert(context, 'Цена должна быть числом',
          title: 'Ошибка', isError: true);
      return;
    }
    final reserve = int.tryParse(_reserveCount.text.trim()) ?? 0;
    if (reserve < 0 || reserve > 10) {
      _ensureOpen('players');
      await showAppAlert(context, 'Резервных игроков: 0–10',
          title: 'Ошибка', isError: true);
      return;
    }
    final waitlistSize = int.tryParse(_waitlistSize.text.trim()) ?? 0;
    if (waitlistSize < 0 || waitlistSize > 32) {
      _ensureOpen('players');
      await showAppAlert(context, 'Лист ожидания: 0–32',
          title: 'Ошибка', isError: true);
      return;
    }

    final courts = List<String?>.generate(_courtsCount, (i) {
      final t = _courtNames[i].text.trim();
      return t.isEmpty ? null : t;
    });

    final tgUrl = _telegramUrl.text.trim();
    if (tgUrl.isNotEmpty) {
      final ok = Uri.tryParse(tgUrl)?.hasScheme ?? false;
      if (!ok || !(tgUrl.startsWith('http://') || tgUrl.startsWith('https://'))) {
        _ensureOpen('registration');
        await showAppAlert(context,
            'Ссылка на Telegram-чат должна начинаться с http:// или https://',
            title: 'Ошибка', isError: true);
        return;
      }
    }

    final body = <String, dynamic>{
      'type': _type,
      'name': name,
      'description':
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      'has_prizes': _hasPrizes,
      if (_hasPrizes && _prizes.text.trim().isNotEmpty)
        'prizes': _prizes.text.trim(),
      'telegram_registration_url': tgUrl.isEmpty ? null : tgUrl,
      'start_date': _startDate!.toIso8601String(),
      if (_durationHours != null) 'duration_hours': _durationHours,
      'min_level': _minLevel,
      'max_level': _maxLevel,
      'max_participants': maxP,
      'price': price,
      'status': _status,
      'is_rated': _isRated,
      'verified_only': _verifiedOnly,
      'chat_enabled': _chatEnabled,
      'chat_write_mode': _chatWriteMode,
      'courts': courts,
      'courts_count': _courtsCount,
      'reserve_count': reserve,
      'waitlist_size': waitlistSize,
      if (_venueClubId != null) 'venue_club_id': _venueClubId,
    };

    if (_type == 'americano') {
      body['groups_count'] = _groupsCount;
      final rounds = int.tryParse(_roundsCount.text.trim()) ?? 0;
      if (rounds < 1 || rounds > 30) {
        _ensureOpen('format');
        await showAppAlert(context,
            'Количество раундов: целое число от 1 до 30',
            title: 'Ошибка', isError: true);
        return;
      }
      body['rounds_count'] = rounds;
      body['has_playoff'] = _hasPlayoff;
      if (_hasPlayoff) {
        body['playoff_type'] = _playoffType;
        // Формат нужен: при 1 группе (и final_only, и semifinal_final),
        // либо при ≥2 групп и semifinal_final
        final needFormat =
            (_groupsCount == 1) ||
                (_groupsCount >= 2 && _playoffType == 'semifinal_final');
        if (needFormat) body['playoff_format'] = _playoffFormat;
        body['has_lower_bracket'] = _hasLowerBracket;
        body['has_bronze_match'] = _hasBronzeMatch;
      }
    }

    if (_type == 'mexicano') {
      final rounds = int.tryParse(_roundsCount.text.trim()) ?? 0;
      if (rounds < 1 || rounds > 30) {
        _ensureOpen('format');
        await showAppAlert(context,
            'Количество раундов: целое число от 1 до 30',
            title: 'Ошибка', isError: true);
        return;
      }
      body['rounds_count'] = rounds;
      body['has_playoff'] = _hasPlayoff;
    }

    if (_type == 'team') {
      body['groups_count'] = _teamGroupsCount;
      body['teams_advance'] = _teamsAdvance;
      body['pairing_mode'] = _pairingMode;
      body['has_playoff'] = _teamHasPlayoff;
      // Нижняя сетка / бронза — только при включённом плей-офф.
      body['has_lower_bracket'] = _teamHasPlayoff && _teamHasLowerBracket;
      body['has_bronze_match'] = _teamHasPlayoff && _teamHasBronzeMatch;
    }

    if (_type == 'americano_flex' && _flexIsPaired) {
      // Парный флекс: число игроков должно быть чётным (пары закреплены).
      if (maxP % 2 != 0) {
        await showAppAlert(context,
            'Для парного турнира число игроков должно быть чётным',
            title: 'Ошибка', isError: true);
        return;
      }
      body['is_paired'] = true;
    }

    if (_type == 'king_of_court' && _flexIsPaired) {
      // Король корта с фиксированными парами: пары админ создаёт после набора.
      body['is_paired'] = true;
    }

    if (_type == 'just_padel_it' && _flexIsPaired) {
      // Just Padel It с фиксированными парами: пары создаются на этапе проведения.
      body['is_paired'] = true;
    }

    if (_type == 'just_padel_it') {
      body['jpi_rank_by_wins'] = _jpiRankByWins;
    }

    setState(() {
      _saving = true;
      _saveLabel = 'Создаём турнир...';
    });

    try {
      final admin = context.read<AdminService>();
      final modHours = int.tryParse(_moderationHours.text.trim());
      final modMinutes = int.tryParse(_moderationMinutes.text.trim());
      final id = widget.clubId == null
          ? await admin.createPersonalTournament(
              body,
              moderationHours: modHours,
              moderationMinutes: modMinutes,
            )
          : await admin.createTournament(
              widget.clubId!,
              body,
              moderationHours: modHours,
              moderationMinutes: modMinutes,
            );
      if (!mounted) return;
      // Сразу открываем экран управления нового турнира
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AdminTournamentDetailScreen(
            tournamentId: id,
            tournamentName: name,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveLabel = null;
      });
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  /// Описание парного Americano Flex (по тапу на «?»).
  void _showPairedInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Парный Americano Flex',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                'Пары фиксированные — партнёр не меняется весь турнир. '
                'Меняются только соперники и отдых.\n\n'
                '• Игроки записываются по одному, пары собирает админ перед стартом.\n'
                '• Число игроков — чётное (пары закреплены).\n'
                '• Каждый раунд часть пар играет, остальные отдыхают по очереди — '
                'никто не сидит на лавке дольше других.\n'
                '• Пары встречаются с разными соперниками без лишних повторов.\n\n'
                'Пример: 10 игроков (5 пар) на 2 кортах → 2 пары играют, 1 отдыхает. '
                'Итог — по среднему за матч у пары.',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
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
                Expanded(child: _buildForm()),
              ],
            ),
          ),
          if (_saving) _buildBusyOverlay(),
        ],
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
                Text(
                  'Создать турнир',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.clubName,
                  style: TextStyle(
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

  Widget _buildForm() {
    final createLabel =
        _status == 'open' ? 'Создать и открыть запись' : 'Создать черновик';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _label('Формат турнира'),
        _typeSelector(),
        const SizedBox(height: 10),
        _aboutFormatButton(),
        const SizedBox(height: 12),
        _collapsibleSection(
          sectionKey: 'basic',
          icon: Icons.description_outlined,
          title: 'Основное',
          summary: _basicSummary,
          children: [
            _label('Название'),
            _textField(_name, hint: 'Например: Турнир выходного дня'),
            const SizedBox(height: 12),
            _label('Описание'),
            _textField(_description,
                hint: 'Можно оставить пустым', maxLines: 3),
            const SizedBox(height: 12),
            _checkboxTile(
              value: _hasPrizes,
              label: 'Призовой турнир',
              onChanged: (v) => setState(() => _hasPrizes = v),
            ),
            if (_hasPrizes) ...[
              const SizedBox(height: 8),
              _label('Призы'),
              _textField(_prizes,
                  hint: 'Например: 1 место — …, 2 место — …', maxLines: 3),
            ],
            const SizedBox(height: 12),
            _label('Дата и время старта'),
            _dateField(),
            const SizedBox(height: 12),
            _label('Длительность (необязательно)'),
            _durationSelector(),
            const SizedBox(height: 12),
            _label('Цена за участие, ₸'),
            _textField(
              _price,
              hint: '0',
              keyboardType: const TextInputType.numberWithOptions(),
            ),
            const SizedBox(height: 12),
            _label('Клуб (площадка)'),
            _venueClubField(),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Необязательно. Где физически играют — увидят записавшиеся.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
            ),
            if (_type == 'americano_flex' ||
                _type == 'king_of_court' ||
                _type == 'just_padel_it') ...[
              const SizedBox(height: 12),
              _pairedToggle(),
            ],
            if (_type == 'just_padel_it') ...[
              const SizedBox(height: 12),
              _scoreTypeControl(),
              const SizedBox(height: 12),
              _jpiRankControl(),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _collapsibleSection(
          sectionKey: 'players',
          icon: Icons.groups_outlined,
          title: 'Игроки и уровень',
          summary: _playersSummary,
          children: [
            // Личные турниры всегда нерейтинговые — свитч не показываем.
            if (widget.clubId != null) ...[
              _ratingToggle(),
              const SizedBox(height: 12),
            ],
            _verifiedToggle(),
            const SizedBox(height: 12),
            _chatSettings(),
            const SizedBox(height: 12),
            _label('Уровень игроков'),
            _levelSliders(),
            const SizedBox(height: 12),
            _label('Макс. участников (2–128)'),
            _textField(
              _maxParticipants,
              hint: '16',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            _label('Резервных игроков (0–10)'),
            _textField(
              _reserveCount,
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            _label(_type == 'team'
                ? 'Лист ожидания, пар (0–32)'
                : 'Лист ожидания, человек (0–32)'),
            _textField(
              _waitlistSize,
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _collapsibleSection(
          sectionKey: 'registration',
          icon: Icons.schedule,
          title: 'Запись и модерация',
          summary: _registrationSummary,
          children: [
            _label('Ссылка на чат в Telegram'),
            _textField(_telegramUrl,
                hint: 'https://t.me/...',
                keyboardType: TextInputType.url),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Если указана — кнопка «Записаться» в карточке турнира будет вести в этот чат вместо записи через приложение.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            _label('Таймер модерации записи'),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    _moderationHours,
                    hint: 'часов',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    _moderationMinutes,
                    hint: 'минут',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Пусто = без таймера. Минуты — для отладки; если заданы, важнее часов.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            _label('Статус при создании'),
            _statusSelector(),
          ],
        ),
        const SizedBox(height: 12),
        _collapsibleSection(
          sectionKey: 'format',
          icon: Icons.tune,
          title: 'Настройки формата',
          summary: _formatSummary,
          children: _formatChildren(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(createLabel,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  // Кнопка «Подробнее об этом формате» — открывает описание выбранного типа.
  Widget _aboutFormatButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TournamentTypesInfoScreen(initialType: _type),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.accent.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withAlpha(70), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppTheme.accent, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Подробнее об этом формате',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector() {
    Widget card({
      required String value,
      required String title,
      required String subtitle,
      required IconData icon,
    }) {
      final active = _type == value;
      return GestureDetector(
        onTap: () {
          setState(() => _type = value);
          _updateRoundsCount();
        },
        child: Container(
          width: 152,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? AppTheme.accent.withOpacity(0.12) : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppTheme.accent : AppTheme.border,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: active ? AppTheme.accent : AppTheme.textSecondary,
                  size: 20),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                    color: active ? AppTheme.accent : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
    }

    // Горизонтальный свайп: видно край следующей карточки — намёк, что листается.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card(
              value: 'americano',
              title: 'Американо',
              subtitle: 'Группы, ротация партнёров',
              icon: Icons.shuffle_rounded,
            ),
            card(
              value: 'mexicano',
              title: 'Мексикано',
              subtitle: 'Пары по очкам, все вместе',
              icon: Icons.trending_up_rounded,
            ),
            card(
              value: 'king_of_court',
              title: 'Король корта',
              subtitle: 'Ротация по кортам',
              icon: Icons.emoji_events_outlined,
            ),
            card(
              value: 'just_padel_it',
              title: 'Just Padel It',
              subtitle: 'Движение по кортам + бонусы',
              icon: Icons.local_fire_department_outlined,
            ),
            card(
              value: 'round_robin',
              title: 'Round Robin',
              subtitle: 'Каждый с каждым, зачёт по победам',
              icon: Icons.sync_alt_rounded,
            ),
            card(
              value: 'bali_koc',
              title: 'Король Корта (Bali)',
              subtitle: 'Фикс. пары, очки от корта',
              icon: Icons.groups_rounded,
            ),
            card(
              value: 'team',
              title: 'Групповой + Плей-офф',
              subtitle: 'Парный, выход в плей-офф',
              icon: Icons.account_tree_outlined,
            ),
            card(
              value: 'americano_flex',
              title: 'Americano Flex',
              subtitle: 'Очередь, любое число игроков',
              icon: Icons.swap_horiz_rounded,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Сворачиваемая секция-аккордеон
  // ---------------------------------------------------------------------------

  Widget _collapsibleSection({
    required String sectionKey,
    required IconData icon,
    required String title,
    required String summary,
    required List<Widget> children,
  }) {
    final open = _openSections.contains(sectionKey);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (open) {
                _openSections.remove(sectionKey);
              } else {
                _openSections.add(sectionKey);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(icon, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        if (!open && summary.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(summary,
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Подписи свёрнутых секций
  // ---------------------------------------------------------------------------

  String get _basicSummary {
    final name = _name.text.trim();
    return [
      name.isEmpty ? 'Без названия' : name,
      _startDate == null ? 'дата не выбрана' : _fmtDateTime(_startDate!),
    ].join(' · ');
  }

  String get _playersSummary {
    final maxP = int.tryParse(_maxParticipants.text.trim()) ?? 16;
    return '$maxP ${_plural(maxP, 'участник', 'участника', 'участников')} · '
        'уровень ${_lvl(_minLevel)}–${_lvl(_maxLevel)}';
  }

  String get _registrationSummary {
    final status = _status == 'open' ? 'Открыта запись' : 'Черновик';
    final where = _telegramUrl.text.trim().isEmpty
        ? 'запись в приложении'
        : 'запись в Telegram';
    return '$status · $where';
  }

  String get _formatSummary {
    if (_type == 'americano') {
      final rounds = int.tryParse(_roundsCount.text.trim()) ?? 0;
      final g =
          '$_groupsCount ${_plural(_groupsCount, 'группа', 'группы', 'групп')}';
      return '$g · $rounds ${_plural(rounds, 'раунд', 'раунда', 'раундов')}';
    }
    if (_type == 'team') {
      final g =
          '$_teamGroupsCount ${_plural(_teamGroupsCount, 'группа', 'группы', 'групп')}';
      return '$g · выходят $_teamsAdvance';
    }
    return '$_courtsCount ${_plural(_courtsCount, 'корт', 'корта', 'кортов')}';
  }

  // ---------------------------------------------------------------------------
  // Контент секции «Настройки формата» — зависит от типа турнира
  // ---------------------------------------------------------------------------

  List<Widget> _formatChildren() {
    final children = <Widget>[];

    if (_type == 'americano') {
      children.addAll([
        _label('Количество групп'),
        _groupsSelector(),
        const SizedBox(height: 12),
        _label('Количество раундов'),
        _textField(
          _roundsCount,
          hint: '7',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 4),
        Text(
          'Авто: игроков в группе − 1. Можно изменить вручную.',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _playoffSettings(),
        Divider(color: AppTheme.border, height: 28),
      ]);
    } else if (_type == 'mexicano') {
      children.addAll([
        _label('Количество раундов'),
        _textField(
          _roundsCount,
          hint: '7',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 4),
        Text(
          'Сколько раундов сыграть (обычно 5–9). Пары каждый раунд '
          'составляются по текущим очкам — все играют вместе, без групп.',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _checkboxTile(
          value: _hasPlayoff,
          label: 'С плей-офф (после основных раундов)',
          onChanged: (v) => setState(() => _hasPlayoff = v),
        ),
        Divider(color: AppTheme.border, height: 28),
      ]);
    } else if (_type == 'team') {
      children.addAll([
        _label('Кто собирает пары'),
        _pairingModeSelector(),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Text(
            _pairingMode == 'admin'
                ? 'Игроки записываются по одному, пары собираете вы перед стартом.'
                : 'Пары регистрируются сами (через поиск партнёра).',
            style: TextStyle(color: AppTheme.textDim, fontSize: 11),
          ),
        ),
        Text(
          'Фиксированные пары играют групповой этап. Можно добавить плей-офф на вылет или оставить только группы. Количество указано в парах.',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _label('Количество групп'),
        _teamGroupsSelector(),
        const SizedBox(height: 12),
        _label('Количество кортов'),
        _textField(
          _teamCourts,
          hint: 'оставьте пустым для авто',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 4),
        Text(
          'Если заполнено — матчи группового этапа идут волнами, не более N '
          'одновременно. Пусто — авто (по числу игроков).',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _checkboxTile(
          value: _teamHasPlayoff,
          label: 'С плей-офф (на вылет после групп)',
          onChanged: (v) => setState(() => _teamHasPlayoff = v),
        ),
        if (_teamHasPlayoff) ...[
          const SizedBox(height: 12),
          _label('Выходят из группы'),
          _teamsAdvanceSelector(),
          const SizedBox(height: 12),
          _checkboxTile(
            value: _teamHasLowerBracket,
            label: 'Нижняя сетка (для проигравших в QF)',
            onChanged: (v) => setState(() => _teamHasLowerBracket = v),
          ),
          _checkboxTile(
            value: _teamHasBronzeMatch,
            label: 'Матч за 3-е место',
            onChanged: (v) => setState(() => _teamHasBronzeMatch = v),
          ),
        ] else
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Без плей-офф: турнир завершится после группового этапа, итоговое место — по таблице групп.',
              style: TextStyle(color: AppTheme.textDim, fontSize: 11),
            ),
          ),
        Divider(color: AppTheme.border, height: 28),
      ]);
    }

    // Корты
    children.add(_label('Корты'));
    if (_type == 'americano_flex') {
      // Flex — кол-во кортов вручную (влияет на расписание пар).
      children.addAll([
        _textField(
          _flexCourts,
          hint: '$_flexMaxCourts',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 4),
        Text(
          'Сколько кортов играет одновременно (1 корт = 4 игрока). '
          'Максимум — $_flexMaxCourts. Пусто = $_flexMaxCourts.',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
      ]);
    } else {
      children.addAll([
        Text(
          'Кол-во кортов: $_courtsCount  (автоматически: участников ÷ 4)',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
      ]);
    }
    children.addAll([
      for (int i = 0; i < _courtsCount; i++) ...[
        _label('Корт ${i + 1}'),
        _textField(_courtNames[i], hint: 'Корт ${i + 1}'),
        if (i < _courtsCount - 1) const SizedBox(height: 8),
      ],
    ]);

    return children;
  }

  // Плюрализация (1 группа / 2 группы / 5 групп) и компактный формат уровня.
  String _plural(int n, String one, String few, String many) {
    final n10 = n % 10;
    final n100 = n % 100;
    if (n10 == 1 && n100 != 11) return one;
    if (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) return few;
    return many;
  }

  String _lvl(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('0') ? s.substring(0, s.length - 1) : s;
  }

  Widget _teamGroupsSelector() {
    Widget btn(int n) {
      final active = _teamGroupsCount == n;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _teamGroupsCount = n),
          child: Container(
            margin: EdgeInsets.only(left: n == 1 ? 0 : 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:
                  active ? AppTheme.accent.withOpacity(0.15) : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppTheme.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              n == 1 ? '1 группа' : (n >= 5 ? '$n групп' : '$n группы'),
              style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: [btn(1), btn(2), btn(3), btn(4)]);
  }

  Widget _teamsAdvanceSelector() {
    Widget btn(int n) {
      final active = _teamsAdvance == n;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _teamsAdvance = n),
          child: Container(
            margin: EdgeInsets.only(left: n == 1 ? 0 : 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:
                  active ? AppTheme.accent.withOpacity(0.15) : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppTheme.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              n == 1 ? '1 пара' : '$n пары',
              style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: [btn(1), btn(2), btn(3), btn(4)]);
  }

  Widget _groupsSelector() {
    Widget btn(int n) {
      final active = _groupsCount == n;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _groupsCount = n;
              // Полуфинал доступен и для 1, и для 2 групп.
              // Формат пересчитается в _playoffFormatSelector под новый набор.
            });
            _updateRoundsCount();
          },
          child: Container(
            margin: EdgeInsets.only(left: n == 1 ? 0 : 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.accent.withOpacity(0.15)
                  : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppTheme.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              n == 1 ? '1 группа' : '$n группы',
              style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: [btn(1), btn(2)]);
  }

  Widget _playoffSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _checkboxTile(
          value: _hasPlayoff,
          label: 'Добавить плей-офф',
          onChanged: (v) {
            setState(() {
              _hasPlayoff = v;
              if (!v) {
                _hasLowerBracket = false;
                _hasBronzeMatch = false;
              }
            });
          },
        ),
        if (_hasPlayoff) ...[
          const SizedBox(height: 8),
          _label('Тип плей-офф'),
          _playoffTypeSelector(),
          if (_needsPlayoffFormat()) ...[
            const SizedBox(height: 12),
            _label(_groupsCount >= 2 && _playoffType == 'semifinal_final'
                ? 'Формат пар в полуфиналах'
                : 'Формат пар в финале'),
            _playoffFormatSelector(),
          ],
          const SizedBox(height: 8),
          _checkboxTile(
            value: _hasLowerBracket,
            label: 'Нижняя сетка',
            onChanged: (v) => setState(() => _hasLowerBracket = v),
          ),
          _checkboxTile(
            value: _hasBronzeMatch,
            label: 'Матч за 3-е место',
            onChanged: (v) => setState(() => _hasBronzeMatch = v),
          ),
        ],
      ],
    );
  }

  bool _needsPlayoffFormat() {
    if (_groupsCount == 1) return true; // и final_only, и semifinal_final
    if (_groupsCount >= 2 && _playoffType == 'semifinal_final') return true;
    return false;
  }

  Widget _playoffTypeSelector() {
    Widget btn(String value, String label) {
      final active = _playoffType == value;
      // Оба типа (final_only / semifinal_final) доступны и для 1, и для 2 групп.
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _playoffType = value;
              // переинициализируем формат под новый набор
              if (_groupsCount == 1 && value == 'final_only') {
                _playoffFormat = 'cross';
              } else if (_groupsCount == 1 && value == 'semifinal_final') {
                _playoffFormat = 'mix';
              } else if (_groupsCount >= 2 && value == 'semifinal_final') {
                _playoffFormat = 'mix';
              }
            });
          },
          child: Container(
              margin: EdgeInsets.only(left: value == 'final_only' ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.accent.withOpacity(0.15)
                    : AppTheme.cardRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? AppTheme.accent : Colors.transparent,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: active ? AppTheme.accent : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }

    return Row(children: [
      btn('final_only', 'Только финал'),
      btn('semifinal_final', 'Полуфинал + финал'),
    ]);
  }

  Widget _playoffFormatSelector() {
    // Опции зависят от числа групп и типа плей-офф (как в Web)
    final options = <(String value, String label)>[];
    if (_groupsCount == 1 && _playoffType == 'final_only') {
      options.addAll(const [
        ('cross', '1+4 vs 2+3 (крест)'),
        ('tops', '1+2 vs 3+4 (топы вместе)'),
        ('mix', '1+3 vs 2+4 (микс)'),
      ]);
    } else if (_groupsCount == 1 && _playoffType == 'semifinal_final') {
      options.addAll(const [
        ('mix', 'Микс (1+8 vs 4+5, 2+7 vs 3+6)'),
        ('tops', 'Топы вместе (1+2 vs 7+8, 3+4 vs 5+6)'),
        ('balanced', 'Сбалансированный (1+4 vs 5+8, 2+3 vs 6+7)'),
      ]);
    } else if (_groupsCount >= 2 && _playoffType == 'semifinal_final') {
      options.addAll(const [
        ('mix', 'Микс (A1+B2 vs A3+B4, A2+B1 vs B3+A4)'),
        ('group_vs', 'Группа vs Группа'),
        ('tops', 'Топы вместе (A1+B1 vs A3+B3, A2+B2 vs A4+B4)'),
        ('cross', 'Крест (A1+B4 vs B1+A4, A2+B3 vs B2+A3)'),
      ]);
    }

    // Если текущий формат не входит в опции — переключим на первую
    if (options.isNotEmpty &&
        !options.any((o) => o.$1 == _playoffFormat)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _playoffFormat = options.first.$1);
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (final o in options)
            InkWell(
              onTap: () => setState(() => _playoffFormat = o.$1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      _playoffFormat == o.$1
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _playoffFormat == o.$1
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        o.$2,
                        style: TextStyle(
                          color: _playoffFormat == o.$1
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: _playoffFormat == o.$1
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _checkboxTile({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppTheme.accent : Colors.transparent,
                border: Border.all(
                  color: value ? AppTheme.accent : AppTheme.textSecondary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Раскрыть секцию (если свёрнута) — чтобы подсветить ошибку валидации.
  void _ensureOpen(String sectionKey) {
    if (!_openSections.contains(sectionKey)) {
      setState(() => _openSections.add(sectionKey));
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );

  Widget _textField(
    TextEditingController c, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textDim, fontSize: 13),
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
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.2),
        ),
      ),
    );
  }

  // Выбор длительности турнира (необязательно): «Не указана» + 1..8 часов.
  Widget _durationSelector() {
    const options = <int?>[null, 1, 2, 3, 4, 5, 6, 7, 8];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((h) {
        final selected = _durationHours == h;
        final label =
            h == null ? 'Не указана' : '$h ${_plural(h, 'час', 'часа', 'часов')}';
        return GestureDetector(
          onTap: () => setState(() => _durationHours = h),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppTheme.accent.withAlpha(30) : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppTheme.accent : AppTheme.border,
                width: selected ? 1 : 0.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dateField() {
    final text = _startDate != null ? _fmtDateTime(_startDate!) : 'Не выбрано';
    return GestureDetector(
      onTap: _pickStartDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined,
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
            Icon(Icons.chevron_right,
                color: AppTheme.textDim, size: 18),
          ],
        ),
      ),
    );
  }

  /// Поле выбора клуба-площадки (необязательно). Тап открывает поиск,
  /// крестик — сбрасывает выбор без открытия sheet.
  Widget _venueClubField() {
    final hasVenue = _venueClubId != null;
    return GestureDetector(
      onTap: _showVenueClubPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.place_outlined,
                color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasVenue ? _venueClubName ?? '' : 'Не выбран',
                style: TextStyle(
                  color: hasVenue ? AppTheme.textPrimary : AppTheme.textDim,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasVenue)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _venueClubId = null;
                    _venueClubName = null;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: AppTheme.textDim, size: 18),
                ),
              )
            else
              Icon(Icons.chevron_right,
                  color: AppTheme.textDim, size: 18),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet поиска клуба-площадки с debounce (400мс).
  Future<void> _showVenueClubPicker() async {
    final admin = context.read<AdminService>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final searchCtrl = TextEditingController();
        Timer? debounce;
        List<Map<String, dynamic>> results = [];
        bool loading = true;
        String? error;
        bool initialLoadStarted = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> runSearch(String query) async {
              setSheetState(() => loading = true);
              try {
                final found = await admin.searchClubs(query);
                setSheetState(() {
                  results = found;
                  loading = false;
                  error = null;
                });
              } catch (e) {
                setSheetState(() {
                  loading = false;
                  error = '$e';
                });
              }
            }

            // Первичная загрузка (пустой запрос) — один раз при открытии sheet.
            if (!initialLoadStarted) {
              initialLoadStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                runSearch('');
              });
            }

            void onChanged(String value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 400), () {
                runSearch(value);
              });
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Клуб (площадка)',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchCtrl,
                        autofocus: false,
                        onChanged: onChanged,
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Название, адрес или город',
                          hintStyle: TextStyle(
                              color: AppTheme.textDim, fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.textSecondary, size: 20),
                          filled: true,
                          fillColor: AppTheme.cardRaised,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
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
                            borderSide: const BorderSide(
                                color: AppTheme.accent, width: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_venueClubId != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _venueClubId = null;
                                _venueClubName = null;
                              });
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text(
                              'Убрать площадку',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: loading
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: AppTheme.accent,
                                        strokeWidth: 2.5),
                                  ),
                                ),
                              )
                            : error != null
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Ошибка поиска: $error',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13),
                                    ),
                                  )
                                : results.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          'Ничего не найдено',
                                          style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: results.length,
                                        itemBuilder: (context, index) {
                                          final club = results[index];
                                          final id = club['id'] as int;
                                          final name =
                                              '${club['name'] ?? ''}';
                                          final city = club['city'];
                                          final isSelected =
                                              _venueClubId == id;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _venueClubId = id;
                                                _venueClubName = name;
                                              });
                                              Navigator.of(sheetContext).pop();
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 6),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppTheme.accent
                                                        .withAlpha(15)
                                                    : AppTheme.card,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppTheme.accent
                                                          .withAlpha(60)
                                                      : const Color(
                                                          0xFF2A3330),
                                                  width:
                                                      isSelected ? 1 : 0.5,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          name,
                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? AppTheme
                                                                    .accent
                                                                : AppTheme
                                                                    .textPrimary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        if (city != null &&
                                                            '$city'
                                                                .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            2),
                                                            child: Text(
                                                              '$city',
                                                              style: TextStyle(
                                                                  color: AppTheme
                                                                      .textSecondary,
                                                                  fontSize:
                                                                      12),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    const Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            AppTheme.accent,
                                                        size: 20),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ??
        DateTime.now().add(const Duration(days: 1, hours: 12));
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
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

    final time = await _pickTime(TimeOfDay.fromDateTime(initial));
    if (time == null || !mounted) return;

    setState(() {
      _startDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  /// Выбор времени крутящимися колёсами (часы 00–23, минуты шагом 5).
  Future<TimeOfDay?> _pickTime(TimeOfDay initial) {
    int hour = initial.hour;
    int minuteIndex = (initial.minute ~/ 5).clamp(0, 11); // 0..11 → 0,5,..,55
    final hourCtrl = FixedExtentScrollController(initialItem: hour);
    final minuteCtrl = FixedExtentScrollController(initialItem: minuteIndex);

    String two(int v) => v.toString().padLeft(2, '0');

    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            Widget wheel({
              required FixedExtentScrollController controller,
              required int count,
              required String Function(int) label,
              required ValueChanged<int> onChanged,
            }) {
              return CupertinoPicker(
                scrollController: controller,
                itemExtent: 44,
                magnification: 1.1,
                squeeze: 1.1,
                backgroundColor: Colors.transparent,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSelectedItemChanged: onChanged,
                children: [
                  for (int i = 0; i < count; i++)
                    Center(
                      child: Text(
                        label(i),
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetCtx).padding.bottom + 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Row(
                      children: [
                        Text('Выберите время',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('${two(hour)}:${two(minuteIndex * 5)}',
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 24,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 190,
                    child: Row(
                      children: [
                        Expanded(
                          child: wheel(
                            controller: hourCtrl,
                            count: 24,
                            label: (i) => two(i),
                            onChanged: (i) => setSheet(() => hour = i),
                          ),
                        ),
                        Text(':',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700)),
                        Expanded(
                          child: wheel(
                            controller: minuteCtrl,
                            count: 12,
                            label: (i) => two(i * 5),
                            onChanged: (i) => setSheet(() => minuteIndex = i),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(sheetCtx).pop(),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Отмена',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(
                                TimeOfDay(hour: hour, minute: minuteIndex * 5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Готово',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _levelSliders() {
    Widget row(String label, double value, ValueChanged<double> onChanged) {
      return Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label,
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(1.0, 5.75),
              min: 1.0,
              max: 5.75,
              divisions: 19,
              activeColor: AppTheme.accent,
              inactiveColor: AppTheme.cardRaised,
              label: value.toStringAsFixed(2),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        row('Мин', _minLevel, (v) {
          setState(() {
            _minLevel = double.parse(v.toStringAsFixed(2));
            if (_minLevel > _maxLevel) _maxLevel = _minLevel;
          });
        }),
        row('Макс', _maxLevel, (v) {
          setState(() {
            _maxLevel = double.parse(v.toStringAsFixed(2));
            if (_maxLevel < _minLevel) _minLevel = _maxLevel;
          });
        }),
      ],
    );
  }

  Widget _pairingModeSelector() {
    Widget btn(String label, String value) {
      final active = _pairingMode == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _pairingMode = value),
          child: Container(
            margin: EdgeInsets.only(left: value == 'self' ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.accent.withOpacity(0.15)
                  : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppTheme.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: [
      btn('Сами игроки', 'self'),
      btn('Админ собирает', 'admin'),
    ]);
  }

  Widget _ratingToggle() {
    return Container(
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
                Text('Рейтинговый турнир',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  _isRated
                      ? 'Влияет на рейтинг игроков'
                      : 'Не повлияет на рейтинг игроков',
                  style: TextStyle(
                      color: AppTheme.textDim, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _isRated,
            onChanged: (v) => setState(() => _isRated = v),
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  // Тип подсчёта результата. v1: активна только «По очкам»; «По сетам» — заглушка.
  // Значение не отправляется — бэкенд по умолчанию считает по очкам.
  /// Ранжирование таблицы Just Padel It: по очкам (по умолчанию) / по победам.
  Widget _jpiRankControl() {
    Widget pill({
      required String text,
      required bool active,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.accent.withOpacity(0.15)
                  : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppTheme.accent : AppTheme.border,
                width: active ? 1.4 : 1,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Ранжирование таблицы'),
        Row(
          children: [
            pill(
              text: 'По очкам',
              active: !_jpiRankByWins,
              onTap: () => setState(() => _jpiRankByWins = false),
            ),
            const SizedBox(width: 10),
            pill(
              text: 'По победам',
              active: _jpiRankByWins,
              onTap: () => setState(() => _jpiRankByWins = true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _scoreTypeControl() {
    Widget pill({
      required String text,
      required bool active,
      required bool enabled,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.accent.withOpacity(0.15)
                : AppTheme.cardRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppTheme.accent : AppTheme.border,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: enabled
                  ? (active ? AppTheme.accent : AppTheme.textPrimary)
                  : AppTheme.textDim,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Тип подсчёта'),
        Row(
          children: [
            pill(text: 'По очкам', active: true, enabled: true),
            const SizedBox(width: 10),
            pill(text: 'По сетам · скоро', active: false, enabled: false),
          ],
        ),
      ],
    );
  }

  Widget _pairedToggle() {
    return Container(
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
                Row(
                  children: [
                    Text('Парный',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _showPairedInfo,
                      child: Icon(Icons.help_outline,
                          size: 16, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Фиксированные пары, ротация соперников',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: _flexIsPaired,
            onChanged: (v) => setState(() => _flexIsPaired = v),
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _verifiedToggle() {
    return Container(
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
                Text('Только для верифицированных',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  _verifiedOnly
                      ? 'Заявки только от верифицированных игроков'
                      : 'Заявки от любых игроков',
                  style: TextStyle(
                      color: AppTheme.textDim, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _verifiedOnly,
            onChanged: (v) => setState(() => _verifiedOnly = v),
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _chatSettings() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Чат турнира',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: _chatEnabled,
                onChanged: (v) => setState(() => _chatEnabled = v),
                activeColor: AppTheme.accent,
              ),
            ],
          ),
          if (_chatEnabled) ...[
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'admin', label: Text('Организатор')),
                ButtonSegment(
                    value: 'participants', label: Text('Участники')),
                ButtonSegment(value: 'everyone', label: Text('Все')),
              ],
              selected: {_chatWriteMode},
              onSelectionChanged: (s) =>
                  setState(() => _chatWriteMode = s.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                selectedBackgroundColor: AppTheme.accent,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Кто может писать. Читать могут все, кому доступен чат.',
              style: TextStyle(color: AppTheme.textDim, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusSelector() {
    Widget btn(String label, String value) {
      final isActive = _status == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _status = value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.accent.withOpacity(0.15)
                  : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? AppTheme.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color:
                    isActive ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('Черновик', 'draft'),
        const SizedBox(width: 8),
        btn('Открыть запись', 'open'),
      ],
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
                  if ((_saveLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_saveLabel!,
                        style: TextStyle(
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

  String _fmtDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} $hh:$mi';
  }
}
