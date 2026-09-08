import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Arcane Scanner'**
  String get appTitle;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get navCollection;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @scanHeadline.
  ///
  /// In en, this message translates to:
  /// **'Summon your card'**
  String get scanHeadline;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or upload an image of a Magic card to identify it'**
  String get scanSubtitle;

  /// No description provided for @scanCameraButton.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get scanCameraButton;

  /// No description provided for @scanGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get scanGalleryButton;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your collection'**
  String get collectionTitle;

  /// No description provided for @collectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards registered yet. Scan your first card!'**
  String get collectionEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAiSection.
  ///
  /// In en, this message translates to:
  /// **'AI provider (fallback)'**
  String get settingsAiSection;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export yet — add cards to your collection first.'**
  String get exportEmpty;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'CSV generated! Choose where to save or share it.'**
  String get exportSuccess;

  /// No description provided for @totalsUnique.
  ///
  /// In en, this message translates to:
  /// **'Unique printings'**
  String get totalsUnique;

  /// No description provided for @totalsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total cards'**
  String get totalsQuantity;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchHint;

  /// No description provided for @filterSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get filterSet;

  /// No description provided for @filterRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get filterRarity;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear your collection?'**
  String get clearAllConfirmTitle;

  /// No description provided for @clearAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All cards will be removed. This action cannot be undone.'**
  String get clearAllConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @removeEntry.
  ///
  /// In en, this message translates to:
  /// **'Remove card'**
  String get removeEntry;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @collectionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your collection.'**
  String get collectionLoadError;

  /// No description provided for @newScan.
  ///
  /// In en, this message translates to:
  /// **'New scan'**
  String get newScan;

  /// No description provided for @identifyButton.
  ///
  /// In en, this message translates to:
  /// **'Identify'**
  String get identifyButton;

  /// No description provided for @identifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying the card...'**
  String get identifying;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @quickMode.
  ///
  /// In en, this message translates to:
  /// **'Quick mode'**
  String get quickMode;

  /// No description provided for @quickModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On identify, automatically adds 1 copy (NM, EN, non-foil)'**
  String get quickModeSubtitle;

  /// No description provided for @quickModeAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your collection by quick mode (1x, NM, EN).'**
  String get quickModeAdded;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get addToCollection;

  /// No description provided for @addedToCollection.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your collection!'**
  String addedToCollection(String name);

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @foil.
  ///
  /// In en, this message translates to:
  /// **'Foil'**
  String get foil;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @openInScryfall.
  ///
  /// In en, this message translates to:
  /// **'View on Scryfall'**
  String get openInScryfall;

  /// No description provided for @identifiedByOcr.
  ///
  /// In en, this message translates to:
  /// **'Identified by on-device OCR (free, offline)'**
  String get identifiedByOcr;

  /// No description provided for @identifiedByAi.
  ///
  /// In en, this message translates to:
  /// **'Identified by AI (fallback)'**
  String get identifiedByAi;

  /// No description provided for @aiSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Only used when on-device OCR can\'t identify the card. Your key is kept in the device\'s secure storage and never leaves it (except to the provider itself).'**
  String get aiSectionHint;

  /// No description provided for @aiProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get aiProviderLabel;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your key here'**
  String get apiKeyHint;

  /// No description provided for @saveKey.
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get saveKey;

  /// No description provided for @keySaved.
  ///
  /// In en, this message translates to:
  /// **'Key saved securely.'**
  String get keySaved;

  /// No description provided for @keyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Key removed.'**
  String get keyRemoved;

  /// No description provided for @keyConfigured.
  ///
  /// In en, this message translates to:
  /// **'Key configured'**
  String get keyConfigured;

  /// No description provided for @keyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'No key configured'**
  String get keyNotConfigured;

  /// No description provided for @removeKey.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeKey;

  /// No description provided for @importSection.
  ///
  /// In en, this message translates to:
  /// **'Import collection'**
  String get importSection;

  /// No description provided for @importHint.
  ///
  /// In en, this message translates to:
  /// **'Bring your collection from the web app (JSON) or from a CSV exported by this app. Duplicate cards are merged by adding quantities.'**
  String get importHint;

  /// No description provided for @importJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get importJson;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @importProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing {done} of {total}...'**
  String importProgress(int done, int total);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Import finished: {imported} cards imported, {failed} failed.'**
  String importDone(int imported, int failed);

  /// No description provided for @cameraAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Fit the card inside the frame, with the footer on the highlighted strip'**
  String get cameraAlignHint;

  /// No description provided for @cameraTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get cameraTorch;

  /// No description provided for @cameraCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get cameraCapture;

  /// No description provided for @cameraProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get cameraProcessing;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the camera.'**
  String get cameraError;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in your device settings to scan cards.'**
  String get cameraPermissionDenied;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @autoMode.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoMode;

  /// No description provided for @autoWaiting.
  ///
  /// In en, this message translates to:
  /// **'Bring the next card in'**
  String get autoWaiting;

  /// No description provided for @autoHold.
  ///
  /// In en, this message translates to:
  /// **'Hold steady...'**
  String get autoHold;

  /// No description provided for @autoSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap the card'**
  String get autoSwap;

  /// No description provided for @skipCard.
  ///
  /// In en, this message translates to:
  /// **'Skip this card'**
  String get skipCard;

  /// No description provided for @queuedCard.
  ///
  /// In en, this message translates to:
  /// **'{name} queued'**
  String queuedCard(String name);

  /// No description provided for @reviewChip.
  ///
  /// In en, this message translates to:
  /// **'Review ({count})'**
  String reviewChip(int count);

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review ({count})'**
  String reviewTitle(int count);

  /// No description provided for @reviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards in the queue. Capture some in auto mode.'**
  String get reviewEmpty;

  /// No description provided for @reviewConfirmAll.
  ///
  /// In en, this message translates to:
  /// **'Add {count} to collection'**
  String reviewConfirmAll(int count);

  /// No description provided for @reviewAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} cards added to your collection.'**
  String reviewAdded(int count);

  /// No description provided for @reviewDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get reviewDiscard;

  /// No description provided for @reviewDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard the queue?'**
  String get reviewDiscardTitle;

  /// No description provided for @reviewDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Captured cards not yet confirmed will be lost.'**
  String get reviewDiscardBody;

  /// No description provided for @pendingQueueBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} cards awaiting review'**
  String pendingQueueBanner(int count);

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAction;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
