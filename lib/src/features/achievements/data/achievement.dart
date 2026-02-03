import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 4)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titleKey; // Localization key

  @HiveField(2)
  final String descriptionKey; // Localization key

  @HiveField(3)
  final String iconName; // Material icon name

  @HiveField(4)
  final int targetValue;

  @HiveField(5)
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.iconName,
    required this.targetValue,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  void unlock() {
    unlockedAt = DateTime.now();
    // Note: Persistence is handled by AchievementService.unlockAchievement()
    // Removed save() call to prevent HiveError on non-boxed objects
  }

  Achievement copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    String? iconName,
    int? targetValue,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      iconName: iconName ?? this.iconName,
      targetValue: targetValue ?? this.targetValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
