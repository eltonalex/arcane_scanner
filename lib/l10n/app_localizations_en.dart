// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arcane Scanner';

  @override
  String get navScan => 'Scan';

  @override
  String get navCollection => 'Collection';

  @override
  String get navSettings => 'Settings';

  @override
  String get scanHeadline => 'Summon your card';

  @override
  String get scanSubtitle => 'Take a photo or upload an image of a Magic card to identify it';

  @override
  String get scanCameraButton => 'Open camera';

  @override
  String get scanGalleryButton => 'Pick from gallery';

  @override
  String get collectionTitle => 'Your collection';

  @override
  String get collectionEmpty => 'No cards registered yet. Scan your first card!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAiSection => 'AI provider (fallback)';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportEmpty => 'Nothing to export yet — add cards to your collection first.';

  @override
  String get exportSuccess => 'CSV generated! Choose where to save or share it.';

  @override
  String get totalsUnique => 'Unique printings';

  @override
  String get totalsQuantity => 'Total cards';

  @override
  String get searchHint => 'Search by name...';

  @override
  String get filterSet => 'Set';

  @override
  String get filterRarity => 'Rarity';

  @override
  String get filterAll => 'All';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearAllConfirmTitle => 'Clear your collection?';

  @override
  String get clearAllConfirmBody => 'All cards will be removed. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get removeEntry => 'Remove card';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get collectionLoadError => 'Could not load your collection.';

  @override
  String get newScan => 'New scan';

  @override
  String get identifyButton => 'Identify';

  @override
  String get identifying => 'Identifying the card...';

  @override
  String get tryAgain => 'Try again';

  @override
  String get quickMode => 'Quick mode';

  @override
  String get quickModeSubtitle => 'On identify, automatically adds 1 copy (NM, EN, non-foil)';

  @override
  String get quickModeAdded => 'Added to your collection by quick mode (1x, NM, EN).';

  @override
  String get addToCollection => 'Add to collection';

  @override
  String addedToCollection(String name) {
    return '$name added to your collection!';
  }

  @override
  String get quantity => 'Quantity';

  @override
  String get foil => 'Foil';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get languageLabel => 'Language';

  @override
  String get openInScryfall => 'View on Scryfall';

  @override
  String get identifiedByOcr => 'Identified by on-device OCR (free, offline)';

  @override
  String get identifiedByAi => 'Identified by AI (fallback)';

  @override
  String get aiSectionHint => 'Only used when on-device OCR can\'t identify the card. Your key is kept in the device\'s secure storage and never leaves it (except to the provider itself).';

  @override
  String get aiProviderLabel => 'Provider';

  @override
  String get apiKeyLabel => 'API key';

  @override
  String get apiKeyHint => 'Paste your key here';

  @override
  String get saveKey => 'Save key';

  @override
  String get keySaved => 'Key saved securely.';

  @override
  String get keyRemoved => 'Key removed.';

  @override
  String get keyConfigured => 'Key configured';

  @override
  String get keyNotConfigured => 'No key configured';

  @override
  String get removeKey => 'Remove';

  @override
  String get importSection => 'Import collection';

  @override
  String get importHint => 'Bring your collection from the web app (JSON) or from a CSV exported by this app. Duplicate cards are merged by adding quantities.';

  @override
  String get importJson => 'Import JSON';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importing => 'Importing...';

  @override
  String importProgress(int done, int total) {
    return 'Importing $done of $total...';
  }

  @override
  String importDone(int imported, int failed) {
    return 'Import finished: $imported cards imported, $failed failed.';
  }

  @override
  String get cameraAlignHint => 'Fit the card inside the frame, with the footer on the highlighted strip';

  @override
  String get cameraTorch => 'Torch';

  @override
  String get cameraCapture => 'Capture';

  @override
  String get cameraProcessing => 'Processing image...';

  @override
  String get cameraError => 'Couldn\'t open the camera.';

  @override
  String get cameraPermissionDenied => 'Allow camera access in your device settings to scan cards.';

  @override
  String get back => 'Back';

  @override
  String get autoMode => 'Auto';

  @override
  String get autoWaiting => 'Bring the next card in';

  @override
  String get autoHold => 'Hold steady...';

  @override
  String get autoSwap => 'Swap the card';

  @override
  String get skipCard => 'Skip this card';

  @override
  String queuedCard(String name) {
    return '$name queued';
  }

  @override
  String reviewChip(int count) {
    return 'Review ($count)';
  }

  @override
  String reviewTitle(int count) {
    return 'Review ($count)';
  }

  @override
  String get reviewEmpty => 'No cards in the queue. Capture some in auto mode.';

  @override
  String reviewConfirmAll(int count) {
    return 'Add $count to collection';
  }

  @override
  String reviewAdded(int count) {
    return '$count cards added to your collection.';
  }

  @override
  String get reviewDiscard => 'Discard';

  @override
  String get reviewDiscardTitle => 'Discard the queue?';

  @override
  String get reviewDiscardBody => 'Captured cards not yet confirmed will be lost.';

  @override
  String pendingQueueBanner(int count) {
    return '$count cards awaiting review';
  }

  @override
  String get reviewAction => 'Review';
}
