import 'package:hive/hive.dart';

part 'product_category.g.dart';

@HiveType(typeId: 5)
enum ProductCategory {
  @HiveField(0)
  electronics('electronics', 'Elektronikk', '📱'),

  @HiveField(1)
  clothing('clothing', 'Klær', '👕'),

  @HiveField(2)
  food('food', 'Mat & Drikke', '🍔'),

  @HiveField(3)
  entertainment('entertainment', 'Underholdning', '🎮'),

  @HiveField(4)
  home('home', 'Hjem & Interiør', '🏠'),

  @HiveField(5)
  health('health', 'Helse & Skjønnhet', '💄'),

  @HiveField(6)
  sports('sports', 'Sport & Fritid', '⚽'),

  @HiveField(7)
  travel('travel', 'Reise', '✈️'),

  @HiveField(8)
  books('books', 'Bøker & Medier', '📚'),

  @HiveField(9)
  other('other', 'Annet', '📦');

  const ProductCategory(this.id, this.displayName, this.emoji);

  final String id;
  final String displayName;
  final String emoji;
}
