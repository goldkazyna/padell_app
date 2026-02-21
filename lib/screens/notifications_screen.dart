import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

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
      final response = await _apiService.get('/notifications', token);
      final list = response['data'] as List<dynamic>? ?? [];
      setState(() {
        _notifications = list.cast<Map<String, dynamic>>();
        _nextPageUrl = response['next_page_url'] as String?;
        _isLoading = false;
      });

      // Mark all as read
      if (_notifications.any((n) => n['read_at'] == null)) {
        try {
          await _apiService.post('/notifications/read-all', {}, token);
        } catch (_) {}
      }
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить уведомления';
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
      final response =
          await _apiService.get('/notifications?page=$page', token);
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2A2A2A),
                        width: 0.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppTheme.textPrimary, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Уведомления',
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
                                _error!,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _loadNotifications,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        )
                      : _notifications.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    color: AppTheme.textSecondary,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Нет уведомлений',
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

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final createdAt = notification['created_at'] as String? ?? '';
    final isRead = notification['read_at'] != null;

    return Container(
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
              color: AppTheme.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.accent,
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
                    style: const TextStyle(
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
                    _formatDate(createdAt),
                    style: const TextStyle(
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
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} мин. назад';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} ч. назад';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} дн. назад';
      }
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
