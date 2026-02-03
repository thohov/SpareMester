import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  String currency; // NOK, USD, EUR, GBP

  @HiveField(1)
  String currencySymbol; // kr, $, €, £

  @HiveField(2)
  double hourlyWage;

  @HiveField(3)
  String languageCode; // 'nb' or 'en'

  @HiveField(4)
  bool hasCompletedOnboarding;

  @HiveField(5)
  int smallAmountThreshold; // Default: 500 (24h wait)

  @HiveField(6)
  int mediumAmountThreshold; // Default: 2000 (7 days wait)

  // Above mediumAmountThreshold = large amount (30 days wait)

  @HiveField(7)
  int smallAmountWaitHours; // Default: 24

  @HiveField(8)
  int mediumAmountWaitDays; // Default: 7

  @HiveField(9)
  int largeAmountWaitDays; // Default: 30

  @HiveField(10)
  bool useMinutesForSmallAmount; // For testing: use minutes instead of hours

  @HiveField(11)
  int currentStreak; // Days in a row with good decisions

  @HiveField(12)
  int longestStreak; // Best streak ever

  @HiveField(13)
  DateTime? lastDecisionDate; // Last date a decision was made

  @HiveField(14)
  double? monthlyBudget; // Optional monthly spending budget

  AppSettings({
    this.currency = 'NOK',
    this.currencySymbol = 'kr',
    this.hourlyWage = 200.0,
    this.languageCode = 'nb',
    this.hasCompletedOnboarding = false,
    this.smallAmountThreshold = 500,
    this.mediumAmountThreshold = 2000,
    this.smallAmountWaitHours = 24,
    this.mediumAmountWaitDays = 7,
    this.largeAmountWaitDays = 30,
    this.useMinutesForSmallAmount = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastDecisionDate,
    this.monthlyBudget,
  });

  // Calculate waiting period for a given price
  DateTime calculateWaitingPeriod(double price) {
    final now = DateTime.now();

    if (price < smallAmountThreshold) {
      // Small amount: hours or minutes (for testing)
      if (useMinutesForSmallAmount) {
        return now.add(Duration(minutes: smallAmountWaitHours));
      }
      return now.add(Duration(hours: smallAmountWaitHours));
    } else if (price < mediumAmountThreshold) {
      // Medium amount: 7 days
      return now.add(Duration(days: mediumAmountWaitDays));
    } else {
      // Large amount: 30 days
      return now.add(Duration(days: largeAmountWaitDays));
    }
  }

  // Helper method to get formatted currency string
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} $currencySymbol';
  }

  // Create a copy with updated values
  AppSettings copyWith({
    String? currency,
    String? currencySymbol,
    double? hourlyWage,
    String? languageCode,
    bool? hasCompletedOnboarding,
    int? smallAmountThreshold,
    int? mediumAmountThreshold,
    int? smallAmountWaitHours,
    int? mediumAmountWaitDays,
    int? largeAmountWaitDays,
    bool? useMinutesForSmallAmount,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastDecisionDate,
    double? monthlyBudget,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      languageCode: languageCode ?? this.languageCode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      smallAmountThreshold: smallAmountThreshold ?? this.smallAmountThreshold,
      mediumAmountThreshold:
          mediumAmountThreshold ?? this.mediumAmountThreshold,
      smallAmountWaitHours: smallAmountWaitHours ?? this.smallAmountWaitHours,
      mediumAmountWaitDays: mediumAmountWaitDays ?? this.mediumAmountWaitDays,
      largeAmountWaitDays: largeAmountWaitDays ?? this.largeAmountWaitDays,
      useMinutesForSmallAmount:
          useMinutesForSmallAmount ?? this.useMinutesForSmallAmount,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDecisionDate: lastDecisionDate ?? this.lastDecisionDate,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }

  // Update streak when a decision is made
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDecisionDate == null) {
      // First decision ever
      currentStreak = 1;
      lastDecisionDate = today;
    } else {
      final lastDate = DateTime(
        lastDecisionDate!.year,
        lastDecisionDate!.month,
        lastDecisionDate!.day,
      );
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Same day, don't change streak
        return;
      } else if (daysDiff == 1) {
        // Consecutive day, increment streak
        currentStreak++;
      } else {
        // Break in streak, reset
        currentStreak = 1;
      }

      lastDecisionDate = today;
    }

    // Update longest streak if current is better
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    save();
  }
}

// Predefined currencies
class CurrencyData {
  final String code;
  final String symbol;
  final String name;

  const CurrencyData({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const List<CurrencyData> currencies = [
    CurrencyData(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone'),
    CurrencyData(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyData(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyData(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyData(code: 'SEK', symbol: 'kr', name: 'Swedish Krona'),
    CurrencyData(code: 'DKK', symbol: 'kr', name: 'Danish Krone'),
  ];
}
