import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/amigo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/player_avatar.dart';

/// Заблокированные игроки: посмотреть и вернуть обратно.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AmigoProvider>().loadBlocked(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<AmigoProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 12),
                      Text(
                        l10n.blockedList,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                    children: [
                      if (provider.blocked.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2A3330),
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              l10n.blockedEmpty,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF2A3330),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              for (final user in provider.blocked)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      PlayerAvatar(
                                        name: user.name,
                                        avatarUrl: user.avatar,
                                        size: 38,
                                        circle: true,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (user.blockedAt != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                l10n.blockedAt(
                                                  DateFormat('d MMM').format(
                                                    user.blockedAt!.toLocal(),
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => context
                                            .read<AmigoProvider>()
                                            .unblock(user.id),
                                        child: Container(
                                          height: 32,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: const Color(0xFF2A3330),
                                            ),
                                          ),
                                          child: Text(
                                            l10n.unblockAction,
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
