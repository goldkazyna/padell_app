import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'notifications_screen.dart';

class NotificationCategoriesScreen extends StatefulWidget {
  const NotificationCategoriesScreen({super.key});

  @override
  State<NotificationCategoriesScreen> createState() => _NotificationCategoriesScreenState();
}

class _NotificationCategoriesScreenState extends State<NotificationCategoriesScreen> {
  final _api = ApiService();
  final _storage = StorageService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.getToken();
      final response = await _api.get('/notifications/categories', token);
      if (response['success'] == true) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response['categories'] ?? []);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _categoryName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'tournament': return l10n.navTournaments;
      case 'booking': return l10n.booking;
      case 'challenge': return l10n.navChallenges;
      case 'general': return l10n.notifCategoryGeneral;
      default: return key;
    }
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    l10n.notifications,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Categories
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.accent,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final key = cat['key'] as String? ?? 'general';
                          final color = _parseColor(cat['color'] as String? ?? '#A78BFA');
                          final unread = cat['unread'] as int? ?? 0;
                          final lastTitle = cat['last_title'] as String?;
                          final lastBody = cat['last_body'] as String?;
                          final hasUnread = unread > 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NotificationsScreen(category: key),
                                  ),
                                );
                                _load(); // Refresh counts on return
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    // Точка с glow
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: hasUnread ? color : const Color(0xFF3F3F46),
                                        shape: BoxShape.circle,
                                        boxShadow: hasUnread
                                            ? [BoxShadow(color: color.withAlpha(150), blurRadius: 8)]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _categoryName(key, l10n),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: hasUnread ? AppTheme.textPrimary : const Color(0xFF71717A),
                                            ),
                                          ),
                                          if (lastTitle != null || lastBody != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              lastTitle ?? lastBody ?? '',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF52525B)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Badge + arrow
                                    if (hasUnread)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius: BorderRadius.circular(11),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    const Icon(Icons.chevron_right, color: Color(0xFF3F3F46), size: 18),
                                  ],
                                ),
                              ),
                            ),
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
