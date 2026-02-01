import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    print('🔔 Initialiserer NotificationService...');

    // Request notification permission on Android 13+
    final notificationStatus = await Permission.notification.status;
    print('📱 Notification permission status: $notificationStatus');
    
    if (notificationStatus.isDenied) {
      print('⚠️ Ber om notification permission...');
      final result = await Permission.notification.request();
      print('✅ Notification permission result: $result');
    }

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      print('⚠️ Ber om exact alarm permission...');
      final result = await Permission.scheduleExactAlarm.request();
      print('✅ Exact alarm permission result: $result');
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    print('✅ NotificationService initialisert!');
    _initialized = true;
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
      rethrow;
    }
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
