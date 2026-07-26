import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/home_provider.dart';
import '../widgets/secure_payment_badge.dart';
import '../widgets/gradient_card_style.dart';
import '../providers/profile_provider.dart';
import '../widgets/home/notification_bell.dart';
import '../widgets/profile/profile_hero.dart';
import '../widgets/home/nearest_tournament_card.dart';
import '../widgets/home/active_tournament_card.dart';
import '../widgets/home/upcoming_list.dart';
import '../widgets/home/section_title.dart';
import '../widgets/home/services_block.dart';
import '../widgets/home/home_banner_card.dart';
import '../widgets/home/personal_creator_block.dart';
import '../widgets/pressable_card.dart';
import '../widgets/home/admin_club_block.dart';
import '../widgets/home/profile_incomplete_banner.dart';
import '../widgets/verification_blockers_banner.dart';
import '../theme/app_theme.dart';
import '../utils/profile_incomplete_guard.dart';
import '../l10n/app_localizations.dart';
import 'tournament_detail_screen.dart';
import '../utils/tournament_navigation.dart';
import 'coach_schedule_screen.dart';
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
                    style: TextStyle(color: AppTheme.textSecondary),
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
              padding: const EdgeInsets.only(bottom: 90),
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
                  const SizedBox(height: 16),
                  ServicesBlock(
                    onOpenTournaments: () => widget.onNavigateToTab?.call(1),
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
                      if (user != null && user.canCreateTournaments) {
                        return const PersonalCreatorBlock();
                      }
                      return _CreateTournamentBanner(
                        onTap: () => _showAccreditationDialog(context),
                      );
                    },
                  ),
                  // Блок тренера — расписание (только для роли coach).
                  Consumer<ProfileProvider>(
                    builder: (_, profile, _) {
                      if (profile.user?.isCoach != true) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _CoachScheduleCard(),
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
                      if (isLive) {
                        // Идущий турнир любого типа (включая americano_flex,
                        // round_robin и т.д.) открываем как Live с таблицей.
                        openTournamentLiveByType(
                          context,
                          tournamentId: t.id,
                          tournamentType: t.type,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TournamentDetailScreen(tournamentId: t.id),
                          ),
                        );
                      }
                    },
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
                  const SizedBox(height: 18),
                  const SecurePaymentBadge(),
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
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
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
                  Expanded(
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
              Text(
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
        clipBehavior: Clip.antiAlias,
        decoration: GradientCardStyle.decoration(const Color(0xFFF97316)),
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GradientCardStyle.glassChip(Icons.add_circle_outline),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .bannerCreateTournamentTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!
                              .bannerCreateTournamentSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 24,
                  ),
                ],
              ),
            ),
            GradientCardStyle.gloss(),
          ],
        ),
      ),
    );
  }
}

/// Блок «Тренер» на главной — тинтованная рамка с заголовком и кнопкой
/// «Расписание» (по образцу блока «Управление клубом»).
class _CoachScheduleCard extends StatelessWidget {
  static const _accent = Color(0xFF33C9C0);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _accent.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withAlpha(60), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _accent.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sports_tennis, color: _accent, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                l.coachTitle.toUpperCase(),
                style: const TextStyle(
                  color: _accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoachScheduleScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withAlpha(60),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.coachScheduleButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.coachScheduleButtonSubtitle,
                            style: const TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
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
