import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/training.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_primary_button.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';

/// Создание тренировки: клуб, время, длительность, цена, места, описание.
class CoachCreateTrainingScreen extends StatefulWidget {
  const CoachCreateTrainingScreen({super.key});

  @override
  State<CoachCreateTrainingScreen> createState() =>
      _CoachCreateTrainingScreenState();
}

class _CoachCreateTrainingScreenState extends State<CoachCreateTrainingScreen> {
  final _price = TextEditingController(text: '5000');
  final _capacity = TextEditingController(text: '4');
  final _description = TextEditingController();

  List<TrainingClub> _clubs = const [];
  int? _clubId;
  DateTime? _startsAt;
  int _duration = 60;

  bool _loadingClubs = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  @override
  void dispose() {
    _price.dispose();
    _capacity.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    try {
      final clubs = await context.read<TrainingService>().getCoachClubs();
      if (!mounted) return;
      setState(() {
        _clubs = clubs;
        _clubId = clubs.isNotEmpty ? clubs.first.id : null;
        _loadingClubs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingClubs = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
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
    if (_clubId == null) {
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
      await context.read<TrainingService>().create(
            clubId: _clubId!,
            startsAt: _formatForApi(_startsAt!),
            durationMinutes: _duration,
            price: price,
            capacity: capacity,
            description: _description.text.trim(),
          );
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
                  Text('Новая тренировка',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: _loadingClubs
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
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
                            label: 'Создать тренировку',
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

  Widget _clubPicker() {
    if (_clubs.isEmpty) {
      return Text('Клубы не найдены',
          style: TextStyle(color: AppTheme.textDim, fontSize: 13));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _clubId,
          isExpanded: true,
          dropdownColor: AppTheme.cardRaised,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          items: _clubs
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      (c.city ?? '').isEmpty ? c.name : '${c.name} · ${c.city}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _clubId = v),
        ),
      ),
    );
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
