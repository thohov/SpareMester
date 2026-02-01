// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SpareMester';

  @override
  String get onboardingTitle1 => 'Stop Impulse Buying';

  @override
  String get onboardingDesc1 =>
      'Add items you want to buy and wait before purchasing. Let time decide if you really need it.';

  @override
  String get onboardingTitle2 => 'Choose Your Currency';

  @override
  String get onboardingDesc2 =>
      'Select the currency you use for your purchases.';

  @override
  String get onboardingTitle3 => 'Time is Money';

  @override
  String get onboardingDesc3 =>
      'Enter your hourly wage. We\'ll show you how many work hours each item costs.';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get currency => 'Currency';

  @override
  String get hourlyWage => 'Hourly Wage';

  @override
  String get enterHourlyWage => 'Enter your hourly wage';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get products => 'Products';

  @override
  String get settings => 'Settings';

  @override
  String get moneySaved => 'Money Saved';

  @override
  String get hoursSaved => 'Hours Saved';

  @override
  String get impulseControlScore => 'Impulse Control Score';

  @override
  String get addProduct => 'Add Product';

  @override
  String get productName => 'Product Name';

  @override
  String get price => 'Price';

  @override
  String get url => 'URL';

  @override
  String get desireScore => 'Desire Score';

  @override
  String workHours(String hours) {
    return '$hours work hours';
  }

  @override
  String get iAmWeak => 'I Am Weak';

  @override
  String get stillWantThis => 'Do you still want this?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get impulseBuy => 'Impulse Buy';

  @override
  String get plannedPurchase => 'Planned Purchase';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get norwegian => 'Norwegian';

  @override
  String get enterProductName => 'Enter product name';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get optionalUrl => 'https://... (optional)';

  @override
  String get howMuchDoYouWantThis => 'How much do you want this?';

  @override
  String get notMuch => 'Not much';

  @override
  String get veryMuch => 'Very much';

  @override
  String get thisWillCost => 'This will cost you';

  @override
  String hoursOfWork(String hours) {
    return '$hours hours of work';
  }

  @override
  String waitingPeriod(String period) {
    return 'Waiting period: $period';
  }

  @override
  String hours(int count) {
    return '$count hours';
  }

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get pleaseEnterName => 'Please enter a product name';

  @override
  String get pleaseEnterPrice => 'Please enter a price';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String productAdded(String period) {
    return 'Product added! Wait $period before deciding.';
  }

  @override
  String get active => 'Active';

  @override
  String get archive => 'Archive';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get tapPlusToAdd => 'Tap + to add your first item';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get timerFinished => 'Timer finished!';

  @override
  String get delete => 'Delete';

  @override
  String get noArchivedProducts => 'No archived products';

  @override
  String get archivedProductsAppearHere =>
      'Products you\'ve made decisions about will appear here';

  @override
  String get decisionMade => 'Decision made';

  @override
  String get unknown => 'Unknown';
}
