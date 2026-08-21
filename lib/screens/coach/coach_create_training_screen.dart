import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/training.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_primary_button.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';

/// Создание и правка тренировки: клуб, время, длительность, цена, места,
/// описание. С [training] экран открывается в режиме редактирования —
/// поля заполнены, сохранение уходит в update.
class CoachCreateTrainingScreen extends StatefulWidget {
  const CoachCreateTrainingScreen({super.key, this.training});

  final Training? training;

  @override
  State<CoachCreateTrainingScreen> createState() =>
      _CoachCreateTrainingScreenState();
}

class _CoachCreateTrainingScreenState extends State<CoachCreateTrainingScreen> {
  final _price = TextEditingController(text: '5000');
  final _capacity = TextEditingController(text: '4');
  final _description = TextEditingController();

  TrainingClub? _club;
  DateTime? _startsAt;
  int _duration = 60;

  bool _saving = false;

  bool get _isEdit => widget.training != null;

  @override
  void initState() {
    super.initState();
    final t = widget.training;
    if (t == null) return;

    _club = t.club;
    _price.text = '${t.price}';
    _capacity.text = '${t.capacity}';
    _description.text = t.description ?? '';
    _duration = t.durationMinutes;
    // startsAt приходит настенным временем «YYYY-MM-DD HH:MM» — разбираем
    // как локальное, иначе пикер сместит час на разницу с UTC.
    _startsAt = DateTime.tryParse(t.startsAt.replaceFirst(' ', 'T'));
  }

  @override
  void dispose() {
    _price.dispose();
    _capacity.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _startsAt ?? now.add(const Duration(days: 1));
    // Правим и уже прошедшее занятие (оно ждёт завершения), поэтому нижнюю
    // границу опускаем до его даты — иначе пикер падает на initialDate.
    final first = initial.isBefore(now) ? initial : now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          _startsAt ?? now.add(const Duration(hours: 2))),
    );
    if (time == null) return;

    setState(() {
      _startsAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_club?.id == null) {
      await showAppAlert(context, 'Выберите клуб', title: 'Ошибка', isError: true);
      return;
    }
    if (_startsAt == null) {
      await showAppAlert(context, 'Укажите дату и время',
          title: 'Ошибка', isError: true);
      return;
    }
    final capacity = int.tryParse(_capacity.text.trim()) ?? 0;
    if (capacity < 1 || capacity > 32) {
      await showAppAlert(context, 'Мест должно быть от 1 до 32',
          title: 'Ошибка', isError: true);
      return;
    }
    final price = int.tryParse(_price.text.trim()) ?? 0;

    setState(() => _saving = true);
    try {
      final service = context.read<TrainingService>();
      if (_isEdit) {
        await service.update(
          widget.training!.id,
          clubId: _club!.id!,
          startsAt: _formatForApi(_startsAt!),
          durationMinutes: _duration,
          price: price,
          capacity: capacity,
          description: _description.text.trim(),
        );
      } else {
        await service.create(
          clubId: _club!.id!,
          startsAt: _formatForApi(_startsAt!),
          durationMinutes: _duration,
          price: price,
          capacity: capacity,
          description: _description.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
      }
    }
  }

  /// Сервер ждёт настенное время «YYYY-MM-DD HH:MM» без часового пояса.
  String _formatForApi(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(_isEdit ? 'Редактирование' : 'Новая тренировка',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        _label('Клуб'),
                        _clubPicker(),
                        const SizedBox(height: 16),
                        _label('Дата и время'),
                        _dateTimeField(),
                        const SizedBox(height: 16),
                        _label('Длительность'),
                        _durationPicker(),
                        const SizedBox(height: 16),
                        _label('Цена, ₸'),
                        _numberField(_price, '5000'),
                        const SizedBox(height: 16),
                        _label('Максимум участников'),
                        _numberField(_capacity, '4'),
                        const SizedBox(height: 16),
                        _label('Описание (необязательно)'),
                        TextField(
                          controller: _description,
                          maxLines: 4,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: _inputDecoration('Например: работа над подачей'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: AppPrimaryButton(
                            label: _isEdit ? 'Сохранить' : 'Создать тренировку',
                            loading: _saving,
                            onPressed: _saving ? null : _save,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );

  /// Поле выбора клуба: открывает поиск, как при создании турнира.
  Widget _clubPicker() {
    final club = _club;

    return GestureDetector(
      onTap: _showClubPicker,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.apartment_outlined,
                size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                club == null
                    ? 'Выберите клуб'
                    : ((club.city ?? '').isEmpty
                        ? club.name
                        : '${club.name} · ${club.city}'),
                style: TextStyle(
                  color: club == null ? AppTheme.textDim : AppTheme.textPrimary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textDim, size: 18),
          ],
        ),
      ),
    );
  }

  /// Поиск клуба с задержкой 400 мс — тем же приёмом, что выбор площадки
  /// при создании турнира.
  Future<void> _showClubPicker() async {
    final service = context.read<TrainingService>();

    final picked = await showModalBottomSheet<TrainingClub>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final searchCtrl = TextEditingController();
        Timer? debounce;
        List<TrainingClub> results = const [];
        bool loading = true;
        String? error;
        bool started = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> runSearch(String query) async {
              setSheetState(() => loading = true);
              try {
                final found = await service.getCoachClubs(query: query);
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

            if (!started) {
              started = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => runSearch(''));
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            color: AppTheme.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Клуб',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        onChanged: (value) {
                          debounce?.cancel();
                          debounce = Timer(
                            const Duration(milliseconds: 400),
                            () => runSearch(value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Название или город',
                          hintStyle:
                              TextStyle(color: AppTheme.textDim, fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.textDim, size: 20),
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
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 320,
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : error != null
                                ? Center(
                                    child: Text(error!,
                                        style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 13)),
                                  )
                                : results.isEmpty
                                    ? Center(
                                        child: Text('Ничего не нашлось',
                                            style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13)),
                                      )
                                    : ListView.separated(
                                        itemCount: results.length,
                                        separatorBuilder: (_, __) => Divider(
                                            height: 1, color: AppTheme.border),
                                        itemBuilder: (_, i) {
                                          final c = results[i];
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(c.name,
                                                style: TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 14)),
                                            subtitle: (c.city ?? '').isEmpty
                                                ? null
                                                : Text(c.city!,
                                                    style: TextStyle(
                                                        color: AppTheme.textDim,
                                                        fontSize: 12)),
                                            onTap: () => Navigator.of(
                                                    sheetContext)
                                                .pop(c),
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

    if (picked != null && mounted) {
      setState(() => _club = picked);
    }
  }

  Widget _dateTimeField() {
    final dt = _startsAt;
    final text = dt == null
        ? 'Выбрать'
        : '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}'
            ' в ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: _pickDateTime,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Text(text,
                style: TextStyle(
                    color: dt == null ? AppTheme.textDim : AppTheme.textPrimary,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _durationPicker() {
    const options = [60, 90, 120, 150, 180];
    return Row(
      children: [
        for (final minutes in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _duration = minutes),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _duration == minutes
                      ? AppTheme.accent.withOpacity(0.15)
                      : AppTheme.cardRaised,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _duration == minutes
                        ? AppTheme.accent
                        : AppTheme.border,
                  ),
                ),
                child: Text('$minutes',
                    style: TextStyle(
                      color: _duration == minutes
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          ),
          if (minutes != options.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _numberField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textDim, fontSize: 13),
        filled: true,
        fillColor: AppTheme.cardRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}
