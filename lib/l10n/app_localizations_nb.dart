// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'SpareMester';

  @override
  String get onboardingTitle1 => 'Stopp Impulskjøp';

  @override
  String get onboardingDesc1 =>
      'Legg til varer du vil kjøpe og vent før du kjøper. La tiden avgjøre om du virkelig trenger det.';

  @override
  String get onboardingTitle2 => 'Velg Valuta';

  @override
  String get onboardingDesc2 => 'Velg valutaen du bruker for kjøp.';

  @override
  String get onboardingTitle3 => 'Tid er Penger';

  @override
  String get onboardingDesc3 =>
      'Skriv inn timelønn. Vi viser deg hvor mange arbeidstimer hver vare koster.';

  @override
  String get next => 'Neste';

  @override
  String get done => 'Ferdig';

  @override
  String get skip => 'Hopp over';

  @override
  String get currency => 'Valuta';

  @override
  String get hourlyWage => 'Timelønn';

  @override
  String get enterHourlyWage => 'Skriv inn timelønn';

  @override
  String get dashboard => 'Oversikt';

  @override
  String get products => 'Produkter';

  @override
  String get settings => 'Innstillinger';

  @override
  String get moneySaved => 'Penger Spart';

  @override
  String get hoursSaved => 'Timer Spart';

  @override
  String get impulseControlScore => 'Impulskontrollen';

  @override
  String get addProduct => 'Legg til Produkt';

  @override
  String get productName => 'Produktnavn';

  @override
  String get price => 'Pris';

  @override
  String get url => 'URL';

  @override
  String get desireScore => 'Ønskepoeng';

  @override
  String workHours(String hours) {
    return '$hours arbeidstimer';
  }

  @override
  String get iAmWeak => 'Jeg er Svak';

  @override
  String get stillWantThis => 'Vil du fortsatt ha dette?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nei';

  @override
  String get impulseBuy => 'Impulskjøp';

  @override
  String get plannedPurchase => 'Planlagt Kjøp';

  @override
  String get language => 'Språk';

  @override
  String get english => 'Engelsk';

  @override
  String get norwegian => 'Norsk';

  @override
  String get enterProductName => 'Skriv inn produktnavn';

  @override
  String get enterPrice => 'Skriv inn pris';

  @override
  String get optionalUrl => 'https://... (valgfritt)';

  @override
  String get howMuchDoYouWantThis => 'Hvor mye vil du ha dette?';

  @override
  String get notMuch => 'Ikke så mye';

  @override
  String get veryMuch => 'Veldig mye';

  @override
  String get thisWillCost => 'Dette koster deg';

  @override
  String hoursOfWork(String hours) {
    return '$hours arbeidstimer';
  }

  @override
  String waitingPeriod(String period) {
    return 'Ventetid: $period';
  }

  @override
  String hours(int count) {
    return '$count timer';
  }

  @override
  String days(int count) {
    return '$count dager';
  }

  @override
  String get save => 'Lagre';

  @override
  String get cancel => 'Avbryt';

  @override
  String get pleaseEnterName => 'Vennligst skriv inn produktnavn';

  @override
  String get pleaseEnterPrice => 'Vennligst skriv inn pris';

  @override
  String get pleaseEnterValidPrice => 'Vennligst skriv inn gyldig pris';

  @override
  String productAdded(String period) {
    return 'Produkt lagt til! Vent $period før du bestemmer deg.';
  }

  @override
  String get active => 'Aktive';

  @override
  String get archive => 'Arkiv';

  @override
  String get noProductsYet => 'Ingen produkter ennå';

  @override
  String get tapPlusToAdd => 'Trykk + for å legge til din første vare';

  @override
  String get timeRemaining => 'Tid gjenstår';

  @override
  String get timerFinished => 'Timer ferdig!';

  @override
  String get delete => 'Slett';

  @override
  String get noArchivedProducts => 'Ingen arkiverte produkter';

  @override
  String get archivedProductsAppearHere =>
      'Produkter du har tatt beslutninger om vil vises her';

  @override
  String get decisionMade => 'Beslutning tatt';

  @override
  String get unknown => 'Ukjent';
}
