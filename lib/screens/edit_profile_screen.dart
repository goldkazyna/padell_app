import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String? _city;
  String? _gender;
  String? _hand;
  String? _position;
  bool _isSaving = false;
  bool _isLoading = true;

  File? _pickedImage;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        _nameController.text = user['name'] as String? ?? '';
        _city = user['city'] as String?;
        _gender = user['gender'] as String?;
        _ageController.text =
            (user['age'] != null) ? user['age'].toString() : '';
        _hand = user['hand'] as String?;
        _position = user['position'] as String?;
        _currentAvatarUrl = user['avatar'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[EDIT_PROFILE] load error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
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
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.accent),
              title: const Text('Камера',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.accent),
              title: const Text('Галерея',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint('[EDIT_PROFILE] pick image error: $e');
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final token = await StorageService().getToken();

      // Upload avatar if picked
      if (_pickedImage != null) {
        try {
          await ApiService().multipartPost(
            '/profile/avatar',
            {},
            _pickedImage!.path,
            'avatar',
            token,
          );
          debugPrint('[EDIT_PROFILE] avatar uploaded');
        } catch (e) {
          debugPrint('[EDIT_PROFILE] avatar upload error: $e');
        }
      }

      // Save profile data
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child:
                          CircularProgressIndicator(color: AppTheme.accent),
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

                          // ФИО
                          _buildSectionLabel('ФИО'),
                          const SizedBox(height: 8),
                          _buildSingleTextField('Имя', _nameController),
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
                            onChanged: (v) =>
                                setState(() => _position = v),
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

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(_pickedImage!, fit: BoxFit.cover),
                  )
                : _currentAvatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          _currentAvatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildInitialsWidget(initials),
                        ),
                      )
                    : _buildInitialsWidget(initials),
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
      ),
    );
  }

  Widget _buildInitialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  Widget _buildSingleTextField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
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
                const Text(
                  'Выберите город',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppTheme.accent : const Color(0xFF2A2A2A),
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
