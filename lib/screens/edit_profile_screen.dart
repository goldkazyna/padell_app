import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// Local utility aliases mapped to global AppTheme
class _T {
  static const bg = AppTheme.background;
  static const card = AppTheme.card;
  static const cardRaised = AppTheme.cardRaised;
  static const border = AppTheme.border;
  static const divider = AppTheme.divider;
  static const text = AppTheme.textPrimary;
  static const muted = AppTheme.textSecondary;
  static const dim = AppTheme.textDim;
  static const green = AppTheme.accent;
  static const greenSoft = AppTheme.accentSoft;
  static const amber = AppTheme.amber;
  static const red = AppTheme.error;
  static const rowIconBg = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _city;
  String? _gender;
  String? _hand;
  String? _position;
  DateTime? _birthDate;
  String _phone = '';
  String? _avatarUrl;
  int? _rating;
  double? _level;
  int? _place;

  File? _pickedImage;
  bool _isLoading = true;
  bool _isSaving = false;

  // Snapshot of original for dirty check
  Map<String, dynamic> _initial = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final token = await StorageService().getToken();
      final response = await ApiService().get('/profile', token);
      final user = response['user'] as Map<String, dynamic>? ?? {};

      final name = user['name'] as String? ?? '';
      final birthStr = user['birth_date'] as String?;
      final birth = birthStr != null ? DateTime.tryParse(birthStr) : null;

      setState(() {
        _nameController.text = name;
        _city = user['city'] as String?;
        _gender = user['gender'] as String?;
        _hand = user['hand'] as String?;
        _position = user['position'] as String?;
        _birthDate = birth;
        _phone = (user['phone'] as String? ?? '').trim();
        _phoneController.text = _phone.isNotEmpty ? _formatPhone(_phone) : '';
        _avatarUrl = user['avatar'] as String?;
        _rating = user['rating'] as int?;
        final lvl = user['level'];
        _level = lvl is num ? lvl.toDouble() : double.tryParse(lvl?.toString() ?? '');
        _place = user['place'] as int?;
        _isLoading = false;
        _initial = _snapshot();
      });
    } catch (e) {
      debugPrint('[EDIT_PROFILE] load error: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _snapshot() => {
    'name': _nameController.text.trim(),
    'city': _city,
    'gender': _gender,
    'hand': _hand,
    'position': _position,
    'birth_date': _birthDate?.toIso8601String().substring(0, 10),
  };

  bool get _isDirty {
    final now = _snapshot();
    if (_pickedImage != null) return true;
    for (final k in now.keys) {
      if (now[k] != _initial[k]) return true;
    }
    return false;
  }

  int get _completionPct {
    final filled = [
      _nameController.text.trim().isNotEmpty,
      _phone.isNotEmpty,
      _city != null && _city!.isNotEmpty,
      _gender != null,
      _birthDate != null,
      _hand != null,
      _position != null,
    ].where((e) => e).length;
    return ((filled / 7) * 100).round();
  }

  String? get _missingFieldHint {
    if (_birthDate == null && _position == null) {
      return 'Заполните возраст и позицию на корте, чтобы находить пары';
    }
    if (_birthDate == null) return 'Укажите возраст, чтобы было проще найти партнёра';
    if (_position == null) return 'Укажите позицию на корте';
    if (_hand == null) return 'Добавьте ведущую руку';
    if (_gender == null) return 'Укажите пол';
    if (_city == null || _city!.isEmpty) return 'Выберите город';
    return null;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final token = await StorageService().getToken();

      if (_pickedImage != null) {
        try {
          await ApiService().multipartPost(
            '/profile/avatar',
            {},
            _pickedImage!.path,
            'avatar',
            token,
          );
        } catch (e) {
          debugPrint('[EDIT_PROFILE] avatar error: $e');
        }
      }

      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
      };
      if (_city != null) body['city'] = _city;
      if (_gender != null) body['gender'] = _gender;
      if (_hand != null) body['hand'] = _hand;
      if (_position != null) body['position'] = _position;
      if (_birthDate != null) {
        body['birth_date'] = _birthDate!.toIso8601String().substring(0, 10);
      }
      // Телефон — отправляем только если изменился относительно исходного
      final phoneRaw = _phoneController.text.trim();
      final phoneDigits = phoneRaw.replaceAll(RegExp(r'[^0-9]'), '');
      if (phoneDigits.isNotEmpty && phoneDigits != _phone) {
        body['phone'] = phoneDigits;
      }

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
            content: Text(AppLocalizations.of(context)!.saveError(e.toString())),
            backgroundColor: _T.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _T.card,
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
              leading: const Icon(Icons.camera_alt, color: _T.green),
              title: Text(AppLocalizations.of(context)!.photoCamera,
                  style: const TextStyle(color: _T.text)),
              onTap: () { Navigator.pop(ctx); _takePhoto(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _T.green),
              title: Text(AppLocalizations.of(context)!.photoGallery,
                  style: const TextStyle(color: _T.text)),
              onTap: () { Navigator.pop(ctx); _takePhoto(ImageSource.gallery); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.webp';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path, targetPath, format: CompressFormat.webp, quality: 80,
        minWidth: 512, minHeight: 512,
      );
      if (!mounted) return;
      setState(() => _pickedImage = File(compressed?.path ?? picked.path));
    } catch (e) {
      debugPrint('[EDIT_PROFILE] pick error: $e');
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 99),
      lastDate: DateTime(now.year - 1, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _T.green,
            onPrimary: Colors.white,
            surface: _T.card,
            onSurface: _T.text,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: _T.card),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickCity() async {
    final cities = ['Алматы', 'Астана', 'Шымкент', 'Караганда', 'Актобе'];
    await showModalBottomSheet(
      context: context,
      backgroundColor: _T.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.selectCity,
              style: const TextStyle(color: _T.text, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...cities.map((city) => ListTile(
              title: Text(
                city,
                style: TextStyle(
                  color: city == _city ? _T.green : _T.text,
                  fontWeight: city == _city ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: city == _city ? const Icon(Icons.check, color: _T.green) : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _T.green))
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          _buildHero(),
                          _buildSectionTitle('КОНТАКТЫ'),
                          _buildCard(children: [
                            _buildEditableRow(
                              icon: Icons.person_outline,
                              label: 'Имя',
                              controller: _nameController,
                              hint: 'Укажите имя',
                            ),
                            _divider(),
                            _buildEditableRow(
                              icon: Icons.phone_outlined,
                              label: 'Телефон',
                              controller: _phoneController,
                              hint: '+7 777 ...',
                              keyboardType: TextInputType.phone,
                            ),
                            _divider(),
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Город',
                              value: _city,
                              placeholder: 'Выберите город',
                              trailing: const Icon(Icons.chevron_right, size: 16, color: _T.dim),
                              onTap: _pickCity,
                              isLast: true,
                            ),
                          ]),
                          _buildSectionTitle('О ВАС', optional: true),
                          _buildCard(children: [
                            _buildInfoRow(
                              icon: Icons.cake_outlined,
                              label: 'Возраст',
                              value: _birthDate != null
                                  ? '${_ageFromDate(_birthDate!)} · ${_formatDate(_birthDate!)}'
                                  : null,
                              placeholder: 'Укажите дату рождения',
                              trailing: const Icon(Icons.chevron_right, size: 16, color: _T.dim),
                              onTap: _pickBirthDate,
                              incomplete: _birthDate == null,
                            ),
                            _divider(),
                            _buildChipRow(
                              icon: Icons.wc_outlined,
                              label: 'Пол',
                              options: const [
                                _ChipOption('male', 'Мужской'),
                                _ChipOption('female', 'Женский'),
                              ],
                              value: _gender,
                              onChanged: (v) => setState(() => _gender = v),
                              incomplete: _gender == null,
                              isLast: true,
                            ),
                          ]),
                          _buildSectionTitle('ИГРОВОЙ СТИЛЬ'),
                          _buildCard(children: [
                            _buildChipRow(
                              icon: Icons.back_hand_outlined,
                              label: 'Ведущая рука',
                              options: const [
                                _ChipOption('right', 'Правша'),
                                _ChipOption('left', 'Левша'),
                              ],
                              value: _hand,
                              onChanged: (v) => setState(() => _hand = v),
                              incomplete: _hand == null,
                            ),
                            _divider(),
                            _buildChipRow(
                              icon: Icons.sports_tennis_outlined,
                              label: 'Позиция на корте',
                              options: const [
                                _ChipOption('right', 'Справа'),
                                _ChipOption('left', 'Слева'),
                                _ChipOption('any', 'Любая'),
                              ],
                              value: _position,
                              onChanged: (v) => setState(() => _position = v),
                              incomplete: _position == null,
                              isLast: true,
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                color: _T.card,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(color: _T.border)),
              ),
              child: const Icon(Icons.chevron_left, size: 20, color: _T.text),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Настройки профиля',
            style: TextStyle(
              color: _T.text, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          _isSaving
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: _T.green, strokeWidth: 2),
                )
              : GestureDetector(
                  onTap: _isDirty ? _save : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _isDirty ? _T.greenSoft : const Color(0x08FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Сохранить',
                      style: TextStyle(
                        color: _isDirty ? _T.green : _T.dim,
                        fontSize: 13, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final pct = _completionPct;
    final hint = _missingFieldHint;
    final levelText = _level != null ? _level!.toStringAsFixed(2) : '—';
    final cityLabel = _city ?? '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F1F26), Color(0xFF1A1A20)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: const Border.fromBorderSide(BorderSide(color: _T.border)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.trim().isEmpty ? 'Без имени' : _nameController.text.trim(),
                        style: const TextStyle(
                          color: _T.text, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$cityLabel · Уровень $levelText',
                        style: const TextStyle(color: _T.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Wrap(spacing: 4, runSpacing: 4, children: [
                        if (_hand != null)
                          _heroBadge(_handLabel(_hand!), _T.greenSoft, _T.green),
                        if (_place != null)
                          _heroBadge('#$_place в рейтинге', const Color(0x0AFFFFFF), _T.muted),
                        if (_rating != null && _rating! > 0)
                          _heroBadge('$_rating рейтинг', const Color(0x0AFFFFFF), _T.muted),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Профиль заполнен',
                          style: TextStyle(color: _T.muted, fontSize: 12),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          color: _T.green, fontSize: 13, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0x0DFFFFFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(_T.green),
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 6),
                    Text(hint, style: const TextStyle(color: _T.dim, fontSize: 11)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: _T.green,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: _pickedImage != null
                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                : _avatarUrl != null
                    ? Image.network(
                        _avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarInitials(),
                      )
                    : _avatarInitials(),
          ),
          Positioned(
            right: -3, bottom: -3,
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: _T.cardRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1B1B21), width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 12, color: _T.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarInitials() {
    final name = _nameController.text.trim();
    final parts = name.split(RegExp(r'\s+'));
    String initials = '??';
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      initials = name[0].toUpperCase();
    }
    return Center(
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _heroBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _T.dim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.4,
              ),
            ),
          ),
          if (optional)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'Опционально',
                style: TextStyle(color: _T.dim, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _T.card,
          borderRadius: BorderRadius.circular(14),
          border: const Border.fromBorderSide(BorderSide(color: _T.border)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() => const SizedBox.shrink();

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: _T.rowIconBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: _T.muted),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    String? value,
    String? placeholder,
    Widget? trailing,
    VoidCallback? onTap,
    bool incomplete = false,
    bool isLast = false,
  }) {
    final empty = value == null || value.isEmpty;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : _T.divider,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildIconBox(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: const TextStyle(color: _T.dim, fontSize: 11, height: 1.2)),
                      if (incomplete && empty) ...[
                        const SizedBox(width: 5),
                        const Text('• Не заполнено',
                          style: TextStyle(color: _T.amber, fontSize: 11, height: 1.2)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    empty ? (placeholder ?? 'Не указано') : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: empty ? _T.dim : _T.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _T.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildIconBox(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _T.dim, fontSize: 11, height: 1.2)),
                const SizedBox(height: 1),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(color: _T.text, fontSize: 14, fontWeight: FontWeight.w500),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: _T.dim, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow({
    required IconData icon,
    required String label,
    required List<_ChipOption> options,
    required String? value,
    required ValueChanged<String> onChanged,
    bool incomplete = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _T.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconBox(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: const TextStyle(color: _T.dim, fontSize: 11)),
                    if (incomplete && value == null) ...[
                      const SizedBox(width: 5),
                      const Text('• Не заполнено',
                        style: TextStyle(color: _T.amber, fontSize: 11)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5, runSpacing: 5,
                  children: options.map((o) {
                    final active = o.value == value;
                    return GestureDetector(
                      onTap: () => onChanged(o.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: active ? _T.green : const Color(0x0AFFFFFF),
                          border: Border.all(color: active ? _T.green : _T.border, width: 1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          o.label,
                          style: TextStyle(
                            color: active ? Colors.white : _T.muted,
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final enabled = _isDirty && !_isSaving;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: enabled ? _save : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: enabled ? _T.green : const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Сохранить изменения',
                    style: TextStyle(
                      color: enabled ? Colors.white : _T.dim,
                      fontSize: 15, fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // === Helpers ===

  String _formatPhone(String digits) {
    if (digits.length != 11) return digits;
    return '+${digits[0]} ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
  }

  String _formatDate(DateTime d) {
    const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  int _ageFromDate(DateTime birth) {
    final now = DateTime.now();
    int years = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      years--;
    }
    return years;
  }

  String _handLabel(String hand) => hand == 'right' ? 'Правша' : hand == 'left' ? 'Левша' : hand;
}

class _ChipOption {
  final String value;
  final String label;
  const _ChipOption(this.value, this.label);
}
