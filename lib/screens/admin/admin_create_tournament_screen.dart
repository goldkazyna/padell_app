import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';
import 'admin_tournament_detail_screen.dart';

/// Этап 4 — создание турнира. На этом этапе поддерживается только
/// Король корта. Когда понадобятся другие типы — добавляем визуальный
/// выбор типа и расширяем форму.
class AdminCreateTournamentScreen extends StatefulWidget {
  final int clubId;
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
  final _telegramUrl = TextEditingController();
  final _maxParticipants = TextEditingController(text: '16');
  final _price = TextEditingController();
  final _reserveCount = TextEditingController(text: '0');
  final _roundsCount = TextEditingController(text: '7');

  String _type = 'americano'; // americano / king_of_court / bali_koc / team
  DateTime? _startDate;
  double _minLevel = 1.5;
  double _maxLevel = 4.0;
  String _status = 'open'; // draft / open

  // Поле Американо
  int _groupsCount = 1;
  bool _hasPlayoff = false;
  String _playoffType = 'final_only'; // final_only / semifinal_final
  String _playoffFormat = 'cross';
  bool _hasLowerBracket = false;
  bool _hasBronzeMatch = false;

  // Поля Team (Групповой + Плей-офф) — отдельный state, чтобы не путать с
  // Американо. По умолчанию 2 группы, выходят 2 пары.
  int _teamGroupsCount = 2;
  int _teamsAdvance = 2;
  bool _teamHasLowerBracket = false;
  bool _teamHasBronzeMatch = false;

  // Корты — кол-во вычисляется как ceil(max_participants / 4) (как в Web)
  late final List<TextEditingController> _courtNames =
      List.generate(32, (i) => TextEditingController(text: 'Корт ${i + 1}'));

  bool _saving = false;
  String? _saveLabel;

  int get _courtsCount {
    final maxP = int.tryParse(_maxParticipants.text.trim()) ?? 16;
    final n = (maxP / 4).ceil();
    return n.clamp(1, 32);
  }

  @override
  void initState() {
    super.initState();
    _maxParticipants.addListener(_onMaxOrGroupsChanged);
    _updateRoundsCount();
  }

  void _onMaxOrGroupsChanged() {
    _updateRoundsCount();
    if (mounted) setState(() {}); // пересчитать кол-во кортов
  }

  void _updateRoundsCount() {
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
    _telegramUrl.dispose();
    _maxParticipants.dispose();
    _price.dispose();
    _reserveCount.dispose();
    _roundsCount.dispose();
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
      await showAppAlert(context, 'Дата старта должна быть в будущем',
          title: 'Ошибка', isError: true);
      return;
    }
    if (_minLevel > _maxLevel) {
      await showAppAlert(context, 'Минимальный уровень больше максимального',
          title: 'Ошибка', isError: true);
      return;
    }
    final maxP = int.tryParse(_maxParticipants.text.trim());
    if (maxP == null || maxP < 2 || maxP > 128) {
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
      await showAppAlert(context, 'Цена должна быть числом',
          title: 'Ошибка', isError: true);
      return;
    }
    final reserve = int.tryParse(_reserveCount.text.trim()) ?? 0;
    if (reserve < 0 || reserve > 10) {
      await showAppAlert(context, 'Резервных игроков: 0–10',
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
      'telegram_registration_url': tgUrl.isEmpty ? null : tgUrl,
      'start_date': _startDate!.toIso8601String(),
      'min_level': _minLevel,
      'max_level': _maxLevel,
      'max_participants': maxP,
      'price': price,
      'status': _status,
      'courts': courts,
      'courts_count': _courtsCount,
      'reserve_count': reserve,
    };

    if (_type == 'americano') {
      body['groups_count'] = _groupsCount;
      final rounds = int.tryParse(_roundsCount.text.trim()) ?? 0;
      if (rounds < 1 || rounds > 30) {
        await showAppAlert(context,
            'Количество раундов: целое число от 1 до 30',
            title: 'Ошибка', isError: true);
        return;
      }
      body['rounds_count'] = rounds;
      body['has_playoff'] = _hasPlayoff;
      if (_hasPlayoff) {
        body['playoff_type'] = _playoffType;
        // Формат нужен: при 1 группе и final_only, либо при ≥2 групп и semifinal_final
        final needFormat =
            (_groupsCount == 1 && _playoffType == 'final_only') ||
                (_groupsCount >= 2 && _playoffType == 'semifinal_final');
        if (needFormat) body['playoff_format'] = _playoffFormat;
        body['has_lower_bracket'] = _hasLowerBracket;
        body['has_bronze_match'] = _hasBronzeMatch;
      }
    }

    if (_type == 'team') {
      body['groups_count'] = _teamGroupsCount;
      body['teams_advance'] = _teamsAdvance;
      body['has_lower_bracket'] = _teamHasLowerBracket;
      body['has_bronze_match'] = _teamHasBronzeMatch;
      // has_playoff на бэке будет принудительно true для team — не передаём.
    }

    setState(() {
      _saving = true;
      _saveLabel = 'Создаём турнир...';
    });

    try {
      final id = await context
          .read<AdminService>()
          .createTournament(widget.clubId, body);
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
                const Text(
                  'Создать турнир',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.clubName,
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

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _typeSelector(),
        const SizedBox(height: 12),
        _section(
          title: 'Основное',
          children: [
            _label('Название'),
            _textField(_name, hint: 'Например: Турнир выходного дня'),
            const SizedBox(height: 12),
            _label('Описание'),
            _textField(_description,
                hint: 'Можно оставить пустым', maxLines: 3),
            const SizedBox(height: 12),
            _label('Ссылка на чат в Telegram (для записи)'),
            _textField(_telegramUrl,
                hint: 'https://t.me/...',
                keyboardType: TextInputType.url),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Если указана — кнопка «Записаться» в карточке турнира будет вести в этот чат вместо записи через приложение.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            _label('Дата и время старта'),
            _dateField(),
          ],
        ),
        const SizedBox(height: 12),
        _section(
          title: 'Параметры',
          children: [
            _label('Уровень игроков'),
            _levelSliders(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Макс. участников (2–128)'),
                      _textField(
                        _maxParticipants,
                        hint: '16',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                      _textField(
                        _price,
                        hint: '0',
                        keyboardType:
                            const TextInputType.numberWithOptions(),
                      ),
                    ],
                  ),
                ),
              ],
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
            _label('Статус при создании'),
            _statusSelector(),
          ],
        ),
        if (_type == 'americano') ...[
          const SizedBox(height: 12),
          _americanoSection(),
        ],
        if (_type == 'team') ...[
          const SizedBox(height: 12),
          _teamSection(),
        ],
        const SizedBox(height: 12),
        _section(
          title: 'Корты',
          children: [
            Text(
              'Кол-во кортов: $_courtsCount  '
              '(автоматически: участников ÷ 4)',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < _courtsCount; i++) ...[
              _label('Корт ${i + 1}'),
              _textField(_courtNames[i], hint: 'Корт ${i + 1}'),
              if (i < _courtsCount - 1) const SizedBox(height: 8),
            ],
          ],
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
            child: const Text('Создать турнир',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
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
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() => _type = value);
            _updateRoundsCount();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.accent.withOpacity(0.12)
                  : AppTheme.card,
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
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            card(
              value: 'americano',
              title: 'Американо',
              subtitle: 'Группы, ротация партнёров',
              icon: Icons.shuffle_rounded,
            ),
            const SizedBox(width: 8),
            card(
              value: 'king_of_court',
              title: 'Король корта',
              subtitle: 'Ротация по кортам',
              icon: Icons.emoji_events_outlined,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            card(
              value: 'bali_koc',
              title: 'Король Корта (Bali)',
              subtitle: 'Фикс. пары, очки от корта',
              icon: Icons.groups_rounded,
            ),
            const SizedBox(width: 8),
            card(
              value: 'team',
              title: 'Групповой + Плей-офф',
              subtitle: 'Парный, выход в плей-офф',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _americanoSection() {
    return _section(
      title: 'Американо',
      children: [
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
        const Text(
          'Авто: игроков в группе − 1. Можно изменить вручную.',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _playoffSettings(),
      ],
    );
  }

  Widget _teamSection() {
    return _section(
      title: 'Групповой + Плей-офф',
      children: [
        const Text(
          'Фиксированные пары играют групповой этап, лучшие выходят в плей-офф (на вылет). Количество указано в парах.',
          style: TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _label('Количество групп'),
        _teamGroupsSelector(),
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
      ],
    );
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
              // 1 группа → только final_only
              if (n == 1 && _playoffType == 'semifinal_final') {
                _playoffType = 'final_only';
                _playoffFormat = 'cross';
              }
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
    if (_groupsCount == 1 && _playoffType == 'final_only') return true;
    if (_groupsCount >= 2 && _playoffType == 'semifinal_final') return true;
    return false;
  }

  Widget _playoffTypeSelector() {
    Widget btn(String value, String label) {
      final active = _playoffType == value;
      final allowed =
          value == 'final_only' || (value == 'semifinal_final' && _groupsCount >= 2);
      return Expanded(
        child: GestureDetector(
          onTap: !allowed
              ? null
              : () {
                  setState(() {
                    _playoffType = value;
                    // переинициализируем формат под новый набор
                    if (_groupsCount == 1 && value == 'final_only') {
                      _playoffFormat = 'cross';
                    } else if (_groupsCount >= 2 &&
                        value == 'semifinal_final') {
                      _playoffFormat = 'mix';
                    }
                  });
                },
          child: Opacity(
            opacity: allowed ? 1 : 0.4,
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
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textDim, fontSize: 13),
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

  Widget _levelSliders() {
    Widget row(String label, double value, ValueChanged<double> onChanged) {
      return Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label,
                style: const TextStyle(
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
              style: const TextStyle(
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

  String _fmtDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} $hh:$mi';
  }
}
