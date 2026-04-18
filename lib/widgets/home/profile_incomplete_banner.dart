import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../screens/edit_profile_screen.dart';

class ProfileIncompleteBanner extends StatelessWidget {
  const ProfileIncompleteBanner({super.key});

  static const _warning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, home, __) {
        final user = home.user;
        if (user == null || !user.isProfileIncomplete) {
          return const SizedBox.shrink();
        }

        final l = AppLocalizations.of(context)!;
        final missingText = user.missingProfileFieldKeys
            .map((key) => _fieldLabel(l, key))
            .join(l.profileBannerSeparator);

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: GestureDetector(
            onTap: () => _openEditProfile(context),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B2A0F), Color(0xFF2D2108)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _warning.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: _warning,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.profileBannerTitle,
                          style: const TextStyle(
                            color: _warning,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          l.profileBannerDesc,
                          style: const TextStyle(
                            color: Color(0xFFD4D4D8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.profileBannerMissing(missingText),
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: _warning,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l.profileBannerCta,
                            style: const TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fieldLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'city':
        return l.profileMissingCity;
      case 'gender':
        return l.profileMissingGender;
      case 'phone':
        return l.profileMissingPhone;
      default:
        return key;
    }
  }

  Future<void> _openEditProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (context.mounted) {
      context.read<HomeProvider>().refresh();
    }
  }
}
