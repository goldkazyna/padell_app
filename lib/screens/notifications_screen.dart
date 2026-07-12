import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/push_notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'tournament_detail_screen.dart';
import 'tournament_invitations_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String? category;

  const NotificationsScreen({super.key, this.category});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _apiService = ApiService();
  final _storageService = StorageService();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _nextPageUrl;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _nextPageUrl != null) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _storageService.getToken();
      final catParam = widget.category != null ? '?category=${widget.category}' : '';
      final response = await _apiService.get('/notifications$catParam', token);
      final list = response['data'] as List<dynamic>? ?? [];
      setState(() {
        _notifications = list.cast<Map<String, dynamic>>();
        _nextPageUrl = response['next_page_url'] as String?;
        _isLoading = false;
      });

      // Mark as read
      if (_notifications.any((n) => n['read_at'] == null)) {
        try {
          final readParam = widget.category != null ? '?category=${widget.category}' : '';
          await _apiService.post('/notifications/read-all$readParam', {}, token);
          if (mounted && widget.category == null) {
            context.read<PushNotificationService>().setBadge(0);
          }
        } catch (_) {}
      }
    } catch (e) {
      setState(() {
        _error = 'error';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_nextPageUrl == null || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final token = await _storageService.getToken();
      // Extract page parameter from next_page_url
      final uri = Uri.parse(_nextPageUrl!);
      final page = uri.queryParameters['page'] ?? '2';
      final catParam = widget.category != null ? '&category=${widget.category}' : '';
      final response =
          await _apiService.get('/notifications?page=$page$catParam', token);
      final list = response['data'] as List<dynamic>? ?? [];
      setState(() {
        _notifications.addAll(list.cast<Map<String, dynamic>>());
        _nextPageUrl = response['next_page_url'] as String?;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] as String? ?? '';
    final data = notification['data'] as Map<String, dynamic>? ?? {};
    final tournamentId = data['tournament_id'] ?? notification['tournament_id'];

    debugPrint('[NOTIF] Tap: type=$type, data=$data, tournament_id=$tournamentId');

    if (type == 'tournament_invite') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TournamentInvitationsScreen(),
        ),
      );
      return;
    }

    if (tournamentId != null) {
      final id = int.tryParse(tournamentId.toString());
      if (id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TournamentDetailScreen(tournamentId: id),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.notifications,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.failedToLoadNotifications,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _loadNotifications,
                                child: Text(AppLocalizations.of(context)!.retry),
                              ),
                            ],
                          ),
                        )
                      : _notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    color: AppTheme.textSecondary,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(context)!.noNotifications,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: AppTheme.accent,
                              backgroundColor: AppTheme.card,
                              onRefresh: _loadNotifications,
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                itemCount: _notifications.length +
                                    (_isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, index) {
                                  if (index == _notifications.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.accent,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  return _NotificationCard(
                                    notification: _notifications[index],
                                    onTap: () => _onNotificationTap(
                                        _notifications[index]),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final createdAt = notification['created_at'] as String? ?? '';
    final type = notification['type'] as String? ?? '';
    final isRead = notification['read_at'] != null;

    IconData iconData;
    Color iconColor;
    switch (type) {
      case 'registration_approved':
        iconData = Icons.check_circle_outline;
        iconColor = AppTheme.accent;
        break;
      case 'registration_rejected':
        iconData = Icons.cancel_outlined;
        iconColor = AppTheme.error;
        break;
      case 'slot_available':
        iconData = Icons.notification_important_outlined;
        iconColor = AppTheme.accent;
        break;
      default:
        iconData = Icons.notifications_outlined;
        iconColor = AppTheme.accent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? AppTheme.card : const Color(0xFF1A2A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead
              ? const Color(0xFF2A2A2A)
              : AppTheme.accent.withAlpha(80),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(createdAt, AppLocalizations.of(context)!),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      ),
    );
  }

  String _formatDate(String dateStr, AppLocalizations l10n) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return l10n.minutesAgo(diff.inMinutes);
      } else if (diff.inHours < 24) {
        return l10n.hoursAgo(diff.inHours);
      } else if (diff.inDays < 7) {
        return l10n.daysAgo(diff.inDays);
      }
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
