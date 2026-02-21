import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../screens/tournament_detail_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[PUSH] Background message: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService;
  final StorageService _storageService;
  final GlobalKey<NavigatorState> _navigatorKey;

  static const _channelId = 'padel_notifications';
  static const _channelName = 'Уведомления';
  static const _channelDescription = 'Уведомления о турнирах и матчах';

  /// In-memory log buffer — visible on screen via showDebugLog()
  final List<String> _logs = [];
  String get debugLog => _logs.join('\n');

  PushNotificationService(
    this._apiService,
    this._storageService,
    this._navigatorKey,
  );

  /// Set app badge to specific number (iOS)
  Future<void> setBadge(int count) async {
    try {
      if (Platform.isIOS) {
        await _localNotifications.show(
          999,
          null,
          null,
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: false,
              presentSound: false,
              badgeNumber: count,
            ),
          ),
        );
        await _localNotifications.cancel(999);
      }
      _log('Badge set to $count');
    } catch (e) {
      _log('Set badge error: $e');
    }
  }

  /// Fetch unread count from API and update badge
  Future<void> updateBadge() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return;
      final response = await _apiService.get('/notifications/unread-count', token);
      final count = response['count'] as int? ?? 0;
      await setBadge(count);
    } catch (e) {
      _log('Update badge error: $e');
    }
  }

  void _log(String msg) {
    final time = DateTime.now().toString().substring(11, 19);
    final line = '[$time] $msg';
    _logs.add(line);
    debugPrint('[PUSH] $msg');
  }

  /// Show debug log dialog on screen
  void showDebugLog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Push Debug Log', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              _logs.isEmpty ? 'No logs yet' : _logs.join('\n'),
              style: const TextStyle(color: Colors.green, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> initialize() async {
    _log('===== PUSH INIT START =====');
    _log('Platform: ${Platform.operatingSystem}');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _log('Background handler registered');

    // Check if Firebase is initialized
    try {
      final apps = Firebase.apps;
      _log('Firebase apps: ${apps.map((a) => a.name).toList()}');
    } catch (e) {
      _log('Firebase apps check error: $e');
    }

    // Request permissions
    _log('Requesting permissions...');
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        _log('===== PUSH INIT ABORTED (not authorized) =====');
        return;
      }
    } catch (e) {
      _log('Permission request error: $e');
      return;
    }

    // Update badge with actual unread count
    updateBadge();

    // iOS: allow notifications to show when app is in foreground
    if (Platform.isIOS) {
      _log('Setting iOS foreground presentation options...');
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('iOS foreground options set');
    }

    // Setup local notifications for foreground
    _log('Setting up local notifications...');
    try {
      await _setupLocalNotifications();
      _log('Local notifications setup OK');
    } catch (e) {
      _log('Local notifications setup error: $e');
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from notification (app terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _log('App opened from notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage);
    }

    // Get APNs token (iOS only)
    if (Platform.isIOS) {
      _log('Getting APNs token...');
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          _log('APNs token: ${apnsToken.substring(0, 20)}...');
        } else {
          _log('APNs token: NULL!');
          _log('Check: 1) Entitlements 2) APNs key in Firebase 3) Provisioning profile');
        }
      } catch (e) {
        _log('APNs token error: $e');
      }
    }

    // Get and send FCM token
    _log('Getting FCM token...');
    await registerToken();

    // Subscribe to topics
    _log('Subscribing to topics...');
    await _subscribeToTopics();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _log('Token refreshed: ${token.substring(0, 20)}...');
      _sendTokenToServer(token);
    });

    _log('===== PUSH INIT COMPLETE =====');
  }

  /// Public method — call after login to send FCM token to server
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _log('FCM Token: ${token.substring(0, 30)}...');
        await _sendTokenToServer(token);
      } else {
        _log('FCM Token is NULL!');
        if (Platform.isIOS) {
          _log('iOS: FCM requires APNs token first.');
        }
      }
    } catch (e, stack) {
      _log('Error getting FCM token: $e');
      _log('Stack: $stack');
    }
  }

  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('tournaments');
      _log('Subscribed to topics OK');
    } catch (e) {
      _log('Error subscribing to topics: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _log('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] ?? '';
    final tournamentId = message.data['tournament_id'] ?? '';
    final payload = '$type|$tournamentId';

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _onNotificationTapped(NotificationResponse details) {
    _log('Local notification tapped: ${details.payload}');
    final payload = details.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    final type = parts[0];
    final id = parts.length > 1 ? parts[1] : '';

    _navigateByType(type, id);
  }

  void _handleNotificationTap(RemoteMessage message) {
    _log('Notification tap: ${message.data}');
    final type = message.data['type'] ?? '';
    final tournamentId = message.data['tournament_id'] ?? '';
    _navigateByType(type, tournamentId);
  }

  void _navigateByType(String type, String id) {
    _log('Navigate: type=$type, id=$id');
    if (type == 'tournament' && id.isNotEmpty) {
      final tournamentId = int.tryParse(id);
      if (tournamentId != null) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) =>
                TournamentDetailScreen(tournamentId: tournamentId),
          ),
        );
      }
    }
  }

  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      final authToken = await _storageService.getToken();
      if (authToken == null) {
        _log('No auth token, skipping server registration');
        return;
      }

      _log('Sending to server (${Platform.isIOS ? "ios" : "android"})...');
      final response = await _apiService.post(
        '/devices/register',
        {'token': fcmToken, 'platform': Platform.isIOS ? 'ios' : 'android'},
        authToken,
      );
      _log('Server response: $response');
    } catch (e) {
      _log('Error sending to server: $e');
    }
  }
}
