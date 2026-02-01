import 'package:hive/hive.dart';
import 'package:pengespareapp/src/features/products/domain/models/product_category.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  String? url;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  int desireScore; // 1-10

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime timerEndDate;

  @HiveField(8)
  ProductStatus status;

  @HiveField(9)
  PurchaseDecision? decision;

  @HiveField(10)
  DateTime? decisionDate;

  @HiveField(11)
  ProductCategory category;

  @HiveField(12)
  int? extendedCooldownDays;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.url,
    this.imageUrl,
    required this.desireScore,
    required this.createdAt,
    required this.timerEndDate,
    this.status = ProductStatus.waiting,
    this.decision,
    this.decisionDate,
    this.category = ProductCategory.other,
    this.extendedCooldownDays,
  });

  // Calculate work hours based on hourly wage
  double calculateWorkHours(double hourlyWage) {
    if (hourlyWage <= 0) return 0;
    return price / hourlyWage;
  }

  // Check if timer has finished
  bool get isTimerFinished => DateTime.now().isAfter(timerEndDate);

  // Get remaining time
  Duration get timeRemaining {
    if (isTimerFinished) return Duration.zero;
    return timerEndDate.difference(DateTime.now());
  }

  // Get progress percentage (0.0 to 1.0)
  double get progress {
    final totalDuration = timerEndDate.difference(createdAt);
    final elapsed = DateTime.now().difference(createdAt);
    
    if (totalDuration.inSeconds == 0) return 1.0;
    final progress = elapsed.inSeconds / totalDuration.inSeconds;
    return progress.clamp(0.0, 1.0);
  }
}

@HiveType(typeId: 1)
enum ProductStatus {
  @HiveField(0)
  waiting, // Timer is still running

  @HiveField(1)
  completed, // Timer finished, awaiting decision

  @HiveField(2)
  archived, // User said "No" or marked as bought
}

@HiveType(typeId: 2)
enum PurchaseDecision {
  @HiveField(0)
  impulseBuy, // User clicked "I Am Weak" during countdown

  @HiveField(1)
  plannedPurchase, // User said "Yes" after timer finished

  @HiveField(2)
  avoided, // User said "No" after timer finished (money saved!)
}
