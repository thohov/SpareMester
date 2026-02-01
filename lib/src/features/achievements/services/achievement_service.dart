import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/achievement.dart';
import '../data/achievement_type.dart';
import '../../products/domain/models/product.dart';
import 'package:pengespareapp/src/core/database/database_service.dart';

class AchievementService {
  static const String _boxName = 'achievements';
  Box<Achievement>? _box;

  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AchievementAdapter());
    }
    _box = await Hive.openBox<Achievement>(_boxName);
    
    // Initialize all achievements if not already done
    for (final type in AchievementType.values) {
      if (!_box!.containsKey(type.id)) {
        final achievement = Achievement(
          id: type.id,
          titleKey: type.titleKey,
          descriptionKey: type.descriptionKey,
          iconName: type.iconName,
          targetValue: type.targetValue,
        );
        await _box!.put(type.id, achievement);
      }
    }
  }

  List<Achievement> getAllAchievements() {
    return _box?.values.toList() ?? [];
  }

  Achievement? getAchievement(String id) {
    return _box?.get(id);
  }

  Future<void> unlockAchievement(String id) async {
    final achievement = _box?.get(id);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.unlock();
    }
  }

  // Check and unlock achievements based on stats
  Future<List<Achievement>> checkAchievements({
    required List<Product> allProducts,
    required int currentStreak,
  }) async {
    final newlyUnlocked = <Achievement>[];
    
    // Count avoided products
    final avoidedCount = allProducts
        .where((p) => p.status == ProductStatus.archived && p.decision == PurchaseDecision.avoided)
        .length;
    
    // Count total archived with any decision
    final totalDecisions = allProducts
        .where((p) => p.status == ProductStatus.archived && p.decision != null)
        .length;
    
    // Count impulse buys
    final impulseBuyCount = allProducts
        .where((p) => p.status == ProductStatus.archived && p.decision == PurchaseDecision.impulseBuy)
        .length;
    
    // Count planned purchases
    final plannedCount = allProducts
        .where((p) => p.status == ProductStatus.archived && p.decision == PurchaseDecision.plannedPurchase)
        .length;
    
    // Calculate total saved (avoided products)
    final totalSaved = allProducts
        .where((p) => p.status == ProductStatus.archived && p.decision == PurchaseDecision.avoided)
        .fold<double>(0, (sum, p) => sum + p.price);
    
    // Check avoided achievements
    final avoidAchievements = [
      (AchievementType.firstAvoid, 1),
      (AchievementType.fiveAvoided, 5),
      (AchievementType.tenAvoided, 10),
      (AchievementType.twentyFiveAvoided, 25),
      (AchievementType.fiftyAvoided, 50),
      (AchievementType.hundredAvoided, 100),
    ];
    
    for (final (type, count) in avoidAchievements) {
      if (avoidedCount >= count) {
        final achievement = getAchievement(type.id);
        if (achievement != null && !achievement.isUnlocked) {
          await unlockAchievement(type.id);
          newlyUnlocked.add(achievement);
        }
      }
    }
    
    // Check streak achievements
    final streakAchievements = [
      (AchievementType.threeDayStreak, 3),
      (AchievementType.weekStreak, 7),
      (AchievementType.twoWeekStreak, 14),
      (AchievementType.monthStreak, 30),
      (AchievementType.fiftyDayStreak, 50),
      (AchievementType.hundredDayStreak, 100),
    ];
    
    for (final (type, days) in streakAchievements) {
      if (currentStreak >= days) {
        final achievement = getAchievement(type.id);
        if (achievement != null && !achievement.isUnlocked) {
          await unlockAchievement(type.id);
          newlyUnlocked.add(achievement);
        }
      }
    }
    
    // Check savings achievements
    final savingsAchievements = [
      (AchievementType.fiveHundredSaved, 500.0),
      (AchievementType.thousandSaved, 1000.0),
      (AchievementType.fiveThousandSaved, 5000.0),
      (AchievementType.tenThousandSaved, 10000.0),
      (AchievementType.twentyFiveThousandSaved, 25000.0),
      (AchievementType.fiftyThousandSaved, 50000.0),
    ];
    
    for (final (type, amount) in savingsAchievements) {
      if (totalSaved >= amount) {
        final achievement = getAchievement(type.id);
        if (achievement != null && !achievement.isUnlocked) {
          await unlockAchievement(type.id);
          newlyUnlocked.add(achievement);
        }
      }
    }
    
    // Check impulse control achievements
    if (totalDecisions >= 7 && impulseBuyCount == 0) {
      final achievement = getAchievement(AchievementType.perfectWeek.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.perfectWeek.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    if (totalDecisions >= 20 && impulseBuyCount == 0) {
      final achievement = getAchievement(AchievementType.noImpulse.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.noImpulse.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    // Total decisions
    if (totalDecisions >= 50) {
      final achievement = getAchievement(AchievementType.fiftyDecisions.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.fiftyDecisions.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    // Planned purchases
    if (plannedCount >= 1) {
      final achievement = getAchievement(AchievementType.firstPlanned.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.firstPlanned.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    if (plannedCount >= 10) {
      final achievement = getAchievement(AchievementType.tenPlanned.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.tenPlanned.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    // Expensive avoided (over 5000)
    final expensiveAvoided = allProducts
        .where((p) => 
            p.status == ProductStatus.archived && 
            p.decision == PurchaseDecision.avoided &&
            p.price >= 5000)
        .isNotEmpty;
    
    if (expensiveAvoided) {
      final achievement = getAchievement(AchievementType.expensiveAvoided.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.expensiveAvoided.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    // Check categories used
    final categoriesUsed = allProducts.map((p) => p.category).toSet().length;
    if (categoriesUsed >= 5) {
      final achievement = getAchievement(AchievementType.categoryMaster.id);
      if (achievement != null && !achievement.isUnlocked) {
        await unlockAchievement(AchievementType.categoryMaster.id);
        newlyUnlocked.add(achievement);
      }
    }
    
    // Check time-based achievements (last decision)
    final lastDecision = allProducts
        .where((p) => p.decisionDate != null)
        .isNotEmpty
        ? allProducts
            .where((p) => p.decisionDate != null)
            .reduce((a, b) => a.decisionDate!.isAfter(b.decisionDate!) ? a : b)
        : null;
    
    if (lastDecision?.decisionDate != null) {
      final hour = lastDecision!.decisionDate!.hour;
      
      // Early bird (before 8 AM)
      if (hour < 8) {
        final achievement = getAchievement(AchievementType.earlyBird.id);
        if (achievement != null && !achievement.isUnlocked) {
          await unlockAchievement(AchievementType.earlyBird.id);
          newlyUnlocked.add(achievement);
        }
      }
      
      // Night owl (after 10 PM)
      if (hour >= 22) {
        final achievement = getAchievement(AchievementType.nightOwl.id);
        if (achievement != null && !achievement.isUnlocked) {
          await unlockAchievement(AchievementType.nightOwl.id);
          newlyUnlocked.add(achievement);
        }
      }
    }
    
    return newlyUnlocked;
  }
}

// Provider for achievement service
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

// Provider for all achievements
final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final service = ref.watch(achievementServiceProvider);
  return Stream.periodic(const Duration(milliseconds: 500), (_) {
    return service.getAllAchievements();
  });
});
