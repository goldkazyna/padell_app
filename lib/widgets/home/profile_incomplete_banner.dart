import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../screens/edit_profile_screen.dart';
import '../../theme/app_theme.dart';

/// Баннер «заполните профиль» — стиль аналогичен VerificationBlockersBanner.
/// Показывается если у юзера не заполнены телефон / город / пол.
class ProfileIncompleteBanner extends StatelessWidget {
  final User? user;

  const ProfileIncompleteBanner({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return _buildForUser(context, user!);
    }
    return Consumer<HomeProvider>(
      builder: (_, home, __) {
        final u = home.user;
        if (u == null) return const SizedBox.shrink();
        return _buildForUser(context, u);
      },
    );
  }

  Widget _buildForUser(BuildContext context, User u) {
    if (!u.isProfileIncomplete) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppTheme.amber, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.profileBannerTitle,
                  style: TextStyle(
                    color: AppTheme.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final key in u.missingProfileFieldKeys) ...[
            _MissingRow(
              fieldKey: key,
              onTap: () => _openEditProfile(context),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (context.mounted) {
      context.read<HomeProvider>().refresh();
      context.read<ProfileProvider>().loadProfile();
    }
  }
}

class _MissingRow extends StatelessWidget {
  final String fieldKey;
  final VoidCallback onTap;

  const _MissingRow({required this.fieldKey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (IconData icon, String title, String desc) = switch (fieldKey) {
      'phone' => (
          Icons.phone_outlined,
          l.profileMissingPhoneTitle,
          l.profileMissingPhoneDesc,
        ),
      'city' => (
          Icons.location_city_outlined,
          l.profileMissingCityTitle,
          l.profileMissingCityDesc,
        ),
      'gender' => (
          Icons.wc_outlined,
          l.profileMissingGenderTitle,
          l.profileMissingGenderDesc,
        ),
      _ => (
          Icons.edit_outlined,
          l.profileBannerTitle,
          fieldKey,
        ),
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.amber, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
