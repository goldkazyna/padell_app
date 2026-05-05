import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/edit_profile_screen.dart';
import '../theme/app_theme.dart';

/// Показывает диалог «заполните профиль». Используется и в `app.dart`
/// (при тапе на заблокированные табы), и при тапах на турниры с главной.
Future<void> showProfileIncompleteDialog(BuildContext context) {
  final l = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.profileBannerTitle,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.profileBannerDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                  if (context.mounted) {
                    context.read<HomeProvider>().refresh();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l.profileBannerCta,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                l.later,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// true — профиль заполнен и можно идти дальше.
/// false — показали диалог, навигацию делать не надо.
bool ensureProfileComplete(BuildContext context) {
  final user = context.read<HomeProvider>().user;
  if (user?.isProfileIncomplete == true) {
    showProfileIncompleteDialog(context);
    return false;
  }
  return true;
}
