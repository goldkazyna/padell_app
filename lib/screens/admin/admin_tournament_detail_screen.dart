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
import 'tournament_standings_share_screen.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/venue_club_field.dart';
import '../../utils/americano_playoff_formats.dart';
import '../../widgets/admin/mexicano_playoff_settings.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';
import '../../widgets/moderation_countdown.dart';
import '../../widgets/verified_badge.dart';
import '../player_profile_screen.dart';
import 'admin_bali_create_pairs_screen.dart';
import 'admin_jpi_create_pairs_screen.dart';
import 'admin_jpi_seeding_screen.dart';
import 'admin_koc_create_pairs_screen.dart';
import 'admin_pair_registration_screen.dart';
import 'admin_pairing_screen.dart';

/// Этап 3a/3b — экран управления существующим турниром.
/// Таб «Матчи» — заглушка до 3c.
class AdminTournamentDetailScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  /// Вкладка, открываемая при входе: 0 = Инфо, 1 = Участники, 2 = Приглашения,
  /// 3 = Матчи, 4 = Журнал. По умолчанию 0. Используется, напр., при переходе
  /// из пуша «участник вышел из турнира» — открываем Журнал на «отписались».
  final int initialTab;

  const AdminTournamentDetailScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    this.initialTab = 0,
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

  /// Призовой турнир: флаг и текст призов.
  final _prizes = TextEditingController();
  bool _hasPrizes = false;
  final _maxParticipants = TextEditingController();
  final _price = TextEditingController();
  final _moderationHours = TextEditingController();
  final _moderationMinutes = TextEditingController();
  DateTime? _startDate;
  double _minLevel = 1.0;
  double _maxLevel = 5.0;
  bool _verifiedOnly = false;
  String _status = 'open'; // draft / open — редактируемый статус
  String _pairingMode = 'self'; // self / admin — кто собирает пары (team)
  // Плей-офф командного турнира (редактируемые до старта).
  bool _teamHasPlayoff = true;
  bool _teamHasLowerBracket = false;
  bool _teamHasBronzeMatch = false;
  final _teamCourts = TextEditingController(); // пусто = авто
  // Названия кортов. Держим максимум слотов сразу, показываем столько,
  // сколько кортов у турнира; пустое поле = названия нет, сервер подпишет
  // корт номером.
  late final List<TextEditingController> _courtNames =
      List.generate(32, (_) => TextEditingController());
  /// Выбранный в списке формат. Применяется отдельной кнопкой: смена
  /// перекраивает настройки турнира, поэтому делаем её осознанным действием.
  String? _pickedType;
  bool _switchingType = false;

  // Клуб-площадка (где играем). Необязательная: null = не выбрана.
  int? _venueClubId;
  String? _venueClubName;
  // Админ правил число кортов руками — автоподстановка от участников
  // больше не перетирает его значение.
  bool _courtsTouchedManually = false;

  // Доп. поля редактирования (как при создании) — до старта менять безопасно
  final _durationHours = TextEditingController();
  final _reserveCount = TextEditingController();
  final _waitlistSize = TextEditingController();
  bool _isRated = true;
  // Формат: Американо
  int _amGroups = 1;
  final _amRounds = TextEditingController();
  bool _amHasPlayoff = false;
  String _amPlayoffType = 'final_only'; // final_only | semifinal_final
  String _amPlayoffFormat = 'mix';
  bool _amHasLower = false;
  bool _amHasBronze = false;
  // Формат: Мексикано (групп нет — только раунды и плей-офф)
  final _mexRounds = TextEditingController();
  bool _mexHasPlayoff = false;
  String _mexPlayoffType = 'final_only'; // final_only | semifinal_final
  String _mexPlayoffFormat = 'mix'; // mix | tops | balanced
  // Формат: командный
  int _teamGroups = 2;
  int _teamsAdvance = 2;
  // Парный режим (King of Court / Flex / Just Padel It)
  bool _isPaired = false;

  bool _saving = false;
  bool _starting = false;
  bool _deleting = false;

  // Этап 3b — участники
  AdminParticipantsResponse? _participants;
  bool _loadingParticipants = false;
  String? _participantsError;

  // Приглашения
  List<AdminInvitation>? _invitations;
  // Заготовка текста приглашения — приходит с сервера вместе со списком.
  String _inviteDefaultTitle = '';
  String _inviteDefaultBody = '';
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

  /// Открыта общая таблица, а не конкретная группа. По умолчанию именно она:
  /// при трёх группах посев в плей-офф идёт по ней, значит она главнее.
  bool _showOverallTable = true;
  // Round Robin: какие раунды раскрыты (override). По умолчанию раскрыт «идёт».
  final Map<int, bool> _rrRoundExpanded = {};

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    // Слушателей на контроллерах намеренно нет: автоподстановка кортов висит
    // на `onChanged` поля «Макс. участников», чтобы срабатывать только на
    // ручной ввод админа, а не на программное заполнение формы из ответа
    // сервера (иначе турниру молча проставлялось бы число кортов, которого
    // у него не было).
    _load();
    // Если открыли сразу на конкретной вкладке (напр. из пуша) — грузим её данные.
    if (widget.initialTab == 1) {
      _loadParticipants();
    } else if (widget.initialTab == 4) {
      _journalSubTab = 1; // «отписались» — открыто из пуша о выходе участника
      _loadJournal();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _prizes.dispose();
    _maxParticipants.dispose();
    _teamCourts.dispose();
    _price.dispose();
    _moderationHours.dispose();
    _moderationMinutes.dispose();
    _durationHours.dispose();
    _reserveCount.dispose();
    _waitlistSize.dispose();
    _amRounds.dispose();
    _mexRounds.dispose();
    for (final c in _courtNames) {
      c.dispose();
    }
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
    _hasPrizes = t.hasPrizes;
    _prizes.text = t.prizes ?? '';
    _maxParticipants.text = t.maxParticipants.toString();
    _price.text = t.price != null
        ? (t.price! % 1 == 0 ? t.price!.toInt().toString() : t.price.toString())
        : '';
    _startDate = t.startDate;
    _minLevel = t.minLevel <= 0 ? 1.0 : t.minLevel;
    _maxLevel = t.maxLevel <= 0 ? 5.0 : t.maxLevel;
    _verifiedOnly = t.verifiedOnly;
    // У парного JPI исторический режим — «админ собирает»: старые турниры
    // и старые сборки приложения поле не присылали.
    final defaultPairing =
        (t.type == 'just_padel_it' && t.isPaired) ? 'admin' : 'self';
    _pairingMode = t.pairingMode == 'admin'
        ? 'admin'
        : (t.pairingMode == 'self' ? 'self' : defaultPairing);
    _teamHasPlayoff = t.hasPlayoff;
    _teamHasLowerBracket = t.hasLowerBracket;
    _teamHasBronzeMatch = t.hasBronzeMatch;
    _teamCourts.text = t.courtsCount != null ? '${t.courtsCount}' : '';
    _venueClubId = t.venueClubId;
    _venueClubName = t.venueClubName;
    _pickedType = t.type;
    for (var i = 0; i < _courtNames.length; i++) {
      _courtNames[i].text = i < t.courts.length ? t.courts[i] : '';
    }
    // При загрузке ничего не подставляем: автоподстановка висит на живом вводе
    // числа участников, а не на открытии экрана. Иначе простое сохранение брони
    // сломало бы старт solo Just Padel It (там нужно ровно кортов × 4
    // зарегистрированных) и молча перекроило бы расписание командного турнира.
    //
    // Флаг сбрасываем: значение с сервера ручной правкой не считается, иначе
    // у турнира с уже заданными кортами смена числа участников перестала бы
    // пересчитывать корты — а это основной сценарий, ради которого поле и делали.
    _courtsTouchedManually = false;
    // Тоггл статуса работает только для черновик/открыт; иные статусы оставляем как есть.
    _status = (t.status == 'draft' || t.status == 'open') ? t.status : _status;
    _moderationHours.text = (t.moderationHours ?? 0) > 0 ? '${t.moderationHours}' : '';
    _moderationMinutes.text = (t.moderationMinutes ?? 0) > 0 ? '${t.moderationMinutes}' : '';
    // Доп. поля
    _durationHours.text = t.durationHours != null ? '${t.durationHours}' : '';
    _reserveCount.text = t.reserveCount > 0 ? '${t.reserveCount}' : '';
    _waitlistSize.text = t.waitlistSize > 0 ? '${t.waitlistSize}' : '';
    _isRated = t.isRated;
    final loadedGroups = t.groupsCount ?? 1;
    _amGroups = (loadedGroups >= 1 && loadedGroups <= 4) ? loadedGroups : 1;
    _amRounds.text = t.roundsCount != null ? '${t.roundsCount}' : '';
    _amHasPlayoff = t.hasPlayoff;
    _amPlayoffType = t.playoffType ?? 'final_only';
    _amPlayoffFormat = t.playoffFormat ?? 'mix';
    _amHasLower = t.hasLowerBracket;
    _amHasBronze = t.hasBronzeMatch;
    _mexRounds.text = t.roundsCount != null ? '${t.roundsCount}' : '';
    _mexHasPlayoff = t.hasPlayoff;
    _mexPlayoffType = t.playoffType ?? 'final_only';
    // Наборы форматов у Американо и Мексикано разные — чужой вариант
    // (например, cross) приводим к «миксу».
    _mexPlayoffFormat =
        const {'mix', 'tops', 'balanced'}.contains(t.playoffFormat)
            ? t.playoffFormat!
            : 'mix';
    _teamGroups = t.groupsCount ?? 2;
    _teamsAdvance = t.teamsAdvance ?? 2;
    _isPaired = t.isPaired;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Сменить формат. Сервер сам вычистит настройки старого типа и подгонит
  /// лимит участников — нам остаётся перечитать турнир, чтобы показать поля
  /// нового формата.
  Future<void> _applyType() async {
    final t = _t;
    final picked = _pickedType;
    if (t == null || picked == null || picked == t.type) return;

    final label = t.switchTypes
        .firstWhere((e) => e.value == picked, orElse: () => (value: picked, label: picked))
        .label;

    final admin = context.read<AdminService>();
    final confirmed = await _confirm(
      title: 'Смена формата',
      message: 'Сменить формат на «$label»? Настройки текущего формата '
          'сбросятся, записавшиеся останутся.',
      okText: 'Сменить',
    );
    if (!confirmed) {
      setState(() => _pickedType = t.type);
      return;
    }

    setState(() => _switchingType = true);
    try {
      await admin.updateTournament(
            t.id,
            name: _name.text.trim(),
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            startDate: _startDate ?? t.startDate ?? DateTime.now(),
            minLevel: _minLevel,
            maxLevel: _maxLevel,
            maxParticipants: t.maxParticipants,
            price: t.price,
            moderationHours: int.tryParse(_moderationHours.text.trim()),
            moderationMinutes: int.tryParse(_moderationMinutes.text.trim()),
            newType: picked,
          );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      final fresh = _t;
      final left = fresh == null
          ? 0
          : fresh.maxParticipants - fresh.participantsCount;
      await showAppAlert(
        context,
        left > 0
            ? 'Формат изменён. Записано ${fresh!.participantsCount} из '
                '${fresh.maxParticipants} — старт откроется, когда наберётся ещё $left.'
            : 'Формат изменён.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pickedType = t.type);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _switchingType = false);
    }
  }

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
            hasPrizes: _hasPrizes,
            prizes: _prizes.text.trim(),
            startDate: _startDate!,
            minLevel: _minLevel,
            maxLevel: _maxLevel,
            maxParticipants: maxP,
            price: price,
            verifiedOnly: _verifiedOnly,
            moderationHours: int.tryParse(_moderationHours.text.trim()),
            moderationMinutes: int.tryParse(_moderationMinutes.text.trim()),
            status: _status,
            pairingMode: t.type == 'team' ? _pairingMode : null,
            hasPlayoff: t.type == 'team'
                ? _teamHasPlayoff
                : (t.type == 'americano'
                    ? _amHasPlayoff
                    : (t.type == 'mexicano' ? _mexHasPlayoff : null)),
            hasLowerBracket: t.type == 'team'
                ? _teamHasLowerBracket
                : (t.type == 'americano' ? _amHasLower : null),
            hasBronzeMatch: t.type == 'team'
                ? _teamHasBronzeMatch
                : (t.type == 'americano' ? _amHasBronze : null),
            playoffType: t.type == 'americano' && _amHasPlayoff
                ? _amPlayoffType
                : (t.type == 'mexicano' && _mexHasPlayoff
                    ? _mexPlayoffType
                    : null),
            // Финал топ-4 у Мексикано сервер собирает как 1+4 vs 2+3 —
            // формат осмыслен только для полуфиналов.
            playoffFormat: t.type == 'americano' && _amHasPlayoff
                ? _amPlayoffFormat
                : (t.type == 'mexicano' &&
                        _mexHasPlayoff &&
                        _mexPlayoffType == 'semifinal_final'
                    ? _mexPlayoffFormat
                    : null),
            // Поле кортов (_teamCourts) общее для всех типов, кроме Flex у
            // которого свой блок ниже, но контроллер тот же самый — отправляем
            // значение независимо от типа, лишь бы поле было заполнено.
            courtsCount: _teamCourts.text.trim().isNotEmpty
                ? int.tryParse(_teamCourts.text.trim())
                : null,
            // Названия кортов: пустое поле уходит как null — сервер подпишет
            // такой корт номером, а не пустой строкой.
            courts: [
              for (var i = 0; i < _courtNamesCount; i++)
                _courtNames[i].text.trim().isEmpty
                    ? null
                    : _courtNames[i].text.trim(),
            ],
            durationHours: int.tryParse(_durationHours.text.trim()),
            // Площадку шлём всегда: поле есть в форме, и её сброс (null)
            // должен доезжать до сервера как «убрать», а не теряться.
            venueClubId: _venueClubId,
            includeVenueClub: true,
            isRated: _isRated,
            reserveCount: int.tryParse(_reserveCount.text.trim()) ?? 0,
            waitlistSize: int.tryParse(_waitlistSize.text.trim()) ?? 0,
            groupsCount: t.type == 'americano'
                ? _amGroups
                : (t.type == 'team' ? _teamGroups : null),
            roundsCount: t.type == 'mexicano' &&
                    _mexRounds.text.trim().isNotEmpty
                ? int.tryParse(_mexRounds.text.trim())
                : t.type == 'americano' && _amRounds.text.trim().isNotEmpty
                    ? int.tryParse(_amRounds.text.trim())
                    : null,
            teamsAdvance: t.type == 'team' ? _teamsAdvance : null,
            isPaired: (t.type == 'king_of_court' ||
                    t.type == 'americano_flex' ||
                    t.type == 'just_padel_it')
                ? _isPaired
                : null,
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

  // Кнопка выбора режима сбора пар (self / admin) для командного турнира.
  Widget _pairingBtn(String label, String value, bool disabled) {
    final active = _pairingMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : () => setState(() => _pairingMode = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppTheme.accent : AppTheme.border,
              width: 1.2,
            ),
          ),
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

  // Универсальный чип выбора (группы, формат плей-офф и т.п.).
  /// Выбор формата пар для Американо на одной-двух группах. Набор общий
  /// с экраном создания и веб-формой — раньше в настройках его не было
  /// вовсе, и формат оставался таким, каким его задали при создании.
  List<Widget> _americanoFormatChips(bool disabled) {
    final options = americanoPlayoffFormats(
      groupsCount: _amGroups,
      playoffType: _amPlayoffType,
    );
    if (options.isEmpty) return const [];

    // Сохранённое значение может быть из чужого набора (сменили тип сетки).
    final current = normalizeAmericanoPlayoffFormat(
      groupsCount: _amGroups,
      playoffType: _amPlayoffType,
      current: _amPlayoffFormat,
    );
    if (current != _amPlayoffFormat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _amPlayoffFormat = current);
      });
    }

    return [
      const SizedBox(height: 10),
      _label(americanoPlayoffFormatLabel(
        groupsCount: _amGroups,
        playoffType: _amPlayoffType,
      )),
      const SizedBox(height: 6),
      // Радио-строки, а не чипы: подписи вроде «Группа vs Группа (A1+A2 vs
      // B1+B2, A3+A4 vs B3+B4)» в чип по ширине не помещаются.
      Container(
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            for (final option in options)
              InkWell(
                onTap: disabled
                    ? null
                    : () => setState(() => _amPlayoffFormat = option.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        current == option.value
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: current == option.value
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option.label,
                          style: TextStyle(
                              color: AppTheme.textPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _fmtChip(String label, bool active, bool disabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppTheme.accent : AppTheme.border,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accent : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Тумблер-строка настройки (плей-офф командного турнира).
  Widget _boolTile({
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
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
                Text(label,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppTheme.textDim, fontSize: 11)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  /// Нужно ли сначала создать пары (Bali, фикс-парный Король корта или
  /// фикс-парный Just Padel It без пар).
  bool get _needPairs {
    final t = _t;
    if (t == null) return false;
    if (t.type == 'bali_koc' && !t.baliPairsCreated) return true;
    if (t.type == 'king_of_court' && t.isPaired && !t.kocPairsCreated) return true;
    // Парный JPI: пары собирает либо админ, либо сами игроки при записи.
    // Во втором случае пары уже готовы (лежат в командах турнира и переезжают
    // в формат при старте) — предлагать собрать их заново незачем.
    if (t.type == 'just_padel_it' && t.isPaired) {
      return !t.jpiPairsCreated && t.isAdminPairing;
    }
    return false;
  }

  /// Командный турнир с «Админ собирает пары»: перед стартом админ собирает
  /// пары через экран сбора (там же и запуск). Кнопка — «Собрать пары».
  /// Только групповой турнир: у парного JPI свой экран сбора пар, а общий
  /// экран рассчитан на команды и там не подойдёт.
  bool get _needAdminPairing =>
      _t?.type == 'team' &&
      (_t?.isAdminPairing ?? false) &&
      _t?.status == 'open';

  /// Запись парой: организатор заводит сразу двоих. Признак считает сервер.
  bool get _canRegisterPairs => _t?.supportsPairRegistration ?? false;

  /// Открыть запись парой и обновить карточку, если что-то поменялось.
  Future<void> _openPairRegistration() async {
    final t = _t;
    if (t == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminPairRegistrationScreen(
          tournamentId: t.id,
          tournamentName: t.name,
        ),
      ),
    );
    if (changed == true) await _load();
  }

  /// Открыть экран сбора пар (админ собирает) и обновить карточку после.
  Future<void> _openAdminPairing() async {
    final t = _t;
    if (t == null) return;
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
        final fresh =
            await context.read<AdminService>().getTournamentDetail(t.id);
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
  }

  /// Solo Just Padel It: старт идёт через экран посева (авто по рейтингу +
  /// ручная расстановка), поэтому кнопка называется «Посев», а не «Запустить».
  bool get _isJpiSolo {
    final t = _t;
    return t != null && t.type == 'just_padel_it' && !t.isPaired;
  }

  bool get _isFlex {
    final t = _t;
    return t != null && t.type == 'americano_flex';
  }

  bool get _isEscalera {
    final t = _t;
    return t != null && t.type == 'escalera';
  }

  /// Авто-расчёт числа кортов от количества участников: 1 корт = 4 игрока,
  /// диапазон 1-32. Только арифметика, без проверок «можно ли подставлять» —
  /// те проверки разные в разных местах вызова (см. `_autofillCourts` и
  /// `_applyToForm`).
  int _computeAutoCourts(int maxParticipants) =>
      (maxParticipants / 4).ceil().clamp(1, 32);

  /// Реально ли сервер использует число кортов у этого формата.
  ///
  /// Читают его всего три места: Americano Flex (расписание пар), командный
  /// турнир (матчи группы идут волнами) и solo Just Padel It (сетка посева).
  /// У короля корта, Bali, американо, мексикано и классического число кортов
  /// на игру считается от числа участников, а сохранённое значение влияет
  /// только на количество названий кортов.
  /// Сколько полей названий кортов показывать: заданное вручную число, иначе
  /// авто — по четыре игрока на корт (так же считает веб-форма).
  int get _courtNamesCount {
    final manual = int.tryParse(_teamCourts.text.trim());
    if (manual != null && manual >= 1) return manual.clamp(1, 32);

    final maxP = int.tryParse(_maxParticipants.text.trim()) ?? 0;
    if (maxP <= 0) return 1;
    return (maxP / 4).ceil().clamp(1, 32);
  }

  bool get _courtsAffectSchedule {
    final t = _t;
    if (t == null) return false;
    return t.type == 'americano_flex' ||
        t.type == 'team' ||
        (t.type == 'just_padel_it' && !t.isPaired);
  }

  /// Подставить число кортов от количества участников: 1 корт = 4 игрока.
  ///
  /// Вызывается ТОЛЬКО из `onChanged` поля «Макс. участников», то есть когда
  /// админ сам меняет число участников в этой сессии. Значение, пришедшее
  /// с сервера, пересчитать можно — иначе у турнира с заданными кортами смена
  /// участников ничего бы не меняла. Не трогает поле, если админ правил корты
  /// руками в этой сессии, или это Flex — у Flex собственный блок кортов.
  void _autofillCourts(String _) {
    // У эскалеры участники считаются из кортов, а не наоборот — подставлять
    // корты по числу участников здесь нельзя, иначе поля перетирают друг друга.
    if (_isFlex || _isEscalera || _courtsTouchedManually) return;

    final maxP = int.tryParse(_maxParticipants.text.trim());
    if (maxP == null || maxP <= 0) return;

    final next = '${_computeAutoCourts(maxP)}';
    if (_teamCourts.text.trim() == next) return;

    _teamCourts.text = next;
  }

  /// Открыть экран создания пар (JPI, KOC или Bali) и обновить карточку после.
  Future<void> _openCreatePairs() async {
    final t = _t;
    if (t == null) return;
    final isJpi = t.type == 'just_padel_it';
    final isKoc = t.type == 'king_of_court';
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => isJpi
            ? AdminJpiCreatePairsScreen(tournamentId: t.id, tournamentName: t.name)
            : isKoc
                ? AdminKocCreatePairsScreen(tournamentId: t.id, tournamentName: t.name)
                : AdminBaliCreatePairsScreen(tournamentId: t.id, tournamentName: t.name),
      ),
    );
    if (ok == true) {
      try {
        final fresh = await context.read<AdminService>().getTournamentDetail(t.id);
        if (mounted) setState(() => _t = fresh);
      } catch (_) {}
    }
  }

  Future<void> _start() async {
    final t = _t;
    if (t == null) return;

    // Just Padel It solo (без фиксированных пар) — старт идёт через экран
    // ручного посева (авто по рейтингу + свап), а не общий /start без body.
    if (t.type == 'just_padel_it' && !t.isPaired) {
      final started = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AdminJpiSeedingScreen(
            tournamentId: t.id,
            tournamentName: t.name,
          ),
        ),
      );
      if (started == true && mounted) {
        try {
          final fresh =
              await context.read<AdminService>().getTournamentDetail(t.id);
          if (!mounted) return;
          _applyToForm(fresh);
          setState(() {
            _t = fresh;
            _matches = null;
            _participants = null;
            _invitations = null;
          });
          unawaited(_loadMatches());
          unawaited(_loadParticipants());
        } catch (_) {}
      }
      return;
    }

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

  Future<void> _cancelTournament() async {
    final t = _t;
    if (t == null) return;

    final ok = await _confirm(
      title: 'Остановить турнир?',
      message:
          'Турнир будет остановлен и переведён в статус «Отменён». Отменить это действие нельзя.',
      okText: 'Остановить',
      destructive: true,
    );
    if (!ok) return;

    setState(() => _starting = true);
    try {
      final updated =
          await context.read<AdminService>().cancelTournament(t.id);
      if (!mounted) return;
      _applyToForm(updated);
      setState(() {
        _t = updated;
        _starting = false;
        _matches = null;
        _participants = null;
        _invitations = null;
      });
      if (!mounted) return;
      await showAppAlert(context, 'Турнир остановлен');
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
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        content: Text(message,
            style: TextStyle(
                color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена',
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

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
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
                Text(
                  'Управление турниром',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.card,
            onSelected: (value) {
              if (value == 'start') {
                // То же действие, что и у нижней кнопки: собрать пары (админ)
                // / создать пары (Bali/KOC/JPI) / запустить.
                if (_needAdminPairing) {
                  _openAdminPairing();
                } else if (_needPairs) {
                  _openCreatePairs();
                } else {
                  _start();
                }
              }
              if (value == 'pairs') _openPairRegistration();
              if (value == 'restart') _restart();
              if (value == 'cancel') _cancelTournament();
              if (value == 'send_push') _sendPush();
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final items = <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'start',
                  enabled: _needAdminPairing || (_t?.canStart ?? false),
                  child: Text(_needAdminPairing
                      ? 'Собрать пары'
                      : (_needPairs
                          ? 'Создать пары'
                          : (_isJpiSolo
                              ? 'Посев'
                              : l10n.startTournamentMenu))),
                ),
                if (_canRegisterPairs)
                  const PopupMenuItem<String>(
                    value: 'pairs',
                    child: Text('Пары'),
                  ),
                PopupMenuItem<String>(
                  value: 'restart',
                  enabled: _t?.canRestart ?? false,
                  child: Text(l10n.restartTournament),
                ),
              ];
              // Остановить турнир (сменить статус на «Отменён») — доступно, пока
              // турнир открыт или идёт (не завершён и не отменён).
              if (_t?.status == 'open' || _t?.status == 'in_progress') {
                items.add(PopupMenuItem<String>(
                  value: 'cancel',
                  child: Text('Остановить турнир',
                      style: TextStyle(color: AppTheme.error)),
                ));
              }
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
            Icon(Icons.error_outline,
                color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textSecondary)),
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
            Icon(Icons.construction_outlined,
                color: AppTheme.textDim, size: 56),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
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
              // Призовой турнир — та же настройка, что при создании.
              _boolTile(
                label: 'Призовой турнир',
                subtitle: 'Покажем призы в карточке турнира',
                value: _hasPrizes,
                onChanged:
                    disabled ? null : (v) => setState(() => _hasPrizes = v),
              ),
              if (_hasPrizes) ...[
                const SizedBox(height: 12),
                _label('Призы'),
                _textField(_prizes,
                    hint: 'Например: 1 место — …, 2 место — …',
                    maxLines: 3,
                    enabled: !disabled),
              ],
              const SizedBox(height: 12),
              _label('Клуб (площадка)'),
              _venueClubField(disabled: disabled),
              const SizedBox(height: 4),
              Text(
                'Необязательно. Где физически играют — увидят записавшиеся.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
              const SizedBox(height: 12),
              _label('Дата и время старта'),
              _dateField(disabled: disabled),
              const SizedBox(height: 12),
              _label('Длительность, часов'),
              _textField(_durationHours,
                  hint: 'Необязательно',
                  keyboardType: TextInputType.number,
                  enabled: !disabled,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
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
                            // Ladder: участников считает сервер как корты × 4,
                            // руками это поле не меняют.
                            enabled: !disabled && !_isEscalera,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            // Ручная правка числа участников подставляет корты,
                            // но только если они ещё не заданы.
                            onChanged: _autofillCourts),
                        if (_isEscalera)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Считается из кортов: корты × 4.',
                              style: TextStyle(
                                  color: AppTheme.textDim, fontSize: 11),
                            ),
                          ),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Забронировать мест'),
                        _textField(_reserveCount,
                            hint: '0',
                            keyboardType: TextInputType.number,
                            enabled: !disabled,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Лист ожидания'),
                        _textField(_waitlistSize,
                            hint: '0',
                            keyboardType: TextInputType.number,
                            enabled: !disabled,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ]),
                      ],
                    ),
                  ),
                ],
              ),
              _boolTile(
                label: 'Рейтинговый турнир',
                subtitle: 'Результаты повлияют на рейтинг игроков.',
                value: _isRated,
                onChanged: disabled ? null : (v) => setState(() => _isRated = v),
              ),
              const SizedBox(height: 14),
              _label('Таймер модерации'),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Часов',
                            style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
                        const SizedBox(height: 4),
                        _textField(_moderationHours,
                            hint: 'Пусто = без таймера',
                            keyboardType: TextInputType.number,
                            enabled: !disabled),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Минут (для отладки)',
                            style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
                        const SizedBox(height: 4),
                        _textField(_moderationMinutes,
                            hint: 'Важнее часов',
                            keyboardType: TextInputType.number,
                            enabled: !disabled),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Меняет только новые заявки — у уже поданных дедлайн остаётся прежним.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
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
                      onChanged: disabled
                          ? null
                          : (v) => setState(() => _verifiedOnly = v),
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Перевод черновик ⇄ открыта регистрация
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
                          Text('Открыта регистрация',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            _status == 'open'
                                ? 'Турнир виден игрокам, идёт онлайн-запись'
                                : 'Черновик — игроки не видят турнир',
                            style: TextStyle(
                                color: AppTheme.textDim, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _status == 'open',
                      onChanged: disabled
                          ? null
                          : (v) =>
                              setState(() => _status = v ? 'open' : 'draft'),
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
              ),
              // Количество кортов — у всех типов, кроме Americano Flex
              // (у него свой блок ниже с тем же полем — не дублируем).
              if (!_isFlex) ...[
                const SizedBox(height: 12),
                Text('Количество кортов',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _teamCourts,
                  enabled: !disabled,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'не задано',
                    hintStyle: TextStyle(color: AppTheme.textDim),
                    filled: true,
                    fillColor: AppTheme.cardRaised,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) {
                    // Введённое значение защищаем от автоподстановки по числу
                    // участников; очистка поля возвращает её.
                    // setState — чтобы список названий кортов перерисовался
                    // под новое количество.
                    setState(() {
                      _courtsTouchedManually = value.trim().isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 4),
                // Пустое поле НЕ означает «авто»: ключ просто не уходит на
                // сервер, и сохранённое значение остаётся прежним. Вернуть
                // турнир в авто-режим из приложения нельзя.
                Text(
                  _t?.courtsCount == null
                      ? 'Не задано — число кортов считается автоматически. '
                          'Пустое поле оставит всё как есть.'
                      : 'Пустое поле оставит текущее значение без изменений.',
                  style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                ),
                // Форматы, где сервер число кортов не читает: оно задаёт
                // только количество названий кортов.
                if (!_courtsAffectSchedule) ...[
                  const SizedBox(height: 4),
                  Text(
                    'У этого формата корты на игру считаются автоматически по '
                    'числу участников — значение задаёт только количество '
                    'названий кортов.',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                ],
                // Solo Just Padel It: посев строит сетку ровно кортов × 4,
                // поэтому при несовпадении кнопка старта недоступна.
                if (_isJpiSolo) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Кнопка посева появится, только когда зарегистрированных '
                    'будет ровно кортов × 4. Если корты не заданы — хватит '
                    'любого числа игроков, кратного четырём.',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                ],
              ],
              // Количество кортов — для Americano Flex.
              if (_isFlex) ...[
                const SizedBox(height: 12),
                Text('Количество кортов',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _teamCourts,
                  enabled: !disabled,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppTheme.textPrimary),
                  // Перерисовываем список названий кортов под новое число.
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'напр. 2',
                    hintStyle: TextStyle(color: AppTheme.textDim),
                    filled: true,
                    fillColor: AppTheme.cardRaised,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Сколько кортов задействовано — влияет на расписание раундов.',
                  style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                ),
              ],
              // Названия кортов — необязательные подписи. Количество полей
              // идёт за числом кортов: заданным вручную или авто по игрокам.
              const SizedBox(height: 12),
              Text('Названия кортов',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              for (var i = 0; i < _courtNamesCount; i++) ...[
                _textField(_courtNames[i],
                    hint: 'Корт ${i + 1}', enabled: !disabled),
                if (i < _courtNamesCount - 1) const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              Text(
                'Пустое поле — корт будет подписан номером.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
              // Кто собирает пары — только для командного турнира.
              if (_t?.type == 'team') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardRaised,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Кто собирает пары',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _pairingBtn('Сами игроки', 'self', disabled),
                          const SizedBox(width: 8),
                          _pairingBtn('Админ собирает', 'admin', disabled),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _pairingMode == 'admin'
                            ? 'Игроки записываются по одному, пары собираете вы перед стартом.'
                            : 'Пары регистрируются сами (через поиск партнёра).',
                        style: TextStyle(
                            color: AppTheme.textDim, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _boolTile(
                  label: 'С плей-офф',
                  subtitle: 'На вылет после групп. Выкл — только групповой этап.',
                  value: _teamHasPlayoff,
                  onChanged: disabled
                      ? null
                      : (v) => setState(() => _teamHasPlayoff = v),
                ),
                if (_teamHasPlayoff) ...[
                  _boolTile(
                    label: 'Нижняя сетка',
                    subtitle: 'Утешительная — для проигравших.',
                    value: _teamHasLowerBracket,
                    onChanged: disabled
                        ? null
                        : (v) => setState(() => _teamHasLowerBracket = v),
                  ),
                  _boolTile(
                    label: 'Матч за 3-е место',
                    value: _teamHasBronzeMatch,
                    onChanged: disabled
                        ? null
                        : (v) => setState(() => _teamHasBronzeMatch = v),
                  ),
                ],
              ],
            ],
          ),
          if (t.canSwitchType) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Формат турнира',
              children: [
                _label('Тип'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardRaised,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _pickedType ?? t.type,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardRaised,
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      items: [
                        for (final option in t.switchTypes)
                          DropdownMenuItem(
                            value: option.value,
                            child: Text(option.label),
                          ),
                      ],
                      onChanged: (_switchingType || disabled)
                          ? null
                          : (value) => setState(() => _pickedType = value),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if ((_pickedType ?? t.type) != t.type)
                  _primaryButton(
                    label: 'Применить формат',
                    loading: _switchingType,
                    onTap: _switchingType ? null : _applyType,
                  ),
                const SizedBox(height: 4),
                Text(
                  'Формат меняется, пока турнир не начат — записавшиеся '
                  '(${t.participantsCount}) остаются. Настройки старого формата '
                  'сбросятся, а число участников подгонится под новый. Если людей '
                  'станет не хватать, турнир дождётся остальных.',
                  style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                ),
              ],
            ),
          ],
          if (t.type == 'americano' ||
              t.type == 'mexicano' ||
              t.type == 'team' ||
              t.type == 'king_of_court' ||
              t.type == 'americano_flex' ||
              t.type == 'just_padel_it') ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Настройка формата',
              children: [
                // Мексикано: групп нет, пары считаются по очкам каждый раунд.
                if (t.type == 'mexicano') ...[
                  _label('Количество раундов'),
                  _textField(_mexRounds,
                      hint: '7',
                      keyboardType: TextInputType.number,
                      enabled: !disabled,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  const SizedBox(height: 4),
                  Text(
                    'Обычно 5–9. Закончить раньше плана можно кнопкой '
                    '«Завершить отборочный этап» во время турнира.',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  MexicanoPlayoffSettings(
                    hasPlayoff: _mexHasPlayoff,
                    playoffType: _mexPlayoffType,
                    playoffFormat: _mexPlayoffFormat,
                    enabled: !disabled,
                    onHasPlayoffChanged: (v) =>
                        setState(() => _mexHasPlayoff = v),
                    onTypeChanged: (v) =>
                        setState(() => _mexPlayoffType = v),
                    onFormatChanged: (v) =>
                        setState(() => _mexPlayoffFormat = v),
                  ),
                ],
                // Американо
                if (t.type == 'americano') ...[
                  _label('Количество групп'),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final n in const [1, 2, 3, 4])
                      _fmtChip(n == 1 ? '1 группа' : '$n группы',
                          _amGroups == n, disabled, () {
                        setState(() {
                          _amGroups = n;
                          // 3+ групп идут только по общей таблице: топ-4 ждут
                          // в полуфинале, места 5–12 играют четвертьфинал.
                          if (n >= 3) {
                            _amPlayoffType = 'semifinal_final';
                            _amPlayoffFormat = 'table_qf';
                            _amHasLower = false;
                          } else if (_amPlayoffFormat == 'table_qf') {
                            _amPlayoffFormat = 'mix';
                          }
                        });
                      }),
                  ]),
                  const SizedBox(height: 12),
                  _label('Количество раундов'),
                  _textField(_amRounds,
                      hint: 'Авто (игроков в группе − 1)',
                      keyboardType: TextInputType.number,
                      enabled: !disabled,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  _boolTile(
                    label: 'С плей-офф',
                    subtitle: 'Стадия навылет после группового этапа.',
                    value: _amHasPlayoff,
                    onChanged: disabled
                        ? null
                        : (v) => setState(() => _amHasPlayoff = v),
                  ),
                  if (_amHasPlayoff) ...[
                    const SizedBox(height: 4),
                    _label('Тип плей-офф'),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (_amGroups < 3)
                        _fmtChip('Только финал', _amPlayoffType == 'final_only',
                            disabled,
                            () => setState(() => _amPlayoffType = 'final_only')),
                      _fmtChip(
                          'Полуфинал + финал',
                          _amPlayoffType == 'semifinal_final',
                          disabled,
                          () => setState(
                              () => _amPlayoffType = 'semifinal_final')),
                    ]),
                    if (_amGroups < 3) ...[
                      ..._americanoFormatChips(disabled),
                    ],
                    if (_amGroups >= 3) ...[
                      const SizedBox(height: 10),
                      _label('Формат плей-офф'),
                      const SizedBox(height: 6),
                      _fmtChip('Общая таблица', true, true, () {}),
                      const SizedBox(height: 6),
                      Text(
                        'Места 1–4 ждут соперников в полуфинале, '
                        'места 5–12 играют четвертьфинал. Нужно минимум 12 игроков.',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.35),
                      ),
                    ],
                    if (_amGroups < 3)
                      _boolTile(
                        label: 'Нижняя сетка',
                        value: _amHasLower,
                        onChanged: disabled
                            ? null
                            : (v) => setState(() => _amHasLower = v),
                      ),
                    _boolTile(
                      label: 'Матч за 3-е место',
                      value: _amHasBronze,
                      onChanged: disabled
                          ? null
                          : (v) => setState(() => _amHasBronze = v),
                    ),
                  ],
                ],
                // Командный
                if (t.type == 'team') ...[
                  _label('Количество групп'),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, children: [
                    for (final n in [1, 2, 3, 4])
                      _fmtChip('$n', _teamGroups == n, disabled,
                          () => setState(() => _teamGroups = n)),
                  ]),
                  const SizedBox(height: 12),
                  _label('Выходят из группы (в плей-офф)'),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, children: [
                    for (final n in [1, 2, 3, 4])
                      _fmtChip('$n', _teamsAdvance == n, disabled,
                          () => setState(() => _teamsAdvance = n)),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    'Кто собирает пары, плей-офф и корты — в разделе «Параметры» выше.',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                ],
                // Парный режим (KoC / Flex / Just Padel It)
                if (t.type == 'king_of_court' ||
                    t.type == 'americano_flex' ||
                    t.type == 'just_padel_it')
                  _boolTile(
                    label: 'Фиксированные пары',
                    subtitle: t.participantsCount > 0
                        ? 'Нельзя менять — уже есть записи.'
                        : 'Игроки играют постоянными парами (создаются перед стартом). Выкл — очередь/ротация.',
                    value: _isPaired,
                    onChanged: (disabled || t.participantsCount > 0)
                        ? null
                        : (v) => setState(() => _isPaired = v),
                  ),
              ],
            ),
          ],
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
              if (t.courts.any((c) => c.trim().isNotEmpty))
                _readOnlyRow(
                  'Корты',
                  [
                    for (var i = 0; i < t.courts.length; i++)
                      t.courts[i].trim().isEmpty
                          ? 'Корт ${i + 1}'
                          : t.courts[i],
                  ].join(', '),
                ),
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
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  t.startDate != null
                      ? _fmtDateTime(t.startDate!)
                      : 'Дата не задана',
                  style: TextStyle(
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
          Icon(Icons.lock_outline, color: AppTheme.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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
              style: TextStyle(
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
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: c,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppTheme.textDim, fontSize: 13),
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

  Widget _venueClubField({required bool disabled}) {
    return VenueClubField(
      clubId: _venueClubId,
      clubName: _venueClubName,
      enabled: !disabled,
      onChanged: (id, name) {
        setState(() {
          _venueClubId = id;
          _venueClubName = name;
        });
      },
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

  Widget _levelSliders({required bool disabled}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
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
                style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
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
                style: TextStyle(
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
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
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
        onTap: _starting ? null : _openAdminPairing,
        color: AppTheme.accent,
      ));
    } else if (t.canStart) {
      // Bali KOC / фикс-парный Король корта: до создания пар нельзя стартовать.
      if (children.isNotEmpty) children.add(const SizedBox(height: 10));
      if (_needPairs) {
        children.add(_primaryButton(
          label: 'Создать пары',
          onTap: _starting ? null : _openCreatePairs,
          color: AppTheme.accent,
        ));
      } else {
        children.add(_primaryButton(
          label: _starting
              ? 'Запуск...'
              : (_isJpiSolo ? 'Посев' : 'Запустить турнир'),
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
      final loaded = await context
          .read<AdminService>()
          .getTournamentInvitations(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _invitations = loaded.items;
        _inviteDefaultTitle = loaded.defaultTitle;
        _inviteDefaultBody = loaded.defaultBody;
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
              Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_invitationsError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary)),
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
    final canInvite = _t != null && (_t!.type != 'team' || _t!.isAdminPairing);

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
                    Text('Приглашено: ${list.length}',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
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
            Padding(
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
                    style: TextStyle(
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
            icon: Icon(Icons.close, size: 20, color: AppTheme.error),
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
              Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_participantsError!,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppTheme.textSecondary)),
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
              Icon(Icons.hourglass_top, color: AppTheme.blue, size: 18),
              const SizedBox(width: 8),
              Text('Лист ожидания: ${waiting.length}',
                  style: TextStyle(
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
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: AppTheme.textSecondary),
                        color: AppTheme.cardRaised,
                        onSelected: (v) {
                          if (v == 'profile') _openProfile(p);
                          if (v == 'copy_phone') _copyPhone(p);
                          if (v == 'call') _callPlayer(p);
                          if (v == 'whatsapp') _whatsappPlayer(p);
                          if (v == 'to_main') _moveParticipant(p, 'registered');
                          if (v == 'moderation') _moveParticipant(p, 'pending');
                          if (v == 'remove') _removeOne(p);
                        },
                        itemBuilder: (_) => [
                          _popupItem(
                              'profile',
                              Icon(Icons.person_outline,
                                  size: 18, color: AppTheme.textSecondary),
                              'Просмотреть профиль',
                              AppTheme.textPrimary),
                          ..._phoneMenuItems(p),
                          if (canModify) ...[
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
                            _popupItem(
                                'remove',
                                Icon(Icons.delete_outline,
                                    size: 18, color: AppTheme.error),
                                'Удалить',
                                AppTheme.error),
                          ],
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
              Icon(Icons.schedule,
                  color: AppTheme.amber, size: 18),
              const SizedBox(width: 8),
              Text('На модерации: ${pending.length}',
                  style: TextStyle(
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
              icon: Icon(Icons.more_vert,
                  color: AppTheme.textSecondary),
              color: AppTheme.cardRaised,
              onSelected: (v) {
                if (v == 'profile') _openProfile(p);
                if (v == 'copy_phone') _copyPhone(p);
                if (v == 'call') _callPlayer(p);
                if (v == 'whatsapp') _whatsappPlayer(p);
                if (v == 'approve') _approveOne(p);
                if (v == 'waitlist') _moveParticipant(p, 'waiting');
                if (v == 'reject') _rejectOne(p);
              },
              itemBuilder: (_) => [
                _popupItem('profile',
                    Icon(Icons.person_outline,
                        size: 18, color: AppTheme.textSecondary),
                    'Просмотреть профиль', AppTheme.textPrimary),
                ..._phoneMenuItems(p),
                _popupItem('approve',
                    const Icon(Icons.check_circle,
                        size: 18, color: AppTheme.accent),
                    'Одобрить', AppTheme.accent),
                _popupItem('waitlist',
                    Icon(Icons.hourglass_bottom,
                        size: 18, color: AppTheme.blue),
                    'Переместить в лист ожидания', AppTheme.textPrimary),
                _popupItem('reject',
                    Icon(Icons.cancel, size: 18, color: AppTheme.error),
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: AppTheme.textSecondary),
            color: AppTheme.cardRaised,
            onSelected: (v) {
              if (v == 'profile') _openProfile(p);
              if (v == 'copy_phone') _copyPhone(p);
              if (v == 'call') _callPlayer(p);
              if (v == 'whatsapp') _whatsappPlayer(p);
              if (v == 'replace') _openReplacePlayer(p);
              if (v == 'to_moderation') _moveParticipant(p, 'pending');
              if (v == 'waitlist') _moveParticipant(p, 'waiting');
              if (v == 'remove') _removeOne(p);
            },
            itemBuilder: (_) => [
              _popupItem('profile',
                  Icon(Icons.person_outline,
                      size: 18, color: AppTheme.textSecondary),
                  'Просмотреть профиль', AppTheme.textPrimary),
              ..._phoneMenuItems(p),
              // Действия изменения состава — только когда это разрешено.
              if (canModify) ...[
                _popupItem('replace',
                    Icon(Icons.swap_horiz,
                        size: 18, color: AppTheme.textSecondary),
                    'Заменить', AppTheme.textPrimary),
                _popupItem('to_moderation',
                    const Icon(Icons.how_to_reg,
                        size: 18, color: AppTheme.accent),
                    'Переместить в модерацию', AppTheme.textPrimary),
                _popupItem('waitlist',
                    Icon(Icons.hourglass_bottom,
                        size: 18, color: AppTheme.blue),
                    'Переместить в лист ожидания', AppTheme.textPrimary),
                _popupItem('remove',
                    Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.error),
                    'Удалить', AppTheme.error),
              ],
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
              Icon(Icons.hourglass_top, color: AppTheme.blue, size: 18),
              const SizedBox(width: 8),
              Text('Пар в листе ожидания: ${teams.length}',
                  style: TextStyle(
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
              Icon(Icons.schedule,
                  color: AppTheme.amber, size: 18),
              const SizedBox(width: 8),
              Text('Пар на модерации: ${teams.length}',
                  style: TextStyle(
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
            Divider(color: AppTheme.divider, height: 14),
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
                  child: Text('Отклонить',
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
                  child: Text('Удалить пару',
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
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                if (pending > 0) ...[
                  const SizedBox(height: 2),
                  Text('На модерации: $pending',
                      style: TextStyle(
                          color: AppTheme.amber, fontSize: 12)),
                ],
                if (isFull) ...[
                  const SizedBox(height: 2),
                  Text('Лимит участников достигнут',
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
                style: TextStyle(color: AppTheme.textSecondary)),
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
        border: Border.all(color: const Color(0xFF2A3330)),
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
                  style: TextStyle(
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
                  style: TextStyle(
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
    // Телефон убран из строки (не влезал на широких экранах) — перенесён в
    // меню «три точки» (см. _phoneMenuItems).

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(p.name,
                  style: TextStyle(
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
              Icon(Icons.shield_outlined,
                  size: 14, color: AppTheme.textDim),
          ],
        ),
        if (pieces.isNotEmpty)
          Text(pieces.join(' · '),
              style: TextStyle(
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
            style: TextStyle(
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

  /// Пункты меню для телефона: сам номер (тап = копировать) + Позвонить + WhatsApp.
  /// Используется во всех меню участников. Пусто, если телефона нет.
  List<PopupMenuItem<String>> _phoneMenuItems(AdminParticipant p) {
    if ((p.phone ?? '').isEmpty) return [];
    return [
      _popupItem(
        'copy_phone',
        Icon(Icons.phone_outlined, size: 18, color: AppTheme.textSecondary),
        _formatPhone(p.phone),
        AppTheme.textSecondary),
      _popupItem(
        'call',
        const Icon(Icons.call, size: 18, color: AppTheme.accent),
        'Позвонить', AppTheme.textPrimary),
      _popupItem(
        'whatsapp',
        const FaIcon(FontAwesomeIcons.whatsapp, size: 17, color: Color(0xFF25D366)),
        'WhatsApp', AppTheme.textPrimary),
    ];
  }

  Future<void> _copyPhone(AdminParticipant p) async {
    final phone = _formatPhone(p.phone);
    if (phone.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) await showAppAlert(context, 'Номер скопирован: $phone');
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
    if (selected == null || !mounted) return;

    // Текст показываем перед отправкой: приглашение уходит пушем,
    // и организатор часто хочет добавить своё — время, корт, условия.
    final text = await showModalBottomSheet<({String title, String body})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _InviteTextSheet(
        playerName: selected.name,
        defaultTitle: _inviteDefaultTitle,
        defaultBody: _inviteDefaultBody,
      ),
    );
    if (text == null) return;

    await _runAction(
      () => context.read<AdminService>().invitePlayer(
            widget.tournamentId,
            selected.id,
            title: text.title,
            body: text.body,
          ),
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
              Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_matchesError!,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppTheme.textSecondary)),
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
                children: [
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
            _buildGroupTabs(r.groups, withOverall: r.overall.isNotEmpty),
          ],
          if (r.overall.isNotEmpty && _showOverallTable) ...[
            const SizedBox(height: 12),
            _buildOverallCard(r.overall),
          ] else if (selectedGroup != null) ...[
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
                Row(
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
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                if (!ready) ...[
                  const SizedBox(height: 8),
                  Text(
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

  Widget _buildGroupTabs(List<AdminMatchGroup> groups, {bool withOverall = false}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (withOverall) Expanded(child: _groupTabBtn('Общая', -1)),
          for (var i = 0; i < groups.length; i++)
            Expanded(child: _groupTabBtn(groups[i].name, i)),
        ],
      ),
    );
  }

  /// [idx] = -1 — общая таблица.
  Widget _groupTabBtn(String label, int idx) {
    final isOverall = idx < 0;
    final isActive =
        isOverall ? _showOverallTable : (!_showOverallTable && _selectedGroupIdx == idx);
    return GestureDetector(
      onTap: () => setState(() {
        _showOverallTable = isOverall;
        if (!isOverall) _selectedGroupIdx = idx;
      }),
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
                  style: TextStyle(
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
                label: Text(_nextRoundLabel()),
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
          if (s.canRebuildRound) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _actionBusy ? null : _rebuildLastRound,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Пересобрать раунд'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Если поправили счёт прошлого раунда — этот собран по старым данным.',
              style: TextStyle(color: AppTheme.textDim, fontSize: 11),
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
          if (s.canFinishEarly) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _actionBusy ? null : _finishEarly,
                icon: Icon(
                    (_matches?.playoff?.hasPlayoff ?? false)
                        ? Icons.emoji_events_outlined
                        : Icons.flag_outlined,
                    size: 18),
                label: Text((_matches?.playoff?.hasPlayoff ?? false)
                    ? 'Перейти в плей-офф'
                    : 'Закончить турнир сейчас'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  side: const BorderSide(color: AppTheme.accent),
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

  /// Мексикано: досрочно завершить / перейти в плей-офф (не доигрывая раунды).
  Future<void> _finishEarly() async {
    if (_actionBusy) return;
    final hasPlayoff = _matches?.playoff?.hasPlayoff ?? false;
    final ok = await _confirm(
      title: hasPlayoff ? 'Перейти в плей-офф?' : 'Закончить турнир?',
      message: hasPlayoff
          ? 'Отборочный этап завершится досрочно, оставшиеся раунды не будут сыграны. Плей-офф соберётся по текущей таблице.'
          : 'Турнир завершится сейчас. Оставшиеся раунды не будут сыграны, рейтинг начислится по текущей таблице.',
      okText: hasPlayoff ? 'В плей-офф' : 'Завершить',
    );
    if (!ok) return;
    setState(() {
      _actionBusy = true;
      _actionLabel =
          hasPlayoff ? 'Генерируем плей-офф...' : 'Завершаем турнир...';
    });
    try {
      await context
          .read<AdminService>()
          .mexicanoFinishEarly(widget.tournamentId);
      if (!mounted) return;
      try {
        final t = await context
            .read<AdminService>()
            .getTournamentDetail(widget.tournamentId);
        if (mounted) {
          _applyToForm(t);
          setState(() => _t = t);
        }
      } catch (_) {}
      _matches = null;
      await _loadMatches();
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  /// Пересобрать последний раунд: удалить и построить заново из текущей
  /// таблицы. Нужно, когда счёт прошлого раунда исправили уже после
  /// генерации следующего.
  Future<void> _rebuildLastRound() async {
    if (_actionBusy) return;
    final admin = context.read<AdminService>();
    final ok = await _confirm(
      title: 'Пересобрать последний раунд?',
      message: 'Составы будут пересчитаны по текущим результатам. '
          'Счёт, введённый в этом раунде, будет удалён.',
      okText: 'Пересобрать',
      destructive: true,
    );
    if (!ok) return;

    setState(() {
      _actionBusy = true;
      _actionLabel = 'Пересобираем раунд...';
    });
    try {
      final fresh = await admin.rebuildLastRound(widget.tournamentId);
      if (!mounted) return;
      setState(() => _matches = fresh);
      await showAppAlert(context, 'Раунд пересобран по текущим результатам.');
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

  /// Общая таблица всех групп: по ней идёт посев в плей-офф при трёх группах.
  Widget _buildOverallCard(List<AdminLeaderboardRow> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Общая таблица',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Места 1–4 ждут соперников в полуфинале, 5–12 играют четвертьфинал.',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          _buildLeaderboard(rows),
          const SizedBox(height: 10),
          _buildShareStandingsButton(rows),
        ],
      ),
    );
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
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
                Text(
                  '$played / $total',
                  style: TextStyle(
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
            const SizedBox(height: 10),
            _buildShareStandingsButton(g.leaderboard),
            const SizedBox(height: 12),
          ],
          ...g.rounds.map(_buildRoundBlock),
        ],
      ),
    );
  }

  /// Кнопка «Выгрузить картинкой» — открывает превью таблицы для соцсетей.
  Widget _buildShareStandingsButton(List<AdminLeaderboardRow> rows) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TournamentStandingsShareScreen(
            tournamentId: widget.tournamentId,
            tournamentName: _t?.name ?? widget.tournamentName,
            type: _matches?.type ?? _t?.type ?? 'americano',
            typeName: _t?.typeName ?? '',
            startDate: _t?.startDate,
            clubName: _t?.club?.name,
            clubLogo: _t?.club?.logo,
            rows: rows,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ios_share, color: AppTheme.accent, size: 17),
            const SizedBox(width: 8),
            Text('Выгрузить картинкой',
                style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800)),
          ],
        ),
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
      // Горизонтальный скролл при нехватке ширины / крупном шрифте.
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
                4: IntrinsicColumnWidth(),
                5: IntrinsicColumnWidth(),
                6: IntrinsicColumnWidth(),
                7: IntrinsicColumnWidth(),
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
                  _flexHdr('Забито'),
                  _flexHdr('Пропущено'),
                  _flexHdr('Разница'),
                  _flexHdr('Матчей'),
                  _flexHdr('Среднее',
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.fromLTRB(6, 8, 4, 8)),
                ]),
                for (final p in rows) _flexLeaderRow(p),
              ],
            ),
          ),
        ),
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
        style: TextStyle(
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
    final diff = p.pointsFor - p.pointsAgainst;
    final matches = p.matchesPlayed ?? 0;
    // Среднее = забито ÷ матчей (как в вебе).
    final avg = p.avgPoints ?? (matches > 0 ? p.pointsFor / matches : 0.0);
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

    final numStyle = TextStyle(
        color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600);

    // Парная строка: показываем обоих игроков с аватарами на двух строках.
    final pair = (p.players != null && p.players!.length == 2) ? p.players! : null;

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
        pair == null
            ? _AdminLeaderAvatar(url: p.avatarUrl, name: p.name, size: 24)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final pl in pair)
                    SizedBox(
                      height: 26,
                      child: Center(
                        child: _AdminLeaderAvatar(
                            url: pl.avatarUrl, name: pl.name, size: 20),
                      ),
                    ),
                ],
              ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      cell(
        pair == null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(p.name,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (p.verified) ...[
                    const SizedBox(width: 5),
                    VerifiedBadge(size: 12, userId: p.id, playerName: p.name),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final pl in pair)
                    SizedBox(
                      height: 26,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(pl.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (pl.verified) ...[
                            const SizedBox(width: 5),
                            VerifiedBadge(
                                size: 12,
                                userId: pl.id,
                                playerName: pl.name),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
        alignment: Alignment.centerLeft,
      ),
      // Забито
      cell(Text('${p.pointsFor}',
          style: const TextStyle(
              color: Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.w700))),
      // Пропущено
      cell(Text('${p.pointsAgainst}',
          style: const TextStyle(
              color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w700))),
      // Разница
      cell(Text(diff > 0 ? '+$diff' : '$diff',
          style: TextStyle(
              color: diff > 0
                  ? const Color(0xFF22C55E)
                  : diff < 0
                      ? const Color(0xFFEF4444)
                      : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700))),
      // Матчей
      cell(Text('$matches', style: numStyle)),
      // Среднее
      cell(
        Text(avg.toStringAsFixed(2),
            style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 13,
                fontWeight: FontWeight.w800)),
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

  /// Подпись последней колонки таблицы — той, по которой считается место.
  ///
  /// У эскалеры зачёт бывает двух видов. При зачёте по баллам за позиции
  /// это своя метрика, её и называем. При зачёте по очкам там сумма
  /// забитых, но «ЗАБИТО» дублировало бы колонку «Р» (забито:пропущено),
  /// поэтому оставляем привычные «ОЧКИ».
  String _pointsColumnLabel() {
    if (_matches?.type != 'escalera') return 'ОЧКИ';
    return _matches?.standingsMode == 'points' ? 'БАЛЛЫ' : 'ОЧКИ';
  }

  TableRow _leaderboardHeaderRow() {
    final hdrStyle = TextStyle(
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
        hdr(_pointsColumnLabel(),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${p.position}',
                  style: TextStyle(
                      color: posColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              // Только в общей таблице: куда ведёт это место.
              if (p.playoffSlot != null)
                Text(
                  p.playoffSlot == 'semifinal' ? 'ПФ' : 'ЧФ',
                  style: TextStyle(
                    color: p.playoffSlot == 'semifinal'
                        ? AppTheme.amber
                        : AppTheme.textDim,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(2, 10, 6, 10),
          alignment: Alignment.centerLeft,
        ),
        cell(
          _AdminLeaderAvatar(url: p.avatarUrl, name: p.name, size: 24),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        cell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(p.name,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2)),
              ),
              if (p.verified) ...[
                const SizedBox(width: 5),
                VerifiedBadge(size: 12, userId: p.id, playerName: p.name),
              ],
              if (p.groupName != null) ...[
                const SizedBox(width: 6),
                Text(
                  p.groupName!.replaceFirst('Группа ', ''),
                  style: TextStyle(color: AppTheme.textDim, fontSize: 10.5),
                ),
              ],
            ],
          ),
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
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 11))),
        cell(Text('${p.winPercent}%',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600))),
        cell(
          // Очки и бонус за результат одной строкой: «45 +6». Бонус приходит
          // только у Ladder в зачёте по сумме очков, иначе он нулевой.
          Text.rich(
            TextSpan(children: [
              TextSpan(text: '${p.totalPoints}'),
              if (p.bonusPoints > 0)
                TextSpan(
                  text: ' +${p.bonusPoints}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ]),
            maxLines: 1,
            style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 13,
                fontWeight: FontWeight.w800),
          ),
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
    final hdrStyle = TextStyle(
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

    final statSecondary = TextStyle(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(p.name,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2)),
              ),
              if (p.verified) ...[
                const SizedBox(width: 5),
                VerifiedBadge(size: 12, userId: p.id, playerName: p.name),
              ],
            ],
          ),
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

  /// Подпись кнопки генерации. У эскалеры называем номер раунда — так админ
  /// понимает, что получит, а не просто «следующий».
  String _nextRoundLabel() {
    if (_matches?.type != 'escalera') return 'Сгенерировать следующий раунд';
    final rounds = _matches?.groups.isNotEmpty == true
        ? _matches!.groups.first.rounds.length
        : 0;
    return 'Сгенерировать раунд ${rounds + 1}';
  }

  /// Матчи раунда с разделителем между кортами.
  ///
  /// В эскалере на корте три матча подряд: без заголовка корта они читаются
  /// как шесть независимых пар. Для остальных форматов, где на корте один
  /// матч, заголовок не нужен — там список остаётся плоским.
  List<Widget> _matchesGroupedByCourt(AdminMatchRound round) {
    final grouped = _matches?.type == 'escalera';
    if (!grouped) {
      return round.matches.map((m) => _buildMatchTile(m)).toList();
    }

    final out = <Widget>[];
    int? currentCourt;

    for (final m in round.matches) {
      if (m.courtNumber != currentCourt) {
        currentCourt = m.courtNumber;
        out.add(Padding(
          padding: EdgeInsets.only(top: out.isEmpty ? 0 : 14, bottom: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Корт ${m.courtNumber}',
                    style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: AppTheme.border),
              ),
            ],
          ),
        ));
      }
      out.add(_buildMatchTile(m));
    }

    return out;
  }

  Widget _buildRoundBlock(AdminMatchRound round) {
    // Round Robin, Americano Flex, Король корта и Bali — раундов много,
    // сворачиваем завершённые, чтобы не листать «газету». Активный («идёт»)
    // раскрыт по умолчанию; при генерации нового раунда предыдущий сам
    // свернётся (стал completed). Остальные типы — всегда раскрыты.
    final collapsible = _matches?.type == 'round_robin'
        || _matches?.type == 'americano_flex'
        || _matches?.type == 'king_of_court'
        || _matches?.type == 'bali_koc'
        || _matches?.type == 'just_padel_it'
        || _matches?.type == 'escalera';
    final expanded = !collapsible
        ? true
        : (_rrRoundExpanded[round.id] ?? (round.status == 'in_progress'));

    final header = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('Раунд ${round.roundNumber}',
              style: TextStyle(
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
            ..._matchesGroupedByCourt(round),
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
                  child: Row(
                    children: [
                      Text('Корт ${m.courtNumber}',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      // Ladder: на корте три матча подряд, без номера они
                      // сливаются в одну кашу.
                      if (m.matchNumber != null)
                        Text(' · Матч ${m.matchNumber}',
                            style: TextStyle(
                                color: AppTheme.textDim, fontSize: 11)),
                    ],
                  ),
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
          children: [
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
      if (b == 'Четвертьфинал') return 0;
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
        border: Border.all(color: const Color(0xFF2A3330)),
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
                child: Icon(Icons.emoji_events_rounded,
                    color: AppTheme.amber, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ),
              Text('$played / $total',
                  style: TextStyle(
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
    if (base == 'Четвертьфинал') {
      label = 'ЧЕТВЕРТЬФИНАЛ';
    } else if (base == 'Полуфинал') {
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
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              if (sub != null) ...[
                const SizedBox(width: 6),
                Text('· $sub',
                    style: TextStyle(
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
            border: Border.all(color: const Color(0xFF2A3330)),
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
                          style: TextStyle(
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
    final isJpi = _matches?.type == 'just_padel_it';
    final isMexicano = _matches?.type == 'mexicano';
    final isEscalera = _matches?.type == 'escalera';

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
        // У плей-офф, KOC, Bali, Round Robin и JPI ничья запрещена. У team — в
        // плей-офф нельзя, в групповом этапе можно (ничья = одинаковые геймы).
        requireDifferent: isPlayoff || isKoc || isBali || isRoundRobin || isJpi,
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
        if (isMexicano) {
          await context.read<AdminService>().saveMexicanoPlayoffScore(
                tournamentId,
                matchId,
                team1Score: result.score1,
                team2Score: result.score2,
              );
        } else {
          await context.read<AdminService>().saveAmericanoPlayoffScore(
                tournamentId,
                matchId,
                team1Score: result.score1,
                team2Score: result.score2,
                isUpdate: isUpdate,
              );
        }
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
      } else if (isJpi) {
        await context.read<AdminService>().saveJpiScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
            );
      } else if (isEscalera) {
        await context.read<AdminService>().saveEscaleraScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
            );
      } else if (isMexicano) {
        await context.read<AdminService>().saveMexicanoScore(
              tournamentId,
              matchId,
              team1Score: result.score1,
              team2Score: result.score2,
              isUpdate: isUpdate,
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
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Center(
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
                    style: TextStyle(
                        color: AppTheme.error, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppTheme.cardRaised),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Отмена',
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
                style: TextStyle(
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
              style: TextStyle(
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
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                autofocus: true,
                style: TextStyle(color: AppTheme.textPrimary),
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: 'Телефон или имя (от 2 символов)',
                  hintStyle: TextStyle(color: AppTheme.textDim),
                  prefixIcon:
                      Icon(Icons.search, color: AppTheme.textSecondary),
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
            style: TextStyle(color: AppTheme.error)),
      );
    }
    if (_ctrl.text.trim().length < 2) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Введите имя или телефон для поиска',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
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
                      style: TextStyle(
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
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text(
                        [
                          if (p.level != null) 'L${p.level!.toStringAsFixed(2)}',
                          if (p.rating != null) '${p.rating}',
                          if ((p.phone ?? '').isNotEmpty) p.phone!,
                        ].join(' · '),
                        style: TextStyle(
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

/// Текст приглашения перед отправкой.
///
/// Приглашение уходит пушем, поэтому организатору нужно видеть и править
/// формулировку — время, корт, условия. Пустые поля не отправляются:
/// сервер подставит свою заготовку.
class _InviteTextSheet extends StatefulWidget {
  const _InviteTextSheet({
    required this.playerName,
    required this.defaultTitle,
    required this.defaultBody,
  });

  final String playerName;
  final String defaultTitle;
  final String defaultBody;

  @override
  State<_InviteTextSheet> createState() => _InviteTextSheetState();
}

class _InviteTextSheetState extends State<_InviteTextSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.defaultTitle);
  late final TextEditingController _body =
      TextEditingController(text: widget.defaultBody);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );

  Widget _field(TextEditingController controller,
      {int maxLength = 100, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        counterStyle:
            TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        filled: true,
        fillColor: AppTheme.cardRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Приглашение · ${widget.playerName}',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _label('Заголовок'),
            _field(_title),
            _label('Текст'),
            _field(_body, maxLength: 250, maxLines: 3),
            const SizedBox(height: 4),
            // На телефоне пуш обрезается — длинный текст увидят не целиком.
            Text('Как увидит игрок',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0.6)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Padel KZ · сейчас',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(_title.text.isEmpty ? '—' : _title.text,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_body.text.isEmpty ? '—' : _body.text,
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _title.text = widget.defaultTitle;
                    _body.text = widget.defaultBody;
                    setState(() {});
                  },
                  child: Text('Вернуть заготовку',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(
                      context, (title: _title.text, body: _body.text)),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Отправить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
