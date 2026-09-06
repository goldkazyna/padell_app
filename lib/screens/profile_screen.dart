import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/push_notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/profile_incomplete_banner.dart';
import '../widgets/profile/profile_hero.dart';
import '../widgets/profile/moderation_payment_banner.dart';
import '../widgets/profile/achievements_section.dart';
import '../widgets/profile/partners_section.dart';
import '../widgets/profile/amigos_card.dart';
import '../widgets/profile/inactivity_card.dart';
import '../widgets/profile/messages_bell.dart';
import '../widgets/profile/rating_dynamics_card.dart';
import '../widgets/profile/profile_menu.dart';
import '../widgets/profile/profile_court_menu.dart';
import '../widgets/verification_blockers_banner.dart';

/// Шаг между блоками профиля. Один на все стыки: раньше тут стояли 12, 20 и
/// 22 вперемешку, и разделы «плавали» — глазом это читается как небрежность.
const double _gap = 20;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.loadProfile();
      provider.loadTournamentHistory();
      provider.loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        if (profile.isLoading && profile.user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.card,
            onRefresh: () => profile.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHero(trailing: MessagesBell()),
                  const ModerationPaymentBanner(),
                  if (profile.user?.isProfileIncomplete == true) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ProfileIncompleteBanner(user: profile.user),
                    ),
                  ],
                  if ((profile.user?.verificationBlockers ?? const []).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: VerificationBlockersBanner(
                        blockers: profile.user!.verificationBlockers,
                      ),
                    ),
                  ],
                  // Простой — сразу под статистикой матчей в шапке: цифры
                  // выше объясняют, о чём речь.
                  const SizedBox(height: _gap),
                  const InactivityCard(),
                  const SizedBox(height: _gap),
                  const AmigosCard(),
                  const SizedBox(height: _gap),
                  const RatingDynamicsCard(),
                  const SizedBox(height: _gap),
                  const AchievementsSection(),
                  const SizedBox(height: _gap),
                  const PartnersSection(),
                  const SizedBox(height: _gap),
                  // Шесть разделов одним блоком-кортом: раньше это были шесть
                  // цветных карточек во всю ширину, и «Служба поддержки»
                  // выглядела так же важно, как приглашение, ждущее ответа.
                  const ProfileCourtMenu(),
                  const SizedBox(height: _gap),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ProfileMenu(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PushDebugButton extends StatelessWidget {
  const _PushDebugButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.read<PushNotificationService>().showDebugLog(context);
        },
        child: Text(
          'Push Debug Log',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
