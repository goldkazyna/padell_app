import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/challenge_provider.dart';
import '../widgets/app_back_button.dart';
import '../widgets/challenges/challenge_card.dart';
import '../l10n/app_localizations.dart';
import 'create_challenge_screen.dart';
import 'challenge_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().loadAll();
    });
  }

  void _openDetail(int challengeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailScreen(challengeId: challengeId),
      ),
    );
  }

  void _openCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateChallengeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.challenge,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: AppTheme.accent,
                    indicatorWeight: 2,
                    labelColor: AppTheme.accent,
                    unselectedLabelColor: const Color(0xFF52525B),
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.challengeOpenTab),
                      Tab(text: AppLocalizations.of(context)!.challengeMyTab),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accent.withAlpha(30)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sports_tennis, color: AppTheme.accent.withAlpha(180), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.challengeHint,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    _OpenTab(onTap: _openDetail),
                    _MyTab(onTap: _openDetail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _openCreate,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withAlpha(76),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _OpenTab extends StatelessWidget {
  final void Function(int) onTap;

  const _OpenTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingOpen) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.openChallenges.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noOpenChallenges,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadOpenChallenges(),
          color: AppTheme.accent,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.openChallenges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final challenge = provider.openChallenges[index];
              return ChallengeCard(
                challenge: challenge,
                onTap: () => onTap(challenge.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _MyTab extends StatelessWidget {
  final void Function(int) onTap;

  const _MyTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingMy) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        if (provider.myChallenges.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noMyChallenges,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMyChallenges(),
          color: AppTheme.accent,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.myChallenges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final challenge = provider.myChallenges[index];
              return ChallengeCard(
                challenge: challenge,
                onTap: () => onTap(challenge.id),
              );
            },
          ),
        );
      },
    );
  }
}
