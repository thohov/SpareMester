import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/products_provider.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/settings/data/app_settings.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:intl/intl.dart';

class ArchivePage extends ConsumerWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    // Watch allProductsProvider to get automatic updates when products are archived
    final allProducts = ref.watch(allProductsProvider);
    final archivedProducts = allProducts
        .where((p) => p.status == ProductStatus.archived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archive),
      ),
      body: archivedProducts.isEmpty
          ? _buildEmptyState(context, l10n)
          : _buildArchiveList(context, settings, archivedProducts, l10n),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noArchivedProducts,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.archivedProductsAppearHere,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveList(
    BuildContext context,
    AppSettings settings,
    List<Product> products,
    AppLocalizations l10n,
  ) {
    // Group by decision
    final avoided =
        products.where((p) => p.decision == PurchaseDecision.avoided).toList();
    final planned = products
        .where((p) => p.decision == PurchaseDecision.plannedPurchase)
        .toList();
    final impulse = products
        .where((p) => p.decision == PurchaseDecision.impulseBuy)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (avoided.isNotEmpty) ...[
          _buildSectionHeader(context, 'Unngått', Icons.block, Colors.green),
          ...avoided.map((p) => _buildArchiveCard(context, settings, p, l10n)),
          const SizedBox(height: 16),
        ],
        if (planned.isNotEmpty) ...[
          _buildSectionHeader(
              context, l10n.plannedPurchase, Icons.shopping_cart, Colors.blue),
          ...planned.map((p) => _buildArchiveCard(context, settings, p, l10n)),
          const SizedBox(height: 16),
        ],
        if (impulse.isNotEmpty) ...[
          _buildSectionHeader(
              context, l10n.impulseBuy, Icons.flash_on, Colors.orange),
          ...impulse.map((p) => _buildArchiveCard(context, settings, p, l10n)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveCard(
    BuildContext context,
    AppSettings settings,
    Product product,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final workHours = product.calculateWorkHours(settings.hourlyWage);

    Color getDecisionColor() {
      switch (product.decision) {
        case PurchaseDecision.avoided:
          return Colors.green;
        case PurchaseDecision.plannedPurchase:
          return Colors.blue;
        case PurchaseDecision.impulseBuy:
          return Colors.orange;
        case null:
          return Colors.grey;
      }
    }

    IconData getDecisionIcon() {
      switch (product.decision) {
        case PurchaseDecision.avoided:
          return Icons.block;
        case PurchaseDecision.plannedPurchase:
          return Icons.shopping_cart;
        case PurchaseDecision.impulseBuy:
          return Icons.flash_on;
        case null:
          return Icons.help_outline;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${settings.currencySymbol}${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getDecisionColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getDecisionIcon(),
                    color: getDecisionColor(),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.access_time,
              l10n.workHours('hours'),
              '${workHours.toStringAsFixed(1)} ${l10n.hours}',
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              l10n.decisionMade,
              product.decisionDate != null
                  ? dateFormat.format(product.decisionDate!)
                  : l10n.unknown,
            ),
            if (product.desireScore > 0) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                context,
                Icons.favorite,
                l10n.desireScore,
                '${product.desireScore}/10',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
