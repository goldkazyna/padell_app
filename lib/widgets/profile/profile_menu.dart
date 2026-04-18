import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../screens/notification_settings_screen.dart';
import '../../screens/my_bookings_screen.dart';
import '../../screens/edit_profile_screen.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === НАСТРОЙКИ ===
        const _SectionLabel('НАСТРОЙКИ'),
        _Card(children: [
          _SettingsRow(
            icon: Icons.person_outline,
            tint: AppTheme.accent,
            title: l.editProfile,
            subtitle: l.editProfileSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          const _Divider(),
          _SettingsRow(
            icon: Icons.bookmark_outline,
            tint: AppTheme.blue,
            title: l.myBookings,
            subtitle: l.bookedCourts,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
            ),
          ),
          const _Divider(),
          _SettingsRow(
            icon: Icons.notifications_outlined,
            tint: AppTheme.amber,
            title: l.notifications,
            subtitle: l.notificationSettingsMenu,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
            ),
          ),
          const _Divider(),
          _SettingsRow(
            icon: Icons.language,
            tint: AppTheme.purple,
            title: l.language,
            subtitle: localeProvider.isRussian ? 'Русский' : 'English',
            onTap: () => _showLanguageDialog(context),
            isLast: true,
          ),
        ]),

        // === АККАУНТ ===
        const SizedBox(height: 16),
        const _SectionLabel('АККАУНТ'),
        _Card(children: [
          _SettingsRow(
            icon: Icons.logout,
            tint: AppTheme.error,
            tintBg: AppTheme.errorSoft,
            title: l.logout,
            subtitle: l.logoutSubtitle,
            onTap: () => _showLogoutDialog(context),
          ),
          const _Divider(),
          _SettingsRow(
            icon: Icons.delete_outline,
            tint: AppTheme.error,
            tintBg: AppTheme.errorSoft,
            title: l.deleteAccount,
            titleColor: AppTheme.error,
            subtitle: l.deleteAccountSubtitle,
            onTap: () => _showDeleteAccountDialog(context),
            isLast: true,
          ),
        ]),

        // === РАЗРАБОТЧИК ===
        const SizedBox(height: 16),
        _DevRow(),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Язык / Language',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'Русский',
              isSelected: localeProvider.isRussian,
              onTap: () {
                localeProvider.setLocale(const Locale('ru'));
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: 'English',
              isSelected: localeProvider.isEnglish,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.logoutTitle, style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(l.logoutConfirm, style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: Text(l.logout, style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.deleteAccountTitle, style: const TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.deleteAccountWarning, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: l.deleteAccountPassword,
                hintStyle: TextStyle(color: AppTheme.textSecondary.withAlpha(128)),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final password = passwordController.text.isNotEmpty ? passwordController.text : null;
              context.read<AuthProvider>().deleteAccount(password);
            },
            child: Text(l.deleteButton, style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// === UI components ===

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textDim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color? tintBg;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.tint,
    this.tintBg,
    required this.title,
    this.titleColor,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tintBg ?? Color.alphaBlend(
      tint.withValues(alpha: 0.22),
      AppTheme.card,
    ).withValues(alpha: 1);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppTheme.divider,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tintBg ?? tint.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentSoft : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DevRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse('https://t.me/mdlabkz');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.code, size: 16, color: AppTheme.blue),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Разработчик',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  Text(
                    'Дудников Денис · @mdlabkz',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 14, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }
}
