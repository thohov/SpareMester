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
      final updated = state.copyWith(
        currency: currency,
        currencySymbol: symbol,
      );
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateHourlyWage(double wage) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(hourlyWage: wage);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateLanguage(String languageCode) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(languageCode: languageCode);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateSmallAmountWaitHours(int hours) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(smallAmountWaitHours: hours);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateMediumAmountWaitDays(int days) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(mediumAmountWaitDays: days);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateLargeAmountWaitDays(int days) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(largeAmountWaitDays: days);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateSmallAmountThreshold(int threshold) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(smallAmountThreshold: threshold);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateMediumAmountThreshold(int threshold) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(mediumAmountThreshold: threshold);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> toggleUseMinutesForSmallAmount(bool useMinutes) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(useMinutesForSmallAmount: useMinutes);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  Future<void> updateMonthlyBudget(double? budget) async {
    await _lock.synchronized(() async {
      final updated = state.copyWith(monthlyBudget: budget);
      await DatabaseService.updateSettings(updated);
      state = DatabaseService.getSettings();
    });
  }

  void refresh() {
    state = DatabaseService.getSettings();
  }

  void refreshSettings() {
    state = DatabaseService.getSettings();
  }
}
