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
  debugPrint('Background message: ${message.messageId}');
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

  PushNotificationService(
    this._apiService,
    this._storageService,
    this._navigatorKey,
  );

  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    // Setup local notifications for foreground
    await _setupLocalNotifications();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from notification (app terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get and send FCM token (will silently skip if not logged in)
    await registerToken();

    // Subscribe to topics
    await _subscribeToTopics();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _sendTokenToServer(token);
    });
  }

  /// Public method — call after login to send FCM token to server
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('tournaments');
      debugPrint('Subscribed to topics: all_users, tournaments');
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
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
    debugPrint('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    // Encode type and id into payload for local notification tap
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

  /// Handle tap on local notification (foreground notifications)
  void _onNotificationTapped(NotificationResponse details) {
    debugPrint('Local notification tapped: ${details.payload}');
    final payload = details.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    final type = parts[0];
    final id = parts.length > 1 ? parts[1] : '';

    _navigateByType(type, id);
  }

  /// Handle tap on FCM notification (background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tap: ${message.data}');
    final type = message.data['type'] ?? '';
    final tournamentId = message.data['tournament_id'] ?? '';
    _navigateByType(type, tournamentId);
  }

  void _navigateByType(String type, String id) {
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
    // type: "test" — do nothing, just a test push
  }

  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      final authToken = await _storageService.getToken();
      if (authToken == null) return;

      await _apiService.post(
        '/devices/register',
        {'token': fcmToken, 'platform': Platform.isIOS ? 'ios' : 'android'},
        authToken,
      );
      debugPrint('FCM token sent to server');
    } catch (e) {
      debugPrint('Error sending FCM token: $e');
    }
  }
}
