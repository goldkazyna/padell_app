import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../utils/city_l10n.dart';

/// Экран регистрации нового пользователя после входа по SMS.
/// Собирает ФИО, Город, Дату рождения и Пол (все обязательны) и сохраняет
/// через PUT /profile — то же хранилище, что и редактирование профиля.
class SmsRegistrationScreen extends StatefulWidget {
  const SmsRegistrationScreen({super.key});

  @override
  State<SmsRegistrationScreen> createState() => _SmsRegistrationScreenState();
}

class _SmsRegistrationScreenState extends State<SmsRegistrationScreen> {
  final _nameController = TextEditingController();
  String? _city;
  DateTime? _birthDate;
  String? _gender; // 'male' | 'female'
  bool _isSaving = false;

  static const _cities = ['Алматы', 'Астана', 'Шымкент', 'Караганда', 'Актобе', 'Актау', 'Атырау', 'Костанай'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isComplete =>
      _nameController.text.trim().isNotEmpty &&
      _city != null &&
      _birthDate != null &&
      _gender != null;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 99),
      lastDate: DateTime(now.year - 1, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.card,
            onSurface: AppTheme.textPrimary,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppTheme.card),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickCity() async {
    final l = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.selectCity,
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._cities.map((city) => ListTile(
                  title: Text(
                    localizeCity(context, city),
                    style: TextStyle(
                      color: city == _city
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontWeight:
                          city == _city ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: city == _city
                      ? const Icon(Icons.check, color: AppTheme.accent)
                      : null,
                  onTap: () {
                    setState(() => _city = city);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (!_isComplete) {
      showAppAlert(context, l.registrationFillAll,
          title: l.error, isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final token = await StorageService().getToken();
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'city': _city,
        'gender': _gender,
        'birth_date': _birthDate!.toIso8601String().substring(0, 10),
      };
      await ApiService().put('/profile', body, token);

      if (!mounted) return;
      // Обновляем пользователя в провайдере, чтобы профиль был актуальным.
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;
      // Возвращаемся в корень — роутинг покажет квиз/главную (новый юзер).
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        showAppAlert(context, l.saveError(e.toString()),
            title: l.error, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.registrationTitle,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.registrationSubtitle,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 28),

                    // ФИО
                    _label(l.fieldName),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration: _inputDecoration('Фамилия Имя'),
                    ),
                    const SizedBox(height: 20),

                    // Город
                    _label(l.fieldCity),
                    const SizedBox(height: 8),
                    _pickerRow(
                      value: _city != null ? localizeCity(context, _city) : null,
                      placeholder: l.selectCity,
                      onTap: _pickCity,
                    ),
                    const SizedBox(height: 20),

                    // Дата рождения
                    _label(l.fieldBirthDate),
                    const SizedBox(height: 8),
                    _pickerRow(
                      value: _birthDate != null ? _formatDate(_birthDate!) : null,
                      placeholder: l.selectBirthDate,
                      onTap: _pickBirthDate,
                    ),
                    const SizedBox(height: 20),

                    // Пол
                    _label(l.fieldGender),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _genderChip('male', l.genderMale),
                        const SizedBox(width: 10),
                        _genderChip('female', l.genderFemale),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSaving || !_isComplete) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor:
                        AppTheme.accent.withValues(alpha: 0.4),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          l.continueButton,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accent),
        ),
      );

  Widget _pickerRow({
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: value != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withValues(alpha: 0.15)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.accent : AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
