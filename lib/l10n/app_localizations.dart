import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'SpareMester'**
  String get appTitle;

  /// First onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Stop Impulse Buying'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Add items you want to buy and wait before purchasing. Let time decide if you really need it.'**
  String get onboardingDesc1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Currency'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Select the currency you use for your purchases.'**
  String get onboardingDesc2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Time is Money'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Enter your hourly wage. We\'ll show you how many work hours each item costs.'**
  String get onboardingDesc3;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Currency label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Hourly wage input label
  ///
  /// In en, this message translates to:
  /// **'Hourly Wage'**
  String get hourlyWage;

  /// Hourly wage input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your hourly wage'**
  String get enterHourlyWage;

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Products tab label
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Money saved stat label
  ///
  /// In en, this message translates to:
  /// **'Money Saved'**
  String get moneySaved;

  /// Hours saved stat label
  ///
  /// In en, this message translates to:
  /// **'Hours Saved'**
  String get hoursSaved;

  /// Impulse control score label
  ///
  /// In en, this message translates to:
  /// **'Impulse Control Score'**
  String get impulseControlScore;

  /// Add product button
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Product name field label
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// URL field label
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// Desire score slider label
  ///
  /// In en, this message translates to:
  /// **'Desire Score'**
  String get desireScore;

  /// Work hours calculation
  ///
  /// In en, this message translates to:
  /// **'{hours} work hours'**
  String workHours(String hours);

  /// Impulse buy button during countdown
  ///
  /// In en, this message translates to:
  /// **'I Am Weak'**
  String get iAmWeak;

  /// Question after timer finishes
  ///
  /// In en, this message translates to:
  /// **'Do you still want this?'**
  String get stillWantThis;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Impulse buy label
  ///
  /// In en, this message translates to:
  /// **'Impulse Buy'**
  String get impulseBuy;

  /// Planned purchase label
  ///
  /// In en, this message translates to:
  /// **'Planned Purchase'**
  String get plannedPurchase;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Norwegian language option
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get norwegian;

  /// Product name hint
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// Price hint
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// URL hint
  ///
  /// In en, this message translates to:
  /// **'https://... (optional)'**
  String get optionalUrl;

  /// Desire score label
  ///
  /// In en, this message translates to:
  /// **'How much do you want this?'**
  String get howMuchDoYouWantThis;

  /// Low desire label
  ///
  /// In en, this message translates to:
  /// **'Not much'**
  String get notMuch;

  /// High desire label
  ///
  /// In en, this message translates to:
  /// **'Very much'**
  String get veryMuch;

  /// Work hours cost label
  ///
  /// In en, this message translates to:
  /// **'This will cost you'**
  String get thisWillCost;

  /// Hours of work display
  ///
  /// In en, this message translates to:
  /// **'{hours} hours of work'**
  String hoursOfWork(String hours);

  /// Waiting period display
  ///
  /// In en, this message translates to:
  /// **'Waiting period: {period}'**
  String waitingPeriod(String period);

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hours(int count);

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(int count);

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get pleaseEnterName;

  /// Price validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get pleaseEnterPrice;

  /// Invalid price error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// Success message after adding product
  ///
  /// In en, this message translates to:
  /// **'Product added! Wait {period} before deciding.'**
  String productAdded(String period);

  /// Active products tab
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Archive page title
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// Empty state hint
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first item'**
  String get tapPlusToAdd;

  /// Countdown label
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// Timer complete label
  ///
  /// In en, this message translates to:
  /// **'Timer finished!'**
  String get timerFinished;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Empty archive state
  ///
  /// In en, this message translates to:
  /// **'No archived products'**
  String get noArchivedProducts;

  /// Archive empty state description
  ///
  /// In en, this message translates to:
  /// **'Products you\'ve made decisions about will appear here'**
  String get archivedProductsAppearHere;

  /// Decision made label
  ///
  /// In en, this message translates to:
  /// **'Decision made'**
  String get decisionMade;

  /// Unknown value
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
