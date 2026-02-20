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

  PushNotificationService(
    this._apiService,
    this._storageService,
    this._navigatorKey,
  );

  Future<void> initialize() async {
    debugPrint('[PUSH] ===== PUSH INIT START =====');
    debugPrint('[PUSH] Platform: ${Platform.operatingSystem}');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('[PUSH] Background handler registered');

    // Check if Firebase is initialized
    try {
      final apps = Firebase.apps;
      debugPrint('[PUSH] Firebase apps: ${apps.map((a) => a.name).toList()}');
    } catch (e) {
      debugPrint('[PUSH] Firebase apps check error: $e');
    }

    // Request permissions
    debugPrint('[PUSH] Requesting permissions...');
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[PUSH] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('[PUSH] ===== PUSH INIT ABORTED (not authorized) =====');
        return;
      }
    } catch (e) {
      debugPrint('[PUSH] Permission request error: $e');
      return;
    }

    // Setup local notifications for foreground
    debugPrint('[PUSH] Setting up local notifications...');
    try {
      await _setupLocalNotifications();
      debugPrint('[PUSH] Local notifications setup OK');
    } catch (e) {
      debugPrint('[PUSH] Local notifications setup error: $e');
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from notification (app terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[PUSH] App opened from notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage);
    }

    // Get APNs token (iOS only)
    if (Platform.isIOS) {
      debugPrint('[PUSH] Getting APNs token...');
      try {
        final apnsToken = await _messaging.getAPNSToken();
        debugPrint('[PUSH] APNs token: ${apnsToken != null ? "${apnsToken.substring(0, 20)}..." : "NULL"}');
        if (apnsToken == null) {
          debugPrint('[PUSH] WARNING: APNs token is null! FCM will not work on iOS.');
          debugPrint('[PUSH] Check: 1) Push Notifications capability 2) APNs key in Firebase 3) Entitlements');
        }
      } catch (e) {
        debugPrint('[PUSH] APNs token error: $e');
      }
    }

    // Get and send FCM token
    debugPrint('[PUSH] Getting FCM token...');
    await registerToken();

    // Subscribe to topics
    debugPrint('[PUSH] Subscribing to topics...');
    await _subscribeToTopics();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('[PUSH] Token refreshed: ${token.substring(0, 20)}...');
      _sendTokenToServer(token);
    });

    debugPrint('[PUSH] ===== PUSH INIT COMPLETE =====');
  }

  /// Public method — call after login to send FCM token to server
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[PUSH] FCM Token: ${token.substring(0, 30)}...');
        await _sendTokenToServer(token);
      } else {
        debugPrint('[PUSH] FCM Token is NULL!');
        if (Platform.isIOS) {
          debugPrint('[PUSH] iOS: Check APNs configuration. FCM requires APNs token first.');
        }
      }
    } catch (e, stack) {
      debugPrint('[PUSH] Error getting FCM token: $e');
      debugPrint('[PUSH] Stack: $stack');
    }
  }

  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('tournaments');
      debugPrint('[PUSH] Subscribed to topics: all_users, tournaments');
    } catch (e) {
      debugPrint('[PUSH] Error subscribing to topics: $e');
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
    debugPrint('[PUSH] Foreground message: ${message.notification?.title}');

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
    debugPrint('[PUSH] Local notification tapped: ${details.payload}');
    final payload = details.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    final type = parts[0];
    final id = parts.length > 1 ? parts[1] : '';

    _navigateByType(type, id);
  }

  /// Handle tap on FCM notification (background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[PUSH] Notification tap: ${message.data}');
    final type = message.data['type'] ?? '';
    final tournamentId = message.data['tournament_id'] ?? '';
    _navigateByType(type, tournamentId);
  }

  void _navigateByType(String type, String id) {
    debugPrint('[PUSH] Navigate: type=$type, id=$id');
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
      if (authToken == null) {
        debugPrint('[PUSH] No auth token, skipping server registration');
        return;
      }

      debugPrint('[PUSH] Sending FCM token to server (platform: ${Platform.isIOS ? "ios" : "android"})...');
      final response = await _apiService.post(
        '/devices/register',
        {'token': fcmToken, 'platform': Platform.isIOS ? 'ios' : 'android'},
        authToken,
      );
      debugPrint('[PUSH] Server response: $response');
    } catch (e) {
      debugPrint('[PUSH] Error sending FCM token to server: $e');
    }
  }
}
