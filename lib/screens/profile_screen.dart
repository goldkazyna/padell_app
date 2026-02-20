import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/push_notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/tournament_history.dart';
import '../widgets/profile/profile_menu.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(),
                  SizedBox(height: 16),
                  ProfileStats(),
                  SizedBox(height: 24),
                  TournamentHistory(),
                  SizedBox(height: 24),
                  ProfileMenu(),
                  SizedBox(height: 16),
                  _PushDebugButton(),
                  SizedBox(height: 20),
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
        child: const Text(
          'Push Debug Log',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
