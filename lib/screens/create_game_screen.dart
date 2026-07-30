import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';
import '../widgets/app_back_button.dart';
import '../utils/app_alert.dart';
import '../l10n/app_localizations.dart';
import 'game_detail_screen.dart';

/// Экран создания игры — форма со всеми полями (F3).
class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  GameClub? _club;
  DateTime? _date;
  TimeOfDay? _time;

  int _durationMin = 90;
  String _type = 'rated';
  String _visibility = 'public';
  String _format = 'sets';

  // sets
  bool _tiebreak = false;

  // points
  String _pointsMode = 'first_to';
  final TextEditingController _pointsTargetController = TextEditingController();
  final TextEditingController _pointsCapController = TextEditingController();

  // americano
  String _amSub = 'by_points';
  final TextEditingController _amTargetController = TextEditingController();

  // rating range
  double? _ratingMin;
  double? _ratingMax;

  // price / description
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isCreating = false;

  static const List<double> _levelValues = [
    1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75,
    3.0, 3.25, 3.5, 3.75, 4.0, 4.25, 4.5, 4.75,
    5.0, 5.25, 5.5, 5.75,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadClubs();
    });
  }

  @override
  void dispose() {
    _pointsTargetController.dispose();
    _pointsCapController.dispose();
    _amTargetController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.challengeMonthJan, l10n.challengeMonthFeb, l10n.challengeMonthMar,
      l10n.challengeMonthApr, l10n.challengeMonthMay, l10n.challengeMonthJun,
      l10n.challengeMonthJul, l10n.challengeMonthAug, l10n.challengeMonthSep,
      l10n.challengeMonthOct, l10n.challengeMonthNov, l10n.challengeMonthDec,
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _validate() {
    if (_club == null || _date == null || _time == null) return false;
    if (_format == 'points' && _pointsMode == 'first_to') {
      if (int.tryParse(_pointsTargetController.text.trim()) == null) return false;
    }
    if (_format == 'americano') {
      if (int.tryParse(_amTargetController.text.trim()) == null) return false;
    }
    return true;
  }

  Map<String, dynamic>? _buildFormatMeta() {
    switch (_format) {
      case 'sets':
        return {'tiebreak': _tiebreak};
      case 'points':
        final meta = <String, dynamic>{'points_mode': _pointsMode};
        if (_pointsMode == 'first_to') {
          meta['points_target'] = int.tryParse(_pointsTargetController.text.trim());
        }
        final cap = int.tryParse(_pointsCapController.text.trim());
        if (cap != null) meta['points_cap'] = cap;
        return meta;
      case 'americano':
        return {
          'sub': _amSub,
          'target': int.tryParse(_amTargetController.text.trim()),
        };
      default:
        return null;
    }
  }

  Future<void> _create() async {
    if (!_validate()) {
      showAppAlert(
        context,
        AppLocalizations.of(context)!.gameCreateValidationError,
        isError: true,
      );
      return;
    }

    final startsAt = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );
    final endsAt = startsAt.add(Duration(minutes: _durationMin));
    final formatMeta = _buildFormatMeta();

    final data = <String, dynamic>{
      'club_id': _club!.id,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'type': _type,
      'visibility': _visibility,
      'format': _format,
      'format_meta': ?formatMeta,
      if (_ratingMin != null) 'rating_min': _ratingMin,
      if (_ratingMax != null) 'rating_max': _ratingMax,
    };

    final price = int.tryParse(_priceController.text.trim());
    if (price != null) data['price'] = price;

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) data['description'] = description;

    setState(() => _isCreating = true);
    final result = await context.read<GameProvider>().createGame(data);
    if (!mounted) return;
    setState(() => _isCreating = false);

    if (result.success && result.game != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: result.game!.id)),
      );
    } else {
      showAppAlert(context, result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.gameCreateTitle,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(l10n.gameFieldClub),
                    const SizedBox(height: 8),
                    _buildClubDropdown(),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _dateTimeSection(
                            label: l10n.gameFieldDate,
                            icon: Icons.calendar_today,
                            text: _date != null ? _formatDate(_date!) : l10n.gameFieldDate,
                            hasValue: _date != null,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateTimeSection(
                            label: l10n.gameFieldTime,
                            icon: Icons.access_time,
                            text: _time != null ? _formatTime(_time!) : l10n.gameFieldTime,
                            hasValue: _time != null,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _sectionLabel(l10n.gameFieldDuration),
                    const SizedBox(height: 8),
                    Row(
                      children: [60, 90, 120].map((min) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: min != 120 ? 12 : 0),
                            child: _chip(
                              label: l10n.gameDurationMin(min),
                              selected: _durationMin == min,
                              onTap: () => setState(() => _durationMin = min),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    _sectionLabel(l10n.gameFieldType),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _chip(label: l10n.gameTypeRated, selected: _type == 'rated', onTap: () => setState(() => _type = 'rated'))),
                        const SizedBox(width: 12),
                        Expanded(child: _chip(label: l10n.gameTypeFriendly, selected: _type == 'friendly', onTap: () => setState(() => _type = 'friendly'))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _sectionLabel(l10n.gameFieldVisibility),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _chip(label: l10n.gameVisibilityPublic, selected: _visibility == 'public', onTap: () => setState(() => _visibility = 'public'))),
                        const SizedBox(width: 12),
                        Expanded(child: _chip(label: l10n.gameVisibilityPrivate, selected: _visibility == 'private', onTap: () => setState(() => _visibility = 'private'))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _sectionLabel(l10n.gameFieldFormat),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _chip(label: l10n.gameFormatSets, selected: _format == 'sets', onTap: () => setState(() => _format = 'sets'))),
                        const SizedBox(width: 8),
                        Expanded(child: _chip(label: l10n.gameFormatPoints, selected: _format == 'points', onTap: () => setState(() => _format = 'points'))),
                        const SizedBox(width: 8),
                        Expanded(child: _chip(label: l10n.gameFormatAmericano, selected: _format == 'americano', onTap: () => setState(() => _format = 'americano'))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildFormatMetaSection(l10n),

                    _sectionLabel(l10n.gameFieldRatingRange),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildLevelDropdown(
                          value: _ratingMin,
                          onChanged: (v) => setState(() => _ratingMin = v),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildLevelDropdown(
                          value: _ratingMax,
                          onChanged: (v) => setState(() => _ratingMax = v),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _sectionLabel(l10n.gameFieldPrice),
                    const SizedBox(height: 8),
                    _textFieldContainer(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormattersDigitsOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _sectionLabel(l10n.gameFieldDescription),
                    const SizedBox(height: 8),
                    _textFieldContainer(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 1000,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GestureDetector(
                onTap: _isCreating ? null : _create,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isCreating ? AppTheme.accent.withAlpha(128) : AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _isCreating
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          l10n.gameCreateSubmit,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatMetaSection(AppLocalizations l10n) {
    switch (_format) {
      case 'sets':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.gameFieldTiebreak,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: _tiebreak,
                    activeThumbColor: AppTheme.accent,
                    onChanged: (v) => setState(() => _tiebreak = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      case 'points':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(l10n.gamePointsMode),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _chip(label: l10n.gamePointsFirstTo, selected: _pointsMode == 'first_to', onTap: () => setState(() => _pointsMode = 'first_to'))),
                const SizedBox(width: 12),
                Expanded(child: _chip(label: l10n.gamePointsTotal, selected: _pointsMode == 'total', onTap: () => setState(() => _pointsMode = 'total'))),
              ],
            ),
            const SizedBox(height: 16),
            if (_pointsMode == 'first_to') ...[
              _sectionLabel(l10n.gamePointsTarget),
              const SizedBox(height: 8),
              _textFieldContainer(controller: _pointsTargetController, keyboardType: TextInputType.number, inputFormattersDigitsOnly: true),
              const SizedBox(height: 16),
            ],
            _sectionLabel(l10n.gamePointsCap),
            const SizedBox(height: 8),
            _textFieldContainer(controller: _pointsCapController, keyboardType: TextInputType.number, inputFormattersDigitsOnly: true),
            const SizedBox(height: 16),
          ],
        );
      case 'americano':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(l10n.gameAmSub),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _chip(label: l10n.gameAmBySets, selected: _amSub == 'by_sets', onTap: () => setState(() => _amSub = 'by_sets'))),
                const SizedBox(width: 8),
                Expanded(child: _chip(label: l10n.gameAmByTiebreak, selected: _amSub == 'by_tiebreak', onTap: () => setState(() => _amSub = 'by_tiebreak'))),
                const SizedBox(width: 8),
                Expanded(child: _chip(label: l10n.gameAmByPoints, selected: _amSub == 'by_points', onTap: () => setState(() => _amSub = 'by_points'))),
              ],
            ),
            const SizedBox(height: 16),
            _sectionLabel(l10n.gameAmTarget),
            const SizedBox(height: 8),
            _textFieldContainer(controller: _amTargetController, keyboardType: TextInputType.number, inputFormattersDigitsOnly: true),
            const SizedBox(height: 16),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13));
  }

  Widget _dateTimeSection({
    required String label,
    required IconData icon,
    required String text,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: hasValue ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClubDropdown() {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GameClub?>(
              value: _club,
              isExpanded: true,
              dropdownColor: AppTheme.card,
              hint: Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.gameFieldClub,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
              items: provider.clubs.map((c) => DropdownMenuItem<GameClub?>(
                value: c,
                child: Text(
                  c.name,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              onChanged: (v) => setState(() => _club = v),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelDropdown({required double? value, required ValueChanged<double?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double?>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.card,
          icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          items: [
            DropdownMenuItem<double?>(
              value: null,
              child: Text(
                AppLocalizations.of(context)!.gameRatingAny,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
            ..._levelValues.map((lvl) => DropdownMenuItem<double?>(
              value: lvl,
              child: Text(
                lvl.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), ''),
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              ),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textFieldContainer({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool inputFormattersDigitsOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormattersDigitsOnly
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          counterText: '',
        ),
      ),
    );
  }

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withAlpha(25) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.accent : const Color(0xFF2A3330),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
