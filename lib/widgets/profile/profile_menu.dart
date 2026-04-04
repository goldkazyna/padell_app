import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../screens/notification_settings_screen.dart';
import '../../screens/my_bookings_screen.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLanguageSwitcher(context),
        const SizedBox(height: 8),
        _buildMenuItem(
          context,
          Icons.sports_tennis,
          AppLocalizations.of(context)!.myBookings,
          AppLocalizations.of(context)!.bookedCourts,
          const Color(0xFF3B82F6),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          context,
          Icons.notifications_outlined,
          AppLocalizations.of(context)!.notifications,
          AppLocalizations.of(context)!.notificationSettingsMenu,
          const Color(0xFFF59E0B),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationSettingsScreen(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          context,
          Icons.logout,
          AppLocalizations.of(context)!.logout,
          AppLocalizations.of(context)!.logoutSubtitle,
          AppTheme.error,
          onTap: () => _showLogoutDialog(context),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          context,
          Icons.delete_forever_outlined,
          AppLocalizations.of(context)!.deleteAccount,
          AppLocalizations.of(context)!.deleteAccountSubtitle,
          AppTheme.error,
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l.logoutTitle,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          l.logoutConfirm,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: Text(
              l.logout,
              style: const TextStyle(color: AppTheme.error),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l.deleteAccountTitle,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.deleteAccountWarning,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: l.deleteAccountPassword,
                hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withAlpha(128)),
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
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final password = passwordController.text.isNotEmpty
                  ? passwordController.text
                  : null;
              context.read<AuthProvider>().deleteAccount(password);
            },
            child: Text(
              l.deleteButton,
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language, color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l.language, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => localeProvider.setLocale(const Locale('ru')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: localeProvider.isRussian ? AppTheme.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'RU',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: localeProvider.isRussian ? Colors.black : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => localeProvider.setLocale(const Locale('en')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: localeProvider.isEnglish ? AppTheme.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: localeProvider.isEnglish ? Colors.black : AppTheme.textSecondary,
                      ),
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

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
