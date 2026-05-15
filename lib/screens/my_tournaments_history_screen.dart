import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/main_tab_bar.dart';
import '../widgets/profile/tournament_history.dart' show TournamentHistoryRow;

/// Полная история турниров пользователя (все завершённые).
/// Открывается из профиля по кнопке «Все» рядом с заголовком «История турниров».
class MyTournamentsHistoryScreen extends StatefulWidget {
  const MyTournamentsHistoryScreen({super.key});

  @override
  State<MyTournamentsHistoryScreen> createState() =>
      _MyTournamentsHistoryScreenState();
}

class _MyTournamentsHistoryScreenState
    extends State<MyTournamentsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadTournamentHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text(
          'История турниров',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: const MainTabBar(),
      body: Consumer<ProfileProvider>(
        builder: (_, profile, __) {
          final tournaments = profile.tournamentHistory;

          if (profile.isLoadingHistory && tournaments.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (tournaments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Сыгранных турниров пока нет',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () => profile.loadTournamentHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: 1,
              itemBuilder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < tournaments.length; i++)
                        TournamentHistoryRow(
                          tournament: tournaments[i],
                          isLast: i == tournaments.length - 1,
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
