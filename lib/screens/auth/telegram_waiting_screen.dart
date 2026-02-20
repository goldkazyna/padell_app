import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../services/push_notification_service.dart';
import '../../theme/app_theme.dart';

class TelegramWaitingScreen extends StatefulWidget {
  const TelegramWaitingScreen({super.key});

  @override
  State<TelegramWaitingScreen> createState() => _TelegramWaitingScreenState();
}

class _TelegramWaitingScreenState extends State<TelegramWaitingScreen> {
  String? _telegramUrl;
  bool _initError = false;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTelegramAuth();
      _authProvider.addListener(_onAuthChanged);
    });
  }

  void _onAuthChanged() {
    if (_authProvider.isAuthenticated && mounted) {
      // Send FCM token to server after telegram login
      context.read<PushNotificationService>().registerToken();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _initTelegramAuth() async {
    setState(() => _initError = false);
    try {
      _telegramUrl = await _authProvider.startTelegramAuth();
      _openTelegram();
    } catch (_) {
      if (mounted) setState(() => _initError = true);
    }
  }

  Future<void> _openTelegram() async {
    if (_telegramUrl == null) return;

    final uri = Uri.parse(_telegramUrl!);
    var bot = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    if (bot.isEmpty) bot = 'padel_kz_bot';
    final start = uri.queryParameters['start'] ?? '';
    final correctUrl = Uri.parse('https://t.me/$bot?start=$start');

    // 1. Открыть напрямую в Telegram (не в браузере)
    try {
      final ok = await launchUrl(
        correctUrl,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (ok) return;
    } catch (_) {}

    // 2. tg:// схема
    try {
      final tgUri = Uri.parse('tg://resolve?domain=$bot&start=$start');
      final ok = await launchUrl(tgUri);
      if (ok) return;
    } catch (_) {}

    // 3. Браузер
    await launchUrl(correctUrl, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    if (!_authProvider.isAuthenticated) {
      _authProvider.cancelTelegramAuth();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Spacer(),

              // Telegram icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF38A5E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),

              const Text(
                'Подтвердите вход',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Нажмите Start в Telegram боте\nи вернитесь в приложение',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              if (_initError) ...[
                const Text(
                  'Не удалось подключиться',
                  style: TextStyle(color: AppTheme.error, fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _initTelegramAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Попробовать снова',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ] else ...[
                // Spinner
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ожидание подтверждения...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),

                // Open Telegram again
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openTelegram,
                    icon: const Icon(Icons.send, size: 20),
                    label: const Text(
                      'Открыть Telegram',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38A5E1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Cancel
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
