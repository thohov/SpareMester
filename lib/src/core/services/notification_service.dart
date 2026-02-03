import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Completer<void>? _initCompleter;

  // Lock for thread-safe notification scheduling
  final _scheduleLock = Lock();

  Future<void> initialize() async {
    // Use Completer to ensure thread-safe initialization
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    print('🔔 Initialiserer NotificationService...');

    // Request notification permission on Android 13+ (API 33+)
    // On older Android versions (10-12), notifications are granted by default
    if (Platform.isAndroid) {
      try {
        final notificationStatus = await Permission.notification.status;
        print('📱 Notification permission status: $notificationStatus');

        if (notificationStatus.isDenied) {
          print('⚠️ Ber om notification permission...');
          final result = await Permission.notification.request();
          print('✅ Notification permission result: $result');
        }
      } catch (e) {
        // On Android < 13, Permission.notification may not exist
        // This is fine - notifications work by default on older versions
        print('ℹ️ Notification permission not needed on this Android version');
      }

      // Request exact alarm permission for Android 12+ (API 31+)
      try {
        if (await Permission.scheduleExactAlarm.isDenied) {
          print('⚠️ Ber om exact alarm permission...');
          final result = await Permission.scheduleExactAlarm.request();
          print('✅ Exact alarm permission result: $result');
        }
      } catch (e) {
        print('ℹ️ Exact alarm permission not needed on this Android version');
      }
    }

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    } catch (e) {
      print('⚠️ Notification initialization failed, clearing corrupt data: $e');
      // Try to cancel all notifications and reinitialize
      try {
        await _notifications.cancelAll();
      } catch (_) {
        // Ignore if cancelAll also fails
      }
      // Try initializing again
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    }

    // Clean up any potentially corrupt pending notifications
    try {
      final pending = await _notifications.pendingNotificationRequests();
      print('📋 Pending notifications at startup: ${pending.length}');
    } catch (e) {
      print('⚠️ Could not retrieve pending notifications, clearing all: $e');
      await _notifications.cancelAll();
    }

    print('✅ NotificationService initialisert!');
    _initCompleter!.complete();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific product
    // For now, we'll just log it
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleProductNotification({
    required String productId,
    required String productName,
    required DateTime scheduledTime,
  }) async {
    await _scheduleLock.synchronized(() async {
      await initialize();

      print('📅 Planlegger varsel for produkt: $productName');
      print('⏰ Tidspunkt: $scheduledTime');
      print('🆔 Notification ID: ${productId.hashCode}');

      const androidDetails = AndroidNotificationDetails(
        'product_timers',
        'Produkttimere',
        channelDescription: 'Varsler når ventetiden for et produkt er fullført',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Use product ID hash as notification ID to ensure uniqueness
      final notificationId = productId.hashCode;

      try {
        await _notifications.zonedSchedule(
          notificationId,
          'Ventetiden er over! ⏰',
          'Nå kan du bestemme om du vil kjøpe "$productName"',
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: productId,
        );

        print('✅ Varsel planlagt vellykket!');

        // Log all pending notifications
        final pending = await _notifications.pendingNotificationRequests();
        print('📋 Antall ventende varsler: ${pending.length}');
      } catch (e) {
        print('❌ Feil ved planlegging av varsel: $e');

        // If we get "Missing type parameter" error, it means there's corrupt notification data
        // Clear all notifications and try again
        if (e.toString().contains('Missing type parameter')) {
          print(
              '🔧 Detected corrupt notification data, clearing and retrying...');
          try {
            await _notifications.cancelAll();

            // Try scheduling again after cleanup
            await _notifications.zonedSchedule(
              notificationId,
              'Ventetiden er over! ⏰',
              'Nå kan du bestemme om du vil kjøpe "$productName"',
              tz.TZDateTime.from(scheduledTime, tz.local),
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: productId,
            );
            print('✅ Varsel planlagt etter cleanup!');
          } catch (retryError) {
            print('❌ Retry failed: $retryError');
            // Don't rethrow - we already saved the product, just log the notification failure
          }
        } else {
          // For other errors, just log but don't fail the whole operation
          // The product was already saved successfully
        }
      }
    });
  }

  Future<void> cancelProductNotification(String productId) async {
    final notificationId = productId.hashCode;
    await _notifications.cancel(notificationId);
    print('🗑️ Kansellert varsel for produkt ID: $productId');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ Alle varsler kansellert');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Test notification - shows immediately
  Future<void> showTestNotification() async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'product_timers',
      'Produkttimere',
      channelDescription: 'Varsler når ventetiden for et produkt er fullført',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999999,
      'Test Varsel 🔔',
      'Hvis du ser dette, fungerer varsler!',
      notificationDetails,
    );

    print('✅ Test varsel sendt!');
  }
}
