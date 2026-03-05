import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/database/database_service.dart';
import 'package:pengespareapp/src/core/services/notification_service.dart';
import 'package:pengespareapp/src/core/services/error_log_service.dart';
import 'package:pengespareapp/src/features/achievements/services/achievement_service.dart';
import 'package:pengespareapp/src/core/theme/app_theme.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:pengespareapp/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pengespareapp/src/features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  try {
    tz.initializeTimeZones();
    // Use device local timezone from platform. Do not hardcode region,
    // otherwise notifications drift when user travels.
  } catch (e) {
    print('⚠️ Timezone init failed, using device default: $e');
  }

  // Initialize Hive database FIRST (required by ErrorLogService)
  await _safeInit('DatabaseService', () async {
    await DatabaseService.init();
  });

  // Initialize error logging after Hive is ready
  await _safeInit('ErrorLogService', () async {
    await ErrorLogService.initialize();
  });

  // Initialize achievement service
  await _safeInit('AchievementService', () async {
    await AchievementService().initialize();
  });

  // Initialize notifications (guarded + timeout to avoid splash hang)
  await _safeInit('NotificationService', () async {
    await NotificationService()
        .initialize()
        .timeout(const Duration(seconds: 8));
  });

  // Reschedule any notifications lost due to reboot / system update / Samsung deep sleep
  await _safeInit('NotificationReschedule', () async {
    await _rescheduleNotificationsIfNeeded();
  });

  // Validate streak on app startup (in case user hasn't opened app in days)
  await _safeInit('StreakValidation', () async {
    await _validateStreakOnStartup();
  });

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _safeInit(String name, Future<void> Function() action) async {
  try {
    await action();
  } catch (e, stackTrace) {
    print('⚠️ $name init failed: $e');
    try {
      ErrorLogService.logError(
        errorType: '${name}InitError',
        errorMessage: e.toString(),
        stackTrace: stackTrace.toString(),
      );
    } catch (_) {
      // ErrorLogService may not be ready; ignore
    }
  }
}
/// Reschedule any notifications that were lost due to a device reboot,
/// system update (Samsung/Android), or aggressive battery optimisation
/// killing the scheduled alarm. Runs on every cold start as a safety net.
Future<void> _rescheduleNotificationsIfNeeded() async {
  try {
    final activeProducts = DatabaseService.getActiveProducts();
    // Only care about products still waiting with a future timer end
    final needsNotification = activeProducts
        .where((p) =>
            p.status == ProductStatus.waiting && !p.isTimerFinished)
        .toList();

    if (needsNotification.isEmpty) return;

    // Fetch currently pending notifications once
    final pending = await NotificationService().getPendingNotifications();
    final pendingIds = pending.map((n) => n.id).toSet();

    int rescheduled = 0;
    for (final product in needsNotification) {
      final notificationId = product.id.hashCode;
      if (!pendingIds.contains(notificationId)) {
        // Alarm is gone – reschedule silently
        try {
          await NotificationService().scheduleProductNotification(
            productId: product.id,
            productName: product.name,
            scheduledTime: product.timerEndDate,
          );
          rescheduled++;
        } catch (e) {
          print('\u26a0\ufe0f Could not reschedule notification for ${product.name}: $e');
        }
      }
    }

    if (rescheduled > 0) {
      print('\ud83d\udd04 Rescheduled $rescheduled notification(s) after boot/update/sleep');
    }
  } catch (e) {
    print('\u26a0\ufe0f Error in _rescheduleNotificationsIfNeeded: $e');
  }
}
/// Check if streak should be reset due to inactivity
Future<void> _validateStreakOnStartup() async {
  try {
    final settings = DatabaseService.getSettings();
    
    if (settings.lastDecisionDate == null) {
      // No decisions made yet, nothing to validate
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      settings.lastDecisionDate!.year,
      settings.lastDecisionDate!.month,
      settings.lastDecisionDate!.day,
    );
    
    final daysSinceLastDecision = today.difference(lastDate).inDays;
    
    // If more than 1 day has passed without a decision, reset streak
    if (daysSinceLastDecision > 1 && settings.currentStreak > 0) {
      print('🔄 Resetting streak: $daysSinceLastDecision days of inactivity');
      final updatedSettings = settings.copyWith(
        currentStreak: 0,
      );
      await DatabaseService.updateSettings(updatedSettings);
    }
  } catch (e) {
    print('⚠️ Error validating streak: $e');
    // Don't crash the app if streak validation fails
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'SpareMester',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('nb'), // Norwegian Bokmål
      ],
      locale: Locale(settings.languageCode),

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Initial route based on onboarding status
      initialRoute: settings.hasCompletedOnboarding ? '/home' : '/onboarding',

      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
