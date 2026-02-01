import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/database/database_service.dart';
import 'package:pengespareapp/src/core/services/notification_service.dart';
import 'package:pengespareapp/src/core/services/error_log_service.dart';
import 'package:pengespareapp/src/features/achievements/services/achievement_service.dart';
import 'package:pengespareapp/src/core/theme/app_theme.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pengespareapp/src/features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error logging first
  await ErrorLogService.initialize();
  
  // Initialize timezone database
  tz.initializeTimeZones();
  // Set local timezone to Oslo/Europe (Norway)
  tz.setLocalLocation(tz.getLocation('Europe/Oslo'));
  
  // Initialize Hive database
  await DatabaseService.init();
  
  // Initialize achievement service
  await AchievementService().initialize();
  
  // Initialize notifications
  await NotificationService().initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
