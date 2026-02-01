import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/settings/data/app_settings.dart';
import 'package:pengespareapp/src/core/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Currency Section
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l10n.currency),
            subtitle: Text('${settings.currencySymbol} - ${settings.currency}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.currency),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: CurrencyData.currencies.map((currency) {
                      return RadioListTile<String>(
                        title: Text('${currency.symbol} - ${currency.name}'),
                        value: currency.code,
                        groupValue: settings.currency,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).updateCurrency(
                                currency.code,
                                currency.symbol,
                              );
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // Hourly Wage
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(l10n.hourlyWage),
            subtitle: Text('${settings.hourlyWage.toStringAsFixed(0)} ${settings.currencySymbol}'),
            onTap: () {
              final controller = TextEditingController(
                text: settings.hourlyWage.toStringAsFixed(0),
              );
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.hourlyWage),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.hourlyWage,
                      suffixText: settings.currencySymbol,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () {
                        final wage = double.tryParse(controller.text);
                        if (wage != null && wage > 0) {
                          ref.read(settingsProvider.notifier).updateHourlyWage(wage);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(settings.languageCode == 'nb' ? l10n.norwegian : l10n.english),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.language),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: Text(l10n.norwegian),
                        value: 'nb',
                        groupValue: settings.languageCode,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).updateLanguage('nb');
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(l10n.english),
                        value: 'en',
                        groupValue: settings.languageCode,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).updateLanguage('en');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // Monthly Budget
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Månedlig budsjett'),
            subtitle: Text(
              settings.monthlyBudget != null
                  ? '${settings.monthlyBudget!.toStringAsFixed(0)} ${settings.currencySymbol}'
                  : 'Ikke satt',
            ),
            onTap: () {
              final controller = TextEditingController(
                text: settings.monthlyBudget?.toStringAsFixed(0) ?? '',
              );
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Månedlig budsjett'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Budsjett',
                          suffixText: settings.currencySymbol,
                          helperText: 'Hvor mye kan du bruke per måned?',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Dette viser deg hvor mye du har brukt av budsjettet ditt.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await ref.read(settingsProvider.notifier).updateMonthlyBudget(null);
                        Navigator.pop(context);
                      },
                      child: const Text('Fjern budsjett'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final budget = double.tryParse(controller.text);
                        if (budget != null && budget > 0) {
                          await ref.read(settingsProvider.notifier).updateMonthlyBudget(budget);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          
          // Notifications Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Varsler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const Divider(),

          // Test Notification Button
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Test varsel'),
            subtitle: const Text('Send et test-varsel for å sjekke at alt fungerer'),
            trailing: FilledButton.icon(
              onPressed: () async {
                await NotificationService().showTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test varsel sendt! Sjekk varselfeltet 🔔'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Send test'),
            ),
          ),

          const SizedBox(height: 24),
          
          // Waiting Periods Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Ventetider',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const Divider(),

          // Testing Mode Toggle
          SwitchListTile(
            secondary: const Icon(Icons.science_outlined),
            title: const Text('Testing: Bruk minutter for små beløp'),
            subtitle: const Text('Aktiver for å teste varsler raskere'),
            value: settings.useMinutesForSmallAmount,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleUseMinutesForSmallAmount(value);
            },
          ),

          const Divider(),

          // Small Amount Wait
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text('Små beløp (< ${settings.smallAmountThreshold} ${settings.currencySymbol})'),
            subtitle: Text('Ventetid: ${settings.smallAmountWaitHours} ${settings.useMinutesForSmallAmount ? "minutter" : "timer"}'),
            onTap: () async {
              await _showWaitTimeDialog(
                context,
                ref,
                'Små beløp',
                settings.smallAmountWaitHours,
                settings.useMinutesForSmallAmount ? 'minutter' : 'timer',
                (hours) async => await ref.read(settingsProvider.notifier).updateSmallAmountWaitHours(hours),
              );
            },
          ),

          const Divider(),

          // Medium Amount Wait
          ListTile(
            leading: const Icon(Icons.timer),
            title: Text('Mellomstore beløp (${settings.smallAmountThreshold} - ${settings.mediumAmountThreshold} ${settings.currencySymbol})'),
            subtitle: Text('Ventetid: ${settings.mediumAmountWaitDays} dager'),
            onTap: () async {
              await _showWaitTimeDialog(
                context,
                ref,
                'Mellomstore beløp',
                settings.mediumAmountWaitDays,
                'dager',
                (days) async => await ref.read(settingsProvider.notifier).updateMediumAmountWaitDays(days),
              );
            },
          ),

          const Divider(),

          // Large Amount Wait
          ListTile(
            leading: const Icon(Icons.timer_10),
            title: Text('Store beløp (> ${settings.mediumAmountThreshold} ${settings.currencySymbol})'),
            subtitle: Text('Ventetid: ${settings.largeAmountWaitDays} dager'),
            onTap: () async {
              await _showWaitTimeDialog(
                context,
                ref,
                'Store beløp',
                settings.largeAmountWaitDays,
                'dager',
                (days) async => await ref.read(settingsProvider.notifier).updateLargeAmountWaitDays(days),
              );
            },
          ),

          const Divider(),

          // Small Amount Threshold
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: const Text('Grense for små beløp'),
            subtitle: Text('${settings.smallAmountThreshold} ${settings.currencySymbol}'),
            onTap: () async {
              await _showThresholdDialog(
                context,
                ref,
                'Grense for små beløp',
                settings.smallAmountThreshold,
                settings.currencySymbol,
                (value) async => await ref.read(settingsProvider.notifier).updateSmallAmountThreshold(value),
              );
            },
          ),

          const Divider(),

          // Medium Amount Threshold
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Grense for mellomstore beløp'),
            subtitle: Text('${settings.mediumAmountThreshold} ${settings.currencySymbol}'),
            onTap: () async {
              await _showThresholdDialog(
                context,
                ref,
                'Grense for mellomstore beløp',
                settings.mediumAmountThreshold,
                settings.currencySymbol,
                (value) async => await ref.read(settingsProvider.notifier).updateMediumAmountThreshold(value),
              );
            },
          ),

          const SizedBox(height: 40),

          // Privacy & App Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Om appen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const Divider(),

          // Privacy & Data
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Personvern & Data'),
            subtitle: const Text('Hvordan vi håndterer dine data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('🔒 Personvern & Datasikkerhet'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInfoSection(
                          '📱 100% Offline',
                          'SpareMester lagrer all data lokalt på din telefon. Ingen informasjon sendes til eksterne servere.',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          '🚫 Ingen datainnsamling',
                          'Vi samler ikke inn personopplysninger, brukerdata, eller analysedata. Din informasjon forblir privat.',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          '🔔 Lokale varsler',
                          'Varsler håndteres av telefonen din og krever ingen internettforbindelse.',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          '🌐 Internettbruk',
                          'Internett brukes kun når du henter produktbilder fra nettbutikker. Ingen data sendes fra appen.',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          '💾 Datalagring',
                          'All data (produkter, prestasjoner, statistikk) lagres i appens lokale database på telefonen din.',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          '🔋 Strømbruk',
                          'Minimal batteripåvirkning - appen kjører kun når du bruker den aktivt.',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Lukk'),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // GitHub Source Code
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Åpen kildekode'),
            subtitle: const Text('Se koden på GitHub'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final url = Uri.parse('https://github.com/thohov/SpareMester');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),

          const Divider(),

          // App Version
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Om SpareMester'),
            subtitle: const Text('Versjon 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SpareMester',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.shopping_bag, size: 48),
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'SpareMester hjelper deg med å ta bedre kjøpsbeslutninger ved å gi deg tid til å tenke deg om.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Laget med ❤️ for å unngå unødvendige kjøp',
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // Footer
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'laget for å ikke bruke penger på unødvendig dritt <3',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Future<void> _showWaitTimeDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    int currentValue,
    String unit,
    Future<void> Function(int) onUpdate,
  ) async {
    final controller = TextEditingController(text: currentValue.toString());
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Ventetid',
            suffixText: unit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                await onUpdate(value);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showThresholdDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    int currentValue,
    String currencySymbol,
    Future<void> Function(int) onUpdate,
  ) async {
    final controller = TextEditingController(text: currentValue.toString());
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Beløp',
            suffixText: currencySymbol,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                await onUpdate(value);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
