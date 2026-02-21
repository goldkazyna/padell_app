import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _ageController = TextEditingController();

  String? _city;
  String? _gender;
  String? _hand;
  String? _position;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymicController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await StorageService().getToken();
      final response = await ApiService().get('/profile', token);
      final user = response['user'] as Map<String, dynamic>? ?? {};

      debugPrint('[EDIT_PROFILE] user data: $user');

      setState(() {
        _lastNameController.text = user['last_name'] as String? ?? '';
        _firstNameController.text = user['first_name'] as String? ?? '';
        _patronymicController.text = user['patronymic'] as String? ?? '';
        _city = user['city'] as String?;
        _gender = user['gender'] as String?;
        _ageController.text = (user['age'] != null) ? user['age'].toString() : '';
        _hand = user['hand'] as String?;
        _position = user['position'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[EDIT_PROFILE] load error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final token = await StorageService().getToken();
      final body = <String, dynamic>{
        'last_name': _lastNameController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'patronymic': _patronymicController.text.trim(),
      };
      if (_city != null) body['city'] = _city;
      if (_gender != null) body['gender'] = _gender;
      if (_ageController.text.isNotEmpty) {
        body['age'] = int.tryParse(_ageController.text) ?? 0;
      }
      if (_hand != null) body['hand'] = _hand;
      if (_position != null) body['position'] = _position;

      debugPrint('[EDIT_PROFILE] saving: $body');

      await ApiService().put('/profile', body, token);

      // Refresh profile data
      if (mounted) {
        context.read<ProfileProvider>().loadProfile();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('[EDIT_PROFILE] save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2A2A2A),
                        width: 0.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppTheme.textPrimary, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Редактировать',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                            strokeWidth: 2,
                          ),
                        )
                      : GestureDetector(
                          onTap: _save,
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          const SizedBox(height: 8),
                          Center(child: _buildAvatar()),
                          const SizedBox(height: 24),

                          // ЛИЧНЫЕ ДАННЫЕ
                          _buildSectionLabel('ЛИЧНЫЕ ДАННЫЕ'),
                          const SizedBox(height: 8),
                          _buildTextField('Фамилия', _lastNameController),
                          _buildTextField('Имя', _firstNameController),
                          _buildTextField('Отчество', _patronymicController,
                              isLast: true),
                          const SizedBox(height: 24),

                          // МЕСТОПОЛОЖЕНИЕ
                          _buildSectionLabel('МЕСТОПОЛОЖЕНИЕ'),
                          const SizedBox(height: 8),
                          _buildCitySelector(),
                          const SizedBox(height: 24),

                          // ПОЛ
                          _buildSectionLabel('ПОЛ'),
                          const SizedBox(height: 8),
                          _buildToggleRow(
                            options: ['male', 'female'],
                            labels: ['Мужской', 'Женский'],
                            selected: _gender,
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                          const SizedBox(height: 24),

                          // ВОЗРАСТ
                          _buildSectionLabel('ВОЗРАСТ'),
                          const SizedBox(height: 8),
                          _buildAgeField(),
                          const SizedBox(height: 24),

                          // ВЕДУЩАЯ РУКА
                          _buildSectionLabel('ВЕДУЩАЯ РУКА'),
                          const SizedBox(height: 8),
                          _buildToggleRow(
                            options: ['right', 'left'],
                            labels: ['Правша', 'Левша'],
                            selected: _hand,
                            onChanged: (v) => setState(() => _hand = v),
                          ),
                          const SizedBox(height: 24),

                          // ПОЗИЦИЯ НА КОРТЕ
                          _buildSectionLabel('ПОЗИЦИЯ НА КОРТЕ'),
                          const SizedBox(height: 8),
                          _buildToggleRow(
                            options: ['right', 'left', 'any'],
                            labels: ['Справа', 'Слева', 'Любая'],
                            selected: _position,
                            onChanged: (v) => setState(() => _position = v),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final user = context.read<ProfileProvider>().user;
    final initials = user?.initials ?? '??';

    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.background, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AppTheme.textSecondary,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              )
            : (label == 'Фамилия'
                ? const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  )
                : BorderRadius.zero),
        border: Border(
          left: const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          right: const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          top: label == 'Фамилия'
              ? const BorderSide(color: Color(0xFF2A2A2A), width: 0.5)
              : BorderSide.none,
          bottom: const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Не указано',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withAlpha(100),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    final cities = ['Алматы', 'Астана', 'Шымкент', 'Караганда', 'Актобе'];

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.card,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Выберите город',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...cities.map((city) => ListTile(
                      title: Text(
                        city,
                        style: TextStyle(
                          color: city == _city
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                          fontWeight: city == _city
                              ? FontWeight.w600
                              : FontWeight.normal,
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          children: [
            const Text(
              'Город',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _city ?? 'Не указан',
                style: TextStyle(
                  color: _city != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary.withAlpha(100),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        children: [
          const Text(
            'Лет',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _ageController,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Не указан',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withAlpha(100),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required List<String> options,
    required List<String> labels,
    required String? selected,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = selected == options[i];
        return Padding(
          padding: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => onChanged(options[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accent
                      : const Color(0xFF2A2A2A),
                  width: 0.5,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
