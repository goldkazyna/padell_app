import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/home_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/home/notification_bell.dart';
import '../widgets/profile/profile_hero.dart';
import '../widgets/home/nearest_tournament_card.dart';
import '../widgets/home/active_tournament_card.dart';
import '../widgets/home/upcoming_list.dart';
import '../widgets/home/section_title.dart';
import '../widgets/home/court_booking_banner.dart';
import '../widgets/home/home_banner_card.dart';
import '../widgets/pressable_card.dart';
import '../widgets/home/admin_club_block.dart';
import 'clubs_list_screen.dart';
import '../widgets/home/profile_incomplete_banner.dart';
import '../widgets/verification_blockers_banner.dart';
import '../theme/app_theme.dart';
import '../utils/profile_incomplete_guard.dart';
import '../l10n/app_localizations.dart';
import 'tournament_detail_screen.dart';
import 'tournament_live_screen.dart';
import 'tournament_live_mexicano_screen.dart';
import 'tournament_live_team_screen.dart';
import 'tournament_live_kingofcourt_screen.dart';
import 'tournament_live_bali_koc_screen.dart';
import 'club_select_screen.dart';
import 'create_challenge_screen.dart';
import 'challenges_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<HomeProvider>(
        builder: (context, home, _) {
          if (home.isLoading && home.user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }

          if (home.error != null && home.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    home.error!,
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => home.loadHomeData(),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                home.refresh(),
                context.read<ProfileProvider>().loadProfile(),
              ]);
            },
            color: AppTheme.accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHero(trailing: NotificationBell()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  if (home.user?.isProfileIncomplete == true) ...[
                    const SizedBox(height: 12),
                    const ProfileIncompleteBanner(),
                  ],
                  if ((home.user?.verificationBlockers ?? const []).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    VerificationBlockersBanner(
                      blockers: home.user!.verificationBlockers,
                      onTournamentsTap: () => widget.onNavigateToTab?.call(1),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CourtBookingBanner(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClubSelectScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HalfBanner(
                          title: AppLocalizations.of(context)!.bannerClubsTitle,
                          subtitle: AppLocalizations.of(context)!.bannerClubsSubtitle,
                          icon: Icons.apartment_rounded,
                          gradient: const [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClubsListScreen(
                                  title: AppLocalizations.of(context)!
                                      .bannerClubsTitle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HalfBanner(
                          title: AppLocalizations.of(context)!.bannerCommunityTitle,
                          subtitle: AppLocalizations.of(context)!.bannerCommunitySubtitle,
                          icon: Icons.groups_rounded,
                          gradient: const [Color(0xFFA855F7), Color(0xFF581C87)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClubsListScreen(
                                  type: 'community',
                                  title: AppLocalizations.of(context)!
                                      .bannerCommunityTitle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Для admin клуба — блок управления, для остальных —
                  // приглашение получить аккредитацию.
                  Consumer<ProfileProvider>(
                    builder: (_, profile, __) {
                      final user = profile.user;
                      if (user != null && user.isClubAdmin) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: AdminClubBlock(
                            clubs: user.adminClubs,
                            tournamentsFullAccess: true,
                            isModerator: false,
                          ),
                        );
                      }
                      if (user != null && user.isClubModerator) {
                        final club = user.moderatorClubs.isNotEmpty
                            ? user.moderatorClubs.first
                            : null;
                        if (club == null) {
                          return _CreateTournamentBanner(
                            onTap: () => _showAccreditationDialog(context),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: AdminClubBlock(
                            clubs: user.moderatorClubs,
                            tournamentsFullAccess: club.tournamentsFullAccess,
                            isModerator: true,
                          ),
                        );
                      }
                      return _CreateTournamentBanner(
                        onTap: () => _showAccreditationDialog(context),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SectionTitle(
                    title: AppLocalizations.of(context)!.nearestTournament,
                    onInfoTap: () => _showInfoDialog(
                      context,
                      AppLocalizations.of(context)!.nearestTournament,
                      AppLocalizations.of(context)!.nearestTournamentInfo,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NearestTournamentCard(
                    tournament: home.nearestTournament,
                    onTap: () {
                      if (home.nearestTournament == null) return;
                      if (!ensureProfileComplete(context)) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TournamentDetailScreen(
                            tournamentId: home.nearestTournament!.id,
                          ),
                        ),
                      );
                    },
                    onBrowse: () => widget.onNavigateToTab?.call(1),
                  ),
                  const SizedBox(height: 12),
                  SectionTitle(
                    title: AppLocalizations.of(context)!.activeTournament,
                    onInfoTap: () => _showInfoDialog(
                      context,
                      AppLocalizations.of(context)!.activeTournament,
                      AppLocalizations.of(context)!.activeTournamentInfo,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ActiveTournamentCard(
                    tournament: home.activeTournament,
                    onTap: () {
                      final t = home.activeTournament;
                      if (t == null) return;
                      if (!ensureProfileComplete(context)) return;
                      final isLive = t.status == 'in_progress';
                      Widget target;
                      if (isLive && t.type == 'americano') {
                        target = TournamentLiveScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'mexicano') {
                        target = TournamentLiveMexicanoScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'team') {
                        target = TournamentLiveTeamScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'king_of_court') {
                        target =
                            TournamentLiveKingOfCourtScreen(tournamentId: t.id);
                      } else if (isLive && t.type == 'bali_koc') {
                        target =
                            TournamentLiveBaliKocScreen(tournamentId: t.id);
                      } else {
                        target = TournamentDetailScreen(tournamentId: t.id);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => target),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Игры: создать + список
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: AppLocalizations.of(context)!.challengeCreateButton,
                          subtitle: AppLocalizations.of(context)!.challengeCreateSubtitle,
                          icon: Icons.add_circle_outline,
                          gradient: const [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          shadowColor: const Color(0xFF3B82F6),
                          onTap: () {
                            if (!ensureProfileComplete(context)) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateChallengeScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionCard(
                          title: AppLocalizations.of(context)!.challengesCardTitle,
                          subtitle: AppLocalizations.of(context)!.challengesCardSubtitle,
                          icon: Icons.sports_tennis,
                          gradient: const [Color(0xFFF97316), Color(0xFF9A3412)],
                          shadowColor: const Color(0xFFF97316),
                          onTap: () {
                            if (!ensureProfileComplete(context)) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (home.banner != null) ...[
                    HomeBannerCard(banner: home.banner!),
                    const SizedBox(height: 12),
                  ],
                  SectionTitle(
                    title: AppLocalizations.of(context)!.upcoming,
                    trailing: AppLocalizations.of(context)!.calendarLink,
                    onTrailingTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  UpcomingList(
                    tournaments: home.upcomingTournaments,
                    onTap: (tournament) {
                      if (!ensureProfileComplete(context)) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TournamentDetailScreen(
                            tournamentId: tournament.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const _TelegramNewsButton(),
                  const SizedBox(height: 16),
                  const _PaymentLogos(),
                  const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppLocalizations.of(context)!.understood,
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withAlpha(30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAccreditationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: Color(0xFFF97316),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Аккредитация',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Чтобы вы могли создавать турниры, вам необходимо получить аккредитацию.\n\nНапишите в Telegram:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://t.me/mdlabkz');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF229ED9).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF229ED9).withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.send_rounded,
                        color: Color(0xFF229ED9),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '@mdlabkz',
                        style: TextStyle(
                          color: Color(0xFF229ED9),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Понятно',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CreateTournamentBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateTournamentBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF97316), Color(0xFF9A3412)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bannerCreateTournamentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.bannerCreateTournamentSubtitle,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Половинчатая кнопка для размещения в Row 2×1 (Клубы / Комьюнити).
class _HalfBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _HalfBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = gradient.first;
    return PressableCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accent.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(200),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentLogos extends StatelessWidget {
  const _PaymentLogos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/visa.png', height: 26),
            const SizedBox(width: 14),
            Image.asset('assets/images/mastercard.png', height: 26),
          ],
        ),
      ),
    );
  }
}

class _TelegramNewsButton extends StatelessWidget {
  const _TelegramNewsButton();

  @override
  Widget build(BuildContext context) {
    const tg = Color(0xFF229ED9);
    return PressableCard(
      onTap: () async {
        final url = Uri.parse('https://t.me/padelkz_app');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF229ED9), Color(0xFF1B7FAE)],
          ),
          boxShadow: [
            BoxShadow(
              color: tg.withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.newsChannelButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
