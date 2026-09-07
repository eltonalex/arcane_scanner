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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Arcane Scanner'**
  String get appTitle;

  /// No description provided for @navScan.
  ///
  /// In pt, this message translates to:
  /// **'Escanear'**
  String get navScan;

  /// No description provided for @navCollection.
  ///
  /// In pt, this message translates to:
  /// **'Coleção'**
  String get navCollection;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @scanHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Invoque sua carta'**
  String get scanHeadline;

  /// No description provided for @scanSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Fotografe ou envie a imagem de uma carta de Magic para identificá-la'**
  String get scanSubtitle;

  /// No description provided for @scanCameraButton.
  ///
  /// In pt, this message translates to:
  /// **'Abrir câmera'**
  String get scanCameraButton;

  /// No description provided for @scanGalleryButton.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get scanGalleryButton;

  /// No description provided for @collectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua coleção'**
  String get collectionTitle;

  /// No description provided for @collectionEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma carta registrada ainda. Escaneie sua primeira carta!'**
  String get collectionEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsAiSection.
  ///
  /// In pt, this message translates to:
  /// **'Provedor de IA (fallback)'**
  String get settingsAiSection;

  /// No description provided for @comingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Disponível na iteração {iteration}'**
  String comingSoon(int iteration);

  /// No description provided for @exportCsv.
  ///
  /// In pt, this message translates to:
  /// **'Exportar CSV'**
  String get exportCsv;

  /// No description provided for @exportEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nada para exportar ainda — adicione cartas à coleção primeiro.'**
  String get exportEmpty;

  /// No description provided for @exportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'CSV gerado! Escolha onde salvar ou compartilhar.'**
  String get exportSuccess;

  /// No description provided for @totalsUnique.
  ///
  /// In pt, this message translates to:
  /// **'Impressões únicas'**
  String get totalsUnique;

  /// No description provided for @totalsQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Cartas no total'**
  String get totalsQuantity;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome...'**
  String get searchHint;

  /// No description provided for @filterSet.
  ///
  /// In pt, this message translates to:
  /// **'Edição'**
  String get filterSet;

  /// No description provided for @filterRarity.
  ///
  /// In pt, this message translates to:
  /// **'Raridade'**
  String get filterRarity;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @clearAll.
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get clearAll;

  /// No description provided for @clearAllConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpar a coleção?'**
  String get clearAllConfirmTitle;

  /// No description provided for @clearAllConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Todas as cartas serão removidas. Esta ação não pode ser desfeita.'**
  String get clearAllConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @removeEntry.
  ///
  /// In pt, this message translates to:
  /// **'Remover carta'**
  String get removeEntry;

  /// No description provided for @increaseQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar quantidade'**
  String get increaseQuantity;

  /// No description provided for @decreaseQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Diminuir quantidade'**
  String get decreaseQuantity;

  /// No description provided for @collectionLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a coleção.'**
  String get collectionLoadError;

  /// No description provided for @newScan.
  ///
  /// In pt, this message translates to:
  /// **'Novo scan'**
  String get newScan;

  /// No description provided for @identifyButton.
  ///
  /// In pt, this message translates to:
  /// **'Identificar'**
  String get identifyButton;

  /// No description provided for @identifying.
  ///
  /// In pt, this message translates to:
  /// **'Identificando a carta...'**
  String get identifying;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @quickMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo rápido'**
  String get quickMode;

  /// No description provided for @quickModeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ao identificar, adiciona 1 unidade automaticamente (NM, EN, sem foil)'**
  String get quickModeSubtitle;

  /// No description provided for @quickModeAdded.
  ///
  /// In pt, this message translates to:
  /// **'Adicionada à coleção pelo modo rápido (1x, NM, EN).'**
  String get quickModeAdded;

  /// No description provided for @addToCollection.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar à coleção'**
  String get addToCollection;

  /// No description provided for @addedToCollection.
  ///
  /// In pt, this message translates to:
  /// **'{name} adicionada à coleção!'**
  String addedToCollection(String name);

  /// No description provided for @quantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantity;

  /// No description provided for @foil.
  ///
  /// In pt, this message translates to:
  /// **'Foil'**
  String get foil;

  /// No description provided for @conditionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Condição'**
  String get conditionLabel;

  /// No description provided for @languageLabel.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageLabel;

  /// No description provided for @openInScryfall.
  ///
  /// In pt, this message translates to:
  /// **'Ver no Scryfall'**
  String get openInScryfall;

  /// No description provided for @identifiedByOcr.
  ///
  /// In pt, this message translates to:
  /// **'Identificada por OCR local (grátis, offline)'**
  String get identifiedByOcr;

  /// No description provided for @identifiedByAi.
  ///
  /// In pt, this message translates to:
  /// **'Identificada pela IA (fallback)'**
  String get identifiedByAi;

  /// No description provided for @aiSectionHint.
  ///
  /// In pt, this message translates to:
  /// **'Usada só quando o OCR local não resolve. A chave fica no armazenamento seguro do aparelho e nunca sai dele (exceto para o próprio provedor).'**
  String get aiSectionHint;

  /// No description provided for @aiProviderLabel.
  ///
  /// In pt, this message translates to:
  /// **'Provedor'**
  String get aiProviderLabel;

  /// No description provided for @apiKeyLabel.
  ///
  /// In pt, this message translates to:
  /// **'Chave da API'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In pt, this message translates to:
  /// **'Cole a chave aqui'**
  String get apiKeyHint;

  /// No description provided for @saveKey.
  ///
  /// In pt, this message translates to:
  /// **'Salvar chave'**
  String get saveKey;

  /// No description provided for @keySaved.
  ///
  /// In pt, this message translates to:
  /// **'Chave salva com segurança.'**
  String get keySaved;

  /// No description provided for @keyRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Chave removida.'**
  String get keyRemoved;

  /// No description provided for @keyConfigured.
  ///
  /// In pt, this message translates to:
  /// **'Chave configurada'**
  String get keyConfigured;

  /// No description provided for @keyNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma chave configurada'**
  String get keyNotConfigured;

  /// No description provided for @removeKey.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get removeKey;

  /// No description provided for @importSection.
  ///
  /// In pt, this message translates to:
  /// **'Importar coleção'**
  String get importSection;

  /// No description provided for @importHint.
  ///
  /// In pt, this message translates to:
  /// **'Traga sua coleção do app web (JSON) ou de um CSV exportado por este app. Cartas repetidas são mescladas somando a quantidade.'**
  String get importHint;

  /// No description provided for @importJson.
  ///
  /// In pt, this message translates to:
  /// **'Importar JSON'**
  String get importJson;

  /// No description provided for @importCsv.
  ///
  /// In pt, this message translates to:
  /// **'Importar CSV'**
  String get importCsv;

  /// No description provided for @importing.
  ///
  /// In pt, this message translates to:
  /// **'Importando...'**
  String get importing;

  /// No description provided for @importProgress.
  ///
  /// In pt, this message translates to:
  /// **'Importando {done} de {total}...'**
  String importProgress(int done, int total);

  /// No description provided for @importDone.
  ///
  /// In pt, this message translates to:
  /// **'Importação concluída: {imported} cartas importadas, {failed} falharam.'**
  String importDone(int imported, int failed);

  /// No description provided for @cameraAlignHint.
  ///
  /// In pt, this message translates to:
  /// **'Encaixe a carta na moldura, com o rodapé na faixa destacada'**
  String get cameraAlignHint;

  /// No description provided for @cameraTorch.
  ///
  /// In pt, this message translates to:
  /// **'Lanterna'**
  String get cameraTorch;

  /// No description provided for @cameraCapture.
  ///
  /// In pt, this message translates to:
  /// **'Capturar'**
  String get cameraCapture;

  /// No description provided for @cameraProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Processando imagem...'**
  String get cameraProcessing;

  /// No description provided for @cameraError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a câmera.'**
  String get cameraError;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permita o acesso à câmera nas configurações do aparelho para escanear cartas.'**
  String get cameraPermissionDenied;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
