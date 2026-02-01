import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/products_provider.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/achievements/presentation/pages/achievements_page.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:pengespareapp/src/features/settings/data/app_settings.dart';
import 'package:pengespareapp/src/features/statistics/presentation/pages/statistics_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stats = ref.watch(statsProvider);
    final settings = ref.watch(settingsProvider);
    
    final moneySaved = stats['moneySaved'] as double;
    final hoursSaved = stats['hoursSaved'] as double;
    final impulseControlScore = stats['impulseControlScore'] as int;
    final avoided = stats['avoided'] as int;
    final impulseBuys = stats['impulseBuys'] as int;
    final plannedPurchases = stats['plannedPurchases'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Message
            Text(
              'Velkommen tilbake! 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),            const SizedBox(height: 16),

            // Budget Card (if budget is set)
            if (settings.monthlyBudget != null) _BudgetCard(
              settings: settings,
              products: ref.watch(allProductsProvider),
            ),
            if (settings.monthlyBudget != null) const SizedBox(height: 16),
            
            // Streak Card
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 48,
                      color: settings.currentStreak > 0 
                        ? Colors.orange 
                        : theme.colorScheme.onTertiaryContainer.withOpacity(0.5),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.currentStreak > 0 
                              ? '🔥 ${settings.currentStreak} dager på rad!'
                              : 'Start din streak!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.currentStreak > 0
                              ? 'Fortsett å ta gode beslutninger! 💪'
                              : 'Ta en beslutning for å starte',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          if (settings.longestStreak > settings.currentStreak)
                            Text(
                              'Beste: ${settings.longestStreak} dager',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),            const SizedBox(height: 16),

            // Achievements Card
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AchievementsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prestasjoner',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Se dine opplåste prestasjoner',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
                        const SizedBox(height: 16),

            // Statistics Card
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StatisticsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistikk',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Grafer og innsikt i dine beslutninger',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
                        const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: l10n.moneySaved,
                    value: '${moneySaved.toStringAsFixed(0)} ${settings.currencySymbol}',
                    icon: Icons.savings,
                    color: theme.colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l10n.hoursSaved,
                    value: hoursSaved.toStringAsFixed(1),
                    icon: Icons.access_time,
                    color: theme.colorScheme.secondaryContainer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Impulse Control Score
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      l10n.impulseControlScore,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: impulseControlScore / 100,
                            strokeWidth: 12,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$impulseControlScore%',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              _getScoreEmoji(impulseControlScore),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MiniStat(
                          label: 'Unngått',
                          value: avoided.toString(),
                          color: Colors.green,
                        ),
                        _MiniStat(
                          label: 'Planlagt',
                          value: plannedPurchases.toString(),
                          color: Colors.blue,
                        ),
                        _MiniStat(
                          label: 'Impuls',
                          value: impulseBuys.toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            if (avoided + impulseBuys + plannedPurchases == 0) ...[
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Legg til ditt første produkt for å begynne å spare!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getScoreEmoji(int score) {
    if (score >= 90) return '🏆';
    if (score >= 75) return '🎯';
    if (score >= 60) return '💪';
    if (score >= 40) return '👍';
    return '💭';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final AppSettings settings;
  final List<Product> products;

  const _BudgetCard({
    required this.settings,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = settings.monthlyBudget ?? 0;
    
    // Calculate current month's spending (impulse buys only)
    final now = DateTime.now();
    final thisMonthSpending = products
        .where((p) =>
            p.decision == PurchaseDecision.impulseBuy &&
            p.decisionDate != null &&
            p.decisionDate!.year == now.year &&
            p.decisionDate!.month == now.month)
        .fold<double>(0, (sum, p) => sum + p.price);

    final percentage = budget > 0 ? (thisMonthSpending / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = budget - thisMonthSpending;
    
    // Color based on percentage
    Color progressColor;
    if (percentage >= 0.9) {
      progressColor = Colors.red;
    } else if (percentage >= 0.7) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Månedlig budsjett',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${thisMonthSpending.toStringAsFixed(0)} ${settings.currencySymbol}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  'av ${budget.toStringAsFixed(0)} ${settings.currencySymbol}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerLowest,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            if (remaining < 0)
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Budsjett overskredet med ${(-remaining).toStringAsFixed(0)} ${settings.currencySymbol}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            else if (percentage >= 0.9)
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Du nærmer deg budsjettet ditt!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else if (remaining > 0)
              Text(
                '${remaining.toStringAsFixed(0)} ${settings.currencySymbol} igjen denne måneden',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
