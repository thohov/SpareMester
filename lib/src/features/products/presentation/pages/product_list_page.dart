import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/products_provider.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:pengespareapp/src/features/products/domain/models/product_category.dart';
import 'package:pengespareapp/src/features/products/presentation/pages/add_product_page.dart';
import 'package:pengespareapp/src/features/products/presentation/widgets/product_card.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  ProductCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allProducts = ref.watch(productsProvider);

    // Filter by category if selected
    final products = _selectedCategory == null
        ? allProducts
        : allProducts.where((p) => p.category == _selectedCategory).toList();

    // Separate products by timer status - with error handling
    List<Product> completedProducts = [];
    List<Product> waitingProducts = [];
    
    try {
      completedProducts = products.where((p) {
        try {
          return p.isTimerFinished;
        } catch (e) {
          return false;
        }
      }).toList();
      
      waitingProducts = products.where((p) {
        try {
          return !p.isTimerFinished;
        } catch (e) {
          return true; // Treat corrupt products as waiting
        }
      }).toList();
    } catch (e) {
      // Fallback: treat all as waiting
      waitingProducts = products;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products),
        actions: [
          if (completedProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${completedProducts.length}'),
                avatar: const Icon(Icons.notifications_active, size: 18),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          // Category filter dropdown
          PopupMenuButton<ProductCategory?>(
            icon: Icon(
              _selectedCategory != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: _selectedCategory != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Filtrer etter kategori',
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem<ProductCategory?>(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      _selectedCategory == null ? Icons.check : null,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Alle kategorier'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...ProductCategory.values.map((category) => PopupMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          _selectedCategory == category ? Icons.check : null,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${category.emoji} ${category.displayName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noProductsYet,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tapPlusToAdd,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length +
                  (completedProducts.isNotEmpty && waitingProducts.isNotEmpty
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                // Show completed products first
                if (index < completedProducts.length) {
                  return ProductCard(
                    key: ValueKey(completedProducts[index].id),
                    product: completedProducts[index],
                  );
                }

                // Add divider between completed and waiting
                if (completedProducts.isNotEmpty &&
                    waitingProducts.isNotEmpty &&
                    index == completedProducts.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Venter',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  );
                }

                // Show waiting products
                final waitingIndex = index -
                    completedProducts.length -
                    (completedProducts.isNotEmpty && waitingProducts.isNotEmpty
                        ? 1
                        : 0);
                return ProductCard(
                  key: ValueKey(waitingProducts[waitingIndex].id),
                  product: waitingProducts[waitingIndex],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addProduct),
      ),
    );
  }
}
