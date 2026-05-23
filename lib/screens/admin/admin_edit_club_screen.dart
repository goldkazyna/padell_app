import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_alert.dart';
import '../../utils/city_l10n.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';

// Local utility aliases — same pattern as edit_profile_screen.dart
class _T {
  static const bg = AppTheme.background;
  static const card = AppTheme.card;
  static const border = AppTheme.border;
  static const divider = AppTheme.divider;
  static const text = AppTheme.textPrimary;
  static const muted = AppTheme.textSecondary;
  static const dim = AppTheme.textDim;
  static const green = AppTheme.accent;
  static const greenSoft = AppTheme.accentSoft;
  static const rowIconBg = Color(0x0AFFFFFF);
}

class AdminEditClubScreen extends StatefulWidget {
  final int clubId;
  const AdminEditClubScreen({super.key, required this.clubId});

  @override
  State<AdminEditClubScreen> createState() => _AdminEditClubScreenState();
}

class _AdminEditClubScreenState extends State<AdminEditClubScreen> {
  static const _cities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Караганда',
    'Актобе',
  ];

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _description = TextEditingController();
  final _paymentUrl = TextEditingController();
  final _telegramUrl = TextEditingController();
  String? _city;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _description.dispose();
    _paymentUrl.dispose();
    _telegramUrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final club = await context.read<AdminService>().getClub(widget.clubId);
      if (!mounted) return;
      setState(() {
        _name.text = club.name;
        _address.text = club.address;
        _city = club.city;
        _phone.text = club.phone ?? '';
        _email.text = club.email ?? '';
        _description.text = club.description ?? '';
        _paymentUrl.text = club.paymentUrl ?? '';
        _telegramUrl.text = club.telegramUrl ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppAlert(
        context,
        e.toString(),
        title: AppLocalizations.of(context)!.error,
        isError: true,
      );
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty || _address.text.trim().isEmpty) {
      showAppAlert(
        context,
        '${l10n.clubName} / ${l10n.clubAddress}',
        title: l10n.error,
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'city': _city,
        'phone':
            _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'email':
            _email.text.trim().isEmpty ? null : _email.text.trim(),
        'description':
            _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
        'payment_url':
            _paymentUrl.text.trim().isEmpty
                ? null
                : _paymentUrl.text.trim(),
        'telegram_url':
            _telegramUrl.text.trim().isEmpty
                ? null
                : _telegramUrl.text.trim(),
      };
      await context.read<AdminService>().updateClub(widget.clubId, body);
      if (!mounted) return;
      showAppAlert(context, l10n.clubCardSaved);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showAppAlert(
        context,
        e.toString(),
        title: AppLocalizations.of(context)!.error,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickCity() async {
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.selectCity,
              style: const TextStyle(
                color: _T.text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._cities.map(
              (city) => ListTile(
                title: Text(
                  localizeCity(context, city),
                  style: TextStyle(
                    color: city == _city ? _T.green : _T.text,
                    fontWeight:
                        city == _city
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                ),
                trailing:
                    city == _city
                        ? const Icon(Icons.check, color: _T.green)
                        : null,
                onTap: () {
                  setState(() => _city = city);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: _T.green),
              )
            : Column(
                children: [
                  _buildHeader(l10n),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildCard(
                            children: [
                              _buildEditableRow(
                                icon: Icons.store_outlined,
                                label: l10n.clubName,
                                controller: _name,
                                hint: l10n.clubName,
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                icon: Icons.location_on_outlined,
                                label: l10n.clubAddress,
                                controller: _address,
                                hint: l10n.clubAddress,
                              ),
                              _buildDivider(),
                              _buildTapRow(
                                icon: Icons.map_outlined,
                                label: l10n.clubCity,
                                value:
                                    _city != null && _city!.isNotEmpty
                                        ? localizeCity(context, _city)
                                        : null,
                                placeholder: l10n.selectCity,
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: _T.dim,
                                ),
                                onTap: _pickCity,
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                icon: Icons.phone_outlined,
                                label: l10n.clubPhone,
                                controller: _phone,
                                hint: '+7 777 ...',
                                keyboardType: TextInputType.phone,
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                icon: Icons.email_outlined,
                                label: l10n.clubEmail,
                                controller: _email,
                                hint: 'club@example.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                icon: Icons.description_outlined,
                                label: l10n.clubDescription,
                                controller: _description,
                                hint: l10n.clubDescription,
                                maxLines: 3,
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                icon: Icons.link_outlined,
                                label: l10n.clubPaymentUrl,
                                controller: _paymentUrl,
                                hint: 'https://',
                                keyboardType: TextInputType.url,
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                icon: Icons.telegram_outlined,
                                label: l10n.clubTelegram,
                                controller: _telegramUrl,
                                hint: 'https://t.me/...',
                                keyboardType: TextInputType.url,
                                isLast: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSaveButton(l10n),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 10),
          Text(
            l10n.editClubCard,
            style: const TextStyle(
              color: _T.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          _saving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: _T.green,
                    strokeWidth: 2,
                  ),
                )
              : GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _T.greenSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.saveProfile,
                      style: const TextStyle(
                        color: _T.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

  Widget _buildDivider() => Container(
    height: 0.5,
    color: _T.divider,
    margin: const EdgeInsets.only(left: 60),
  );

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _T.rowIconBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: _T.muted),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment:
            maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
        children: [
          _buildIconBox(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _T.dim,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 1),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: const TextStyle(
                    color: _T.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: _T.dim,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildTapRow({
    required IconData icon,
    required String label,
    String? value,
    String? placeholder,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final empty = value == null || value.isEmpty;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            _buildIconBox(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _T.dim,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    empty ? (placeholder ?? '') : value,
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

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: _saving ? null : _save,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _saving ? const Color(0x14FFFFFF) : _T.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.saveChanges,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
