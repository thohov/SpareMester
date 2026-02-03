import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/src/core/database/database_service.dart';
import 'package:pengespareapp/src/core/services/notification_service.dart';
import 'package:pengespareapp/src/core/services/error_log_service.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:pengespareapp/src/features/products/domain/models/product_category.dart';
import 'package:pengespareapp/src/features/achievements/services/achievement_service.dart';
import 'package:pengespareapp/src/features/achievements/data/achievement.dart';
import 'package:uuid/uuid.dart';

// Products provider
final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier(ref);
});

// All products provider (including archived)
final allProductsProvider =
    StateNotifierProvider<AllProductsNotifier, List<Product>>((ref) {
  return AllProductsNotifier();
});

class AllProductsNotifier extends StateNotifier<List<Product>> {
  AllProductsNotifier() : super(_getAllProducts());

  static List<Product> _getAllProducts() {
    final box = DatabaseService.getProductsBox();
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void refresh() {
    state = _getAllProducts();
  }
}

class ProductsNotifier extends StateNotifier<List<Product>> {
  final Ref ref;

  ProductsNotifier(this.ref) : super(DatabaseService.getActiveProducts());

  void refresh() {
    state = DatabaseService.getActiveProducts();
    // Also refresh allProductsProvider to keep dashboard in sync
    ref.read(allProductsProvider.notifier).refresh();
  }

  Future<Product> addProduct({
    required String name,
    required double price,
    String? url,
    String? imageUrl,
    required int desireScore,
    ProductCategory category = ProductCategory.other,
  }) async {
    try {
      final settings = DatabaseService.getSettings();
      final timerEndDate = settings.calculateWaitingPeriod(price);

      final product = Product(
        id: const Uuid().v4(),
        name: name,
        price: price,
        url: url,
        imageUrl: imageUrl,
        desireScore: desireScore,
        createdAt: DateTime.now(),
        timerEndDate: timerEndDate,
        status: ProductStatus.waiting,
        category: category,
      );

      await DatabaseService.addProduct(product);

      // Schedule notification for when timer ends
      try {
        await NotificationService().scheduleProductNotification(
          productId: product.id,
          productName: product.name,
          scheduledTime: product.timerEndDate,
        );
      } catch (e) {
        // Log notification error but don't fail the whole operation
        print('⚠️ Failed to schedule notification: $e');
      }

      refresh();
      return product;
    } catch (e, stackTrace) {
      // Log the error for debugging
      ErrorLogService.logError(
        errorType: 'AddProductProviderError',
        errorMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        additionalContext: {
          'productName': '[REDACTED]',
          'price': '[REDACTED]',
          'category': category.toString(),
        },
      );
      print('❌ Error adding product: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    await DatabaseService.updateProduct(product);
    refresh();
  }

  Future<void> deleteProduct(String id) async {
    // Cancel notification when product is deleted
    await NotificationService().cancelProductNotification(id);
    await DatabaseService.deleteProduct(id);
    refresh();
  }

  Future<List<Achievement>> markAsImpulseBuy(Product product) async {
    // Cancel notification when decision is made
    await NotificationService().cancelProductNotification(product.id);
    product.status = ProductStatus.archived;
    product.decision = PurchaseDecision.impulseBuy;
    product.decisionDate = DateTime.now();
    await DatabaseService.updateProduct(product);

    // Update streak and check achievements
    final newAchievements = await _updateStreakAndAchievements();

    refresh();
    return newAchievements;
  }

  Future<List<Achievement>> markAsPlannedPurchase(Product product) async {
    // Cancel notification when decision is made
    await NotificationService().cancelProductNotification(product.id);
    product.status = ProductStatus.archived;
    product.decision = PurchaseDecision.plannedPurchase;
    product.decisionDate = DateTime.now();
    await DatabaseService.updateProduct(product);

    // Update streak and check achievements
    final newAchievements = await _updateStreakAndAchievements();

    refresh();
    return newAchievements;
  }

  Future<List<Achievement>> markAsAvoided(Product product) async {
    // Cancel notification when decision is made
    await NotificationService().cancelProductNotification(product.id);
    product.status = ProductStatus.archived;
    product.decision = PurchaseDecision.avoided;
    product.decisionDate = DateTime.now();
    await DatabaseService.updateProduct(product);

    // Update streak and check achievements
    final newAchievements = await _updateStreakAndAchievements();

    refresh();
    return newAchievements;
  }

  Future<void> extendCooldown(Product product, int days) async {
    // Set extended cooldown
    product.extendedCooldownDays = days;

    // Reset the timer by creating a new end date from now
    final now = DateTime.now();
    product.createdAt = now;
    product.timerEndDate = now.add(Duration(days: days));
    product.status = ProductStatus.waiting;

    // Clear any previous decision
    product.decision = null;
    product.decisionDate = null;

    await DatabaseService.updateProduct(product);

    // Schedule new notification
    await NotificationService().scheduleProductNotification(
      productId: product.id,
      productName: product.name,
      scheduledTime: product.timerEndDate,
    );

    refresh();
  }

  Future<List<Achievement>> _updateStreakAndAchievements() async {
    // Update streak in settings
    final settings = DatabaseService.getSettings();
    settings.updateStreak();
    await DatabaseService.updateSettings(settings);

    // Check for newly unlocked achievements
    final achievementService = AchievementService();
    await achievementService.initialize();

    // Get all products (active + archived)
    final allProducts = [
      ...DatabaseService.getActiveProducts(),
      ...DatabaseService.getArchivedProducts(),
    ];

    final newAchievements = await achievementService.checkAchievements(
      allProducts: allProducts,
      currentStreak: settings.currentStreak,
    );

    return newAchievements;
  }

  // Get products by status
  List<Product> getWaitingProducts() {
    return state
        .where((p) => p.status == ProductStatus.waiting && !p.isTimerFinished)
        .toList();
  }

  List<Product> getCompletedProducts() {
    return state
        .where((p) => p.status == ProductStatus.waiting && p.isTimerFinished)
        .toList();
  }
}

// Statistics provider
final statsProvider = Provider<Map<String, dynamic>>((ref) {
  // Watch both providers to recalculate when any products change
  ref.watch(productsProvider);
  ref.watch(allProductsProvider);
  return DatabaseService.calculateStats();
});
