import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';
import 'package:pengespareapp/src/core/database/database_service.dart';
import 'package:pengespareapp/src/features/settings/data/app_settings.dart';

// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(DatabaseService.getSettings());

  // Lock for thread-safe settings updates
  final _lock = Lock();

  Future<void> updateCurrency(String currency, String symbol) async {
    await _lock.synchronized(() async {
      final current = state;
      current.currency = currency;
      current.currencySymbol = symbol;
      await current.save();
      // Trigger rebuild with a fresh copy - preserve all fields
      final updated = DatabaseService.getSettings();
      state = AppSettings(
        currency: updated.currency,
        currencySymbol: updated.currencySymbol,
        hourlyWage: updated.hourlyWage,
        languageCode: updated.languageCode,
        hasCompletedOnboarding: updated.hasCompletedOnboarding,
        smallAmountThreshold: updated.smallAmountThreshold,
        mediumAmountThreshold: updated.mediumAmountThreshold,
        smallAmountWaitHours: updated.smallAmountWaitHours,
        mediumAmountWaitDays: updated.mediumAmountWaitDays,
        largeAmountWaitDays: updated.largeAmountWaitDays,
        useMinutesForSmallAmount: updated.useMinutesForSmallAmount,
        currentStreak: updated.currentStreak,
        longestStreak: updated.longestStreak,
        lastDecisionDate: updated.lastDecisionDate,
        monthlyBudget: updated.monthlyBudget,
      );
    });
  }

  Future<void> updateHourlyWage(double wage) async {
    await _lock.synchronized(() async {
      final current = state;
      current.hourlyWage = wage;
      await current.save();
      // Trigger rebuild with a fresh copy - preserve all fields
      final updated = DatabaseService.getSettings();
      state = AppSettings(
        currency: updated.currency,
        currencySymbol: updated.currencySymbol,
        hourlyWage: updated.hourlyWage,
        languageCode: updated.languageCode,
        hasCompletedOnboarding: updated.hasCompletedOnboarding,
        smallAmountThreshold: updated.smallAmountThreshold,
        mediumAmountThreshold: updated.mediumAmountThreshold,
        smallAmountWaitHours: updated.smallAmountWaitHours,
        mediumAmountWaitDays: updated.mediumAmountWaitDays,
        largeAmountWaitDays: updated.largeAmountWaitDays,
        useMinutesForSmallAmount: updated.useMinutesForSmallAmount,
        currentStreak: updated.currentStreak,
        longestStreak: updated.longestStreak,
        lastDecisionDate: updated.lastDecisionDate,
        monthlyBudget: updated.monthlyBudget,
      );
    });
  }

  Future<void> updateLanguage(String languageCode) async {
    await _lock.synchronized(() async {
      final current = state;
      current.languageCode = languageCode;
      await current.save();
      // Trigger rebuild with a fresh copy - preserve all fields
      final updated = DatabaseService.getSettings();
      state = AppSettings(
        currency: updated.currency,
        currencySymbol: updated.currencySymbol,
        hourlyWage: updated.hourlyWage,
        languageCode: updated.languageCode,
        hasCompletedOnboarding: updated.hasCompletedOnboarding,
        smallAmountThreshold: updated.smallAmountThreshold,
        mediumAmountThreshold: updated.mediumAmountThreshold,
        smallAmountWaitHours: updated.smallAmountWaitHours,
        mediumAmountWaitDays: updated.mediumAmountWaitDays,
        largeAmountWaitDays: updated.largeAmountWaitDays,
        useMinutesForSmallAmount: updated.useMinutesForSmallAmount,
        currentStreak: updated.currentStreak,
        longestStreak: updated.longestStreak,
        lastDecisionDate: updated.lastDecisionDate,
        monthlyBudget: updated.monthlyBudget,
      );
    });
  }

  Future<void> updateSmallAmountWaitHours(int hours) async {
    final current = state;
    current.smallAmountWaitHours = hours;
    await current.save();
    // Trigger rebuild by creating a new instance
    state = AppSettings(
      currency: current.currency,
      currencySymbol: current.currencySymbol,
      hourlyWage: current.hourlyWage,
      languageCode: current.languageCode,
      hasCompletedOnboarding: current.hasCompletedOnboarding,
      smallAmountThreshold: current.smallAmountThreshold,
      mediumAmountThreshold: current.mediumAmountThreshold,
      smallAmountWaitHours: hours,
      mediumAmountWaitDays: current.mediumAmountWaitDays,
      largeAmountWaitDays: current.largeAmountWaitDays,
      useMinutesForSmallAmount: current.useMinutesForSmallAmount,
    );
    // Also save to database to ensure persistence
    await DatabaseService.updateSettings(state);
  }

  Future<void> updateMediumAmountWaitDays(int days) async {
    final current = state;
    // Trigger rebuild by creating a new instance
    state = AppSettings(
      currency: current.currency,
      currencySymbol: current.currencySymbol,
      hourlyWage: current.hourlyWage,
      languageCode: current.languageCode,
      hasCompletedOnboarding: current.hasCompletedOnboarding,
      smallAmountThreshold: current.smallAmountThreshold,
      mediumAmountThreshold: current.mediumAmountThreshold,
      smallAmountWaitHours: current.smallAmountWaitHours,
      mediumAmountWaitDays: days,
      largeAmountWaitDays: current.largeAmountWaitDays,
      useMinutesForSmallAmount: current.useMinutesForSmallAmount,
    );
    // Also save to database to ensure persistence
    await DatabaseService.updateSettings(state);
  }

  Future<void> updateLargeAmountWaitDays(int days) async {
    final current = state;
    // Trigger rebuild by creating a new instance
    state = AppSettings(
      currency: current.currency,
      currencySymbol: current.currencySymbol,
      hourlyWage: current.hourlyWage,
      languageCode: current.languageCode,
      hasCompletedOnboarding: current.hasCompletedOnboarding,
      smallAmountThreshold: current.smallAmountThreshold,
      mediumAmountThreshold: current.mediumAmountThreshold,
      smallAmountWaitHours: current.smallAmountWaitHours,
      mediumAmountWaitDays: current.mediumAmountWaitDays,
      largeAmountWaitDays: days,
      useMinutesForSmallAmount: current.useMinutesForSmallAmount,
    );
    // Also save to database to ensure persistence
    await DatabaseService.updateSettings(state);
  }

  Future<void> updateSmallAmountThreshold(int threshold) async {
    final current = state;
    // Trigger rebuild by creating a new instance
    state = AppSettings(
      currency: current.currency,
      currencySymbol: current.currencySymbol,
      hourlyWage: current.hourlyWage,
      languageCode: current.languageCode,
      hasCompletedOnboarding: current.hasCompletedOnboarding,
      smallAmountThreshold: threshold,
      mediumAmountThreshold: current.mediumAmountThreshold,
      smallAmountWaitHours: current.smallAmountWaitHours,
      mediumAmountWaitDays: current.mediumAmountWaitDays,
      largeAmountWaitDays: current.largeAmountWaitDays,
      useMinutesForSmallAmount: current.useMinutesForSmallAmount,
    );
    // Also save to database to ensure persistence
    await DatabaseService.updateSettings(state);
  }

  Future<void> updateMediumAmountThreshold(int threshold) async {
    final current = state;
    // Trigger rebuild by creating a new instance
    state = AppSettings(
      currency: current.currency,
      currencySymbol: current.currencySymbol,
      hourlyWage: current.hourlyWage,
      languageCode: current.languageCode,
      hasCompletedOnboarding: current.hasCompletedOnboarding,
      smallAmountThreshold: current.smallAmountThreshold,
      mediumAmountThreshold: threshold,
      smallAmountWaitHours: current.smallAmountWaitHours,
      mediumAmountWaitDays: current.mediumAmountWaitDays,
      largeAmountWaitDays: current.largeAmountWaitDays,
      useMinutesForSmallAmount: current.useMinutesForSmallAmount,
    );
    // Also save to database to ensure persistence
    await DatabaseService.updateSettings(state);
  }

  Future<void> toggleUseMinutesForSmallAmount(bool useMinutes) async {
    final current = state;
    // Trigger rebuild by creating a new instance
    state = AppSettings(
      currency: current.currency,
      currencySymbol: current.currencySymbol,
      hourlyWage: current.hourlyWage,
      languageCode: current.languageCode,
      hasCompletedOnboarding: current.hasCompletedOnboarding,
      smallAmountThreshold: current.smallAmountThreshold,
      mediumAmountThreshold: current.mediumAmountThreshold,
      smallAmountWaitHours: current.smallAmountWaitHours,
      mediumAmountWaitDays: current.mediumAmountWaitDays,
      largeAmountWaitDays: current.largeAmountWaitDays,
      useMinutesForSmallAmount: useMinutes,
    );
    // Also save to database to ensure persistence
    await DatabaseService.updateSettings(state);
  }

  Future<void> updateMonthlyBudget(double? budget) async {
    await _lock.synchronized(() async {
      final current = state;
      current.monthlyBudget = budget;
      await current.save();
      // Trigger rebuild with a fresh copy - preserve all fields
      final updated = DatabaseService.getSettings();
      state = AppSettings(
        currency: updated.currency,
        currencySymbol: updated.currencySymbol,
        hourlyWage: updated.hourlyWage,
        languageCode: updated.languageCode,
        hasCompletedOnboarding: updated.hasCompletedOnboarding,
        smallAmountThreshold: updated.smallAmountThreshold,
        mediumAmountThreshold: updated.mediumAmountThreshold,
        smallAmountWaitHours: updated.smallAmountWaitHours,
        mediumAmountWaitDays: updated.mediumAmountWaitDays,
        largeAmountWaitDays: updated.largeAmountWaitDays,
        useMinutesForSmallAmount: updated.useMinutesForSmallAmount,
        currentStreak: updated.currentStreak,
        longestStreak: updated.longestStreak,
        lastDecisionDate: updated.lastDecisionDate,
        monthlyBudget: updated.monthlyBudget,
      );
    });
  }

  void refresh() {
    state = DatabaseService.getSettings();
  }

  void refreshSettings() {
    state = DatabaseService.getSettings();
  }
}
