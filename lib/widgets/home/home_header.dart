import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../screens/notifications_screen.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUnread();
  }

  Future<void> _checkUnread() async {
    try {
      final token = await StorageService().getToken();
      final response = await ApiService().get('/notifications/unread-count', token);
      final count = response['count'] as int? ?? 0;
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  void _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    // Refresh unread count when coming back
    _checkUnread();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, home, __) {
        final name = home.user?.name ?? '';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _openNotifications,
              child: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.textPrimary,
                      size: 22,
                    ),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
