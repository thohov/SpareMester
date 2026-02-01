import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/products_provider.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:pengespareapp/src/features/products/domain/models/product_category.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allProducts = ref.watch(allProductsProvider);
    final settings = ref.watch(settingsProvider);

    // Filter products with decisions
    final decidedProducts = allProducts
        .where((p) => p.decisionDate != null && p.decision != null)
        .toList();

    if (decidedProducts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Statistikk'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 100,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Ingen data ennå',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ta noen kjøpsbeslutninger for å se statistikk',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistikk'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        children: [
          // Savings Over Time Chart
          _SavingsOverTimeChart(
            products: decidedProducts,
            settings: settings,
          ),
          const SizedBox(height: 32),

          // Category Distribution
          _CategoryDistributionChart(
            products: decidedProducts,
            settings: settings,
          ),
          const SizedBox(height: 32),

          // Decision Type Distribution
          _DecisionTypeChart(
            products: decidedProducts,
            settings: settings,
          ),
          const SizedBox(height: 32),

          // Monthly Spending Trend
          _MonthlySpendingChart(
            products: decidedProducts,
            settings: settings,
          ),
        ],
      ),
    );
  }
}

class _SavingsOverTimeChart extends StatelessWidget {
  final List<Product> products;
  final settings;

  const _SavingsOverTimeChart({
    required this.products,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get avoided products sorted by date
    final avoidedProducts = products
        .where((p) => p.decision == PurchaseDecision.avoided)
        .toList()
      ..sort((a, b) => a.decisionDate!.compareTo(b.decisionDate!));

    if (avoidedProducts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sparing over tid',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Ingen sparing ennå',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate cumulative savings
    double cumulative = 0;
    final spots = avoidedProducts.asMap().entries.map((entry) {
      cumulative += entry.value.price;
      return FlSpot(entry.key.toDouble(), cumulative);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sparing over tid',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Totalt spart: ${cumulative.toStringAsFixed(0)} ${settings.currencySymbol}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: cumulative / 4,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDistributionChart extends StatelessWidget {
  final List<Product> products;
  final settings;

  const _CategoryDistributionChart({
    required this.products,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count products by category
    final categoryCount = <ProductCategory, int>{};
    for (var product in products) {
      categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
    }

    // Filter out categories with 0 products
    final activeCategories = categoryCount.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (activeCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = activeCategories.fold(0, (sum, entry) => sum + entry.value);

    // Create pie chart sections
    final sections = activeCategories.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: _getCategoryColor(entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategorier',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: activeCategories.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.key.emoji} ${entry.value}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.electronics:
        return Colors.blue;
      case ProductCategory.clothing:
        return Colors.purple;
      case ProductCategory.food:
        return Colors.orange;
      case ProductCategory.entertainment:
        return Colors.pink;
      case ProductCategory.home:
        return Colors.brown;
      case ProductCategory.health:
        return Colors.red;
      case ProductCategory.sports:
        return Colors.green;
      case ProductCategory.travel:
        return Colors.teal;
      case ProductCategory.books:
        return Colors.indigo;
      case ProductCategory.other:
        return Colors.grey;
    }
  }
}

class _DecisionTypeChart extends StatelessWidget {
  final List<Product> products;
  final settings;

  const _DecisionTypeChart({
    required this.products,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final avoided = products.where((p) => p.decision == PurchaseDecision.avoided).length;
    final planned = products.where((p) => p.decision == PurchaseDecision.plannedPurchase).length;
    final impulse = products.where((p) => p.decision == PurchaseDecision.impulseBuy).length;

    final sections = [
      if (avoided > 0)
        PieChartSectionData(
          value: avoided.toDouble(),
          title: '$avoided',
          color: Colors.green,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (planned > 0)
        PieChartSectionData(
          value: planned.toDouble(),
          title: '$planned',
          color: Colors.orange,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (impulse > 0)
        PieChartSectionData(
          value: impulse.toDouble(),
          title: '$impulse',
          color: Colors.red,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beslutninger',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    if (avoided > 0)
                      _LegendItem(
                        color: Colors.green,
                        label: 'Unngått',
                        value: avoided,
                      ),
                    if (planned > 0)
                      _LegendItem(
                        color: Colors.orange,
                        label: 'Planlagt',
                        value: planned,
                      ),
                    if (impulse > 0)
                      _LegendItem(
                        color: Colors.red,
                        label: 'Impulsiv',
                        value: impulse,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlySpendingChart extends StatelessWidget {
  final List<Product> products;
  final settings;

  const _MonthlySpendingChart({
    required this.products,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get last 6 months of spending (impulse buys only)
    final now = DateTime.now();
    final monthlySpending = <int, double>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthKey = month.year * 12 + month.month;

      final spending = products
          .where((p) =>
              p.decision == PurchaseDecision.impulseBuy &&
              p.decisionDate != null &&
              p.decisionDate!.year == month.year &&
              p.decisionDate!.month == month.month)
          .fold<double>(0, (sum, p) => sum + p.price);

      monthlySpending[monthKey] = spending;
    }

    if (monthlySpending.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Utgifter siste 6 måneder',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Ingen utgifter ennå',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final monthKeys = monthlySpending.keys.toList()..sort();
    final spots = monthKeys.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), monthlySpending[entry.value]!);
    }).toList();

    final maxY = monthlySpending.values.isEmpty
        ? 1000.0
        : monthlySpending.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utgifter siste 6 måneder',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= monthKeys.length || value.toInt() < 0) {
                            return const Text('');
                          }

                          final monthKey = monthKeys[value.toInt()];
                          final monthNumber = monthKey % 12;
                          final monthIndex = monthNumber == 0 ? 11 : monthNumber - 1;
                          final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 
                                             'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Des'];

                          // Sjekk at indeksen er gyldig
                          if (monthIndex < 0 || monthIndex >= monthNames.length) {
                            return const Text('');
                          }

                          return Text(
                            monthNames[monthIndex],
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: spots.map((spot) {
                    return BarChartGroupData(
                      x: spot.x.toInt(),
                      barRods: [
                        BarChartRodData(
                          toY: spot.y,
                          color: theme.colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
