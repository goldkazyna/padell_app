import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../screens/notification_settings_screen.dart';
import '../../screens/my_bookings_screen.dart';
import '../../screens/edit_profile_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/tournament_types_info_screen.dart';
import '../../screens/auth/delete_account_code_screen.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_alert.dart';

// Палитра нижней части профиля (фон экрана не трогаем — берём из темы).
const _card = Color(0xFF15181A);
final _line = Colors.white.withValues(alpha: 0.065);
const _text = Color(0xFFEEF1F2);
const _text2 = Color(0xFF8B9298);
const _dim = Color(0xFF5D646A);
const _red = Color(0xFFE5564E);
const _logout = Color(0xFFC9938F);

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
        SettingsSection(
          label: l.sectionSettings,
          children: [
            SettingsRow(
              icon: Icons.person_outline,
              title: l.editProfile,
              subtitle: l.editProfileSubtitle,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            SettingsRow(
              icon: Icons.bookmark_border,
              title: l.myBookings,
              subtitle: l.bookedCourts,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
            ),
            SettingsRow(
              icon: Icons.notifications_none,
              title: l.notifications,
              subtitle: l.notificationSettingsMenu,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen())),
            ),
            SettingsRow(
              icon: Icons.language,
              title: l.language,
              subtitle: localeProvider.isRussian
                  ? 'Русский'
                  : localeProvider.isKazakh
                      ? 'Қазақша'
                      : 'English',
              onTap: () => _showLanguageDialog(context),
            ),
            SettingsRow(
              icon: Icons.tune,
              title: l.settingsMenuItem,
              subtitle: l.settingsMenuItemSubtitle,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ],
        ),

        // === ИНФОРМАЦИЯ ===
        SettingsSection(
          label: l.sectionInfo,
          children: [
            SettingsRow(
              icon: Icons.info_outline,
              title: l.tournamentInfoTitle,
              subtitle: l.tournamentInfoMenuSubtitle,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TournamentTypesInfoScreen())),
            ),
          ],
        ),

        // === АККАУНТ ===
        SettingsSection(
          label: l.sectionAccount,
          children: [
            SettingsRow(
              icon: Icons.logout,
              title: l.logout,
              subtitle: l.logoutSubtitle,
              iconColor: _logout,
              titleColor: _logout,
              onTap: () => _showLogoutDialog(context),
            ),
            SettingsRow(
              icon: Icons.delete_outline,
              title: l.deleteAccount,
              subtitle: l.deleteAccountSubtitle,
              iconColor: _red,
              titleColor: _red,
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),

        // === Подвал ===
        const SizedBox(height: 18),
        FooterLink(
          icon: Icons.send,
          iconTint: const Color(0xFF4D8FF0),
          title: l.newsChannelTitle,
          subtitle: l.newsChannelSubtitle,
          onTap: () => _launch('https://t.me/padelkz_app'),
        ),
        FooterLink(
          icon: Icons.code,
          iconTint: _text2,
          title: l.developerLabel,
          subtitle: 'Дудников Денис · @mdlabkz',
          onTap: () => _launch('https://t.me/mdlabkz'),
        ),
        const _AppVersionLabel(),
      ],
    );
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
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
            const SizedBox(height: 8),
            _LanguageOption(
              label: 'Қазақша',
              isSelected: localeProvider.isKazakh,
              onTap: () {
                localeProvider.setLocale(const Locale('kk'));
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
        title: Text(l.logoutTitle,
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(l.logoutConfirm,
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child:
                Text(l.logout, style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.deleteAccountTitle,
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(l.deleteAccountWarning,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              final sent = await auth.sendDeleteCode();
              if (!context.mounted) return;
              if (sent) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DeleteAccountCodeScreen()),
                );
              } else {
                showAppAlert(context, auth.error ?? l.error,
                    title: l.error, isError: true);
              }
            },
            child: Text(l.deleteButton,
                style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// === Переиспользуемые виджеты ===

/// Секция сгруппированного списка: заголовок + карточка со строками,
/// разделёнными тонкими линиями с левым инсетом.
class SettingsSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Container(height: 1, margin: const EdgeInsets.only(left: 52), color: _line));
      }
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 20, bottom: 9),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _dim,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: rows),
        ),
      ],
    );
  }
}

/// Строка секции: монохромная контурная иконка, заголовок + подзаголовок, шеврон.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Icon(icon, size: 22, color: iconColor ?? _text2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _text2, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: _dim),
          ],
        ),
      ),
    );
  }
}

/// Строка-ссылка в подвале (Telegram-канал, разработчик).
class FooterLink extends StatelessWidget {
  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FooterLink({
    super.key,
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF191D1F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _line),
              ),
              child: Icon(icon, size: 18, color: iconTint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _text2, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 17, color: _dim),
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

  const _LanguageOption(
      {required this.label, required this.isSelected, required this.onTap});

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
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AppVersionLabel extends StatefulWidget {
  const _AppVersionLabel();

  @override
  State<_AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<_AppVersionLabel> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (_) {
      // ignore — версия не отрисуется
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_version == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Text(
        'v$_version',
        style: const TextStyle(color: _dim, fontSize: 12),
      ),
    );
  }
}
