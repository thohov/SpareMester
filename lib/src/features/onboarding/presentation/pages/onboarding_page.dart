import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pengespareapp/src/core/database/database_service.dart';
import 'package:pengespareapp/src/features/settings/data/app_settings.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  // Selected currency (default NOK)
  CurrencyData _selectedCurrency = CurrencyData.currencies[0];

  // Hourly wage
  final _wageController = TextEditingController(text: '200');

  @override
  void dispose() {
    _wageController.dispose();
    super.dispose();
  }

  void _onDone() async {
    final hourlyWage = double.tryParse(_wageController.text) ?? 200.0;

    final settings = DatabaseService.getSettings();
    settings.currency = _selectedCurrency.code;
    settings.currencySymbol = _selectedCurrency.symbol;
    settings.hourlyWage = hourlyWage;
    settings.hasCompletedOnboarding = true;

    await DatabaseService.updateSettings(settings);

    if (mounted) {
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          key: _introKey,
          pages: [
            // Page 1: Introduction
            PageViewModel(
              title: l10n.onboardingTitle1,
              body: l10n.onboardingDesc1,
              image: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 2: Currency Selection
            PageViewModel(
              title: l10n.onboardingTitle2,
              bodyWidget: Column(
                children: [
                  Text(
                    l10n.onboardingDesc2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<CurrencyData>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: CurrencyData.currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(
                            '${currency.symbol} - ${currency.name}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCurrency = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              image: Center(
                child: Icon(
                  Icons.attach_money,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 3: Hourly Wage
            PageViewModel(
              title: l10n.onboardingTitle3,
              bodyWidget: Column(
                children: [
                  Text(
                    l10n.onboardingDesc3,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _wageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: l10n.hourlyWage,
                        hintText: l10n.enterHourlyWage,
                        suffixText: _selectedCurrency.symbol,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              image: Center(
                child: Icon(
                  Icons.access_time,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 4: Timer System
            PageViewModel(
              title: '⏳ Ventetider & Tenkepause',
              body:
                  'Legg til produkter du ønsker, og appen setter en tenketid basert på pris. Du får varsel når tiden er ute!',
              image: Center(
                child: Icon(
                  Icons.timer,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 5: Categories
            PageViewModel(
              title: '📂 Kategorier',
              body:
                  'Organiser ønskene dine i kategorier som Elektronikk, Klær, Hobby og mer. Se statistikk over hva du bruker mest på!',
              image: Center(
                child: Icon(
                  Icons.category,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 6: Pre-purchase Questions
            PageViewModel(
              title: '✋ Refleksjonsspørsmål',
              body:
                  'Før du kjøper, må du svare på to viktige spørsmål: Trenger jeg virkelig dette? Har jeg noe tilsvarende fra før?',
              image: Center(
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 7: Extended Cooldown
            PageViewModel(
              title: '🤔 Forleng tenketiden',
              body:
                  'Usikker? Du kan alltid forlenge tenketiden med 1-30 dager ekstra før du bestemmer deg!',
              image: Center(
                child: Icon(
                  Icons.snooze,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 8: Achievements
            PageViewModel(
              title: '🏆 Prestasjoner',
              body:
                  'Lås opp over 30 prestasjoner ved å spare penger og ta gode beslutninger. Fiksjon med konfetti når du oppnår noe!',
              image: Center(
                child: Icon(
                  Icons.emoji_events,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 9: Statistics
            PageViewModel(
              title: '📊 Statistikk',
              body:
                  'Se detaljert oversikt over spare-beslutninger, kategorier, månedlig forbruk og sparemål!',
              image: Center(
                child: Icon(
                  Icons.bar_chart,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),

            // Page 10: Budget
            PageViewModel(
              title: '💰 Månedlig budsjett',
              body:
                  'Sett et budsjett og få varsler når du nærmer deg grensen. Hold kontroll på forbruket ditt!',
              image: Center(
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 150,
                  color: theme.colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
          ],
          onDone: _onDone,
          showSkipButton: false,
          skip: Text(l10n.skip),
          next: Text(l10n.next),
          done: Text(l10n.done,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          bodyPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          controlsPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          controlsMargin: const EdgeInsets.all(0),
          dotsContainerDecorator: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          dotsDecorator: DotsDecorator(
            size: const Size.square(4.0),
            activeSize: const Size(8.0, 4.0),
            activeColor: theme.colorScheme.primary,
            color: theme.colorScheme.outline,
            spacing: const EdgeInsets.symmetric(horizontal: 1.5),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
      ),
      imagePadding: const EdgeInsets.only(top: 40, bottom: 8),
      pageColor: Theme.of(context).colorScheme.background,
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
      bodyAlignment: Alignment.center,
      imageAlignment: Alignment.topCenter,
      footerPadding: const EdgeInsets.only(bottom: 140),
      titlePadding: const EdgeInsets.only(top: 8, bottom: 8),
    );
  }
}
