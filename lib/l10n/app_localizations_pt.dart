// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Arcane Scanner';

  @override
  String get navScan => 'Escanear';

  @override
  String get navCollection => 'Coleção';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get scanHeadline => 'Invoque sua carta';

  @override
  String get scanSubtitle =>
      'Fotografe ou envie a imagem de uma carta de Magic para identificá-la';

  @override
  String get scanCameraButton => 'Abrir câmera';

  @override
  String get scanGalleryButton => 'Escolher da galeria';

  @override
  String get collectionTitle => 'Sua coleção';

  @override
  String get collectionEmpty =>
      'Nenhuma carta registrada ainda. Escaneie sua primeira carta!';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAiSection => 'Provedor de IA (fallback)';

  @override
  String comingSoon(int iteration) {
    return 'Disponível na iteração $iteration';
  }

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get exportEmpty =>
      'Nada para exportar ainda — adicione cartas à coleção primeiro.';

  @override
  String get exportSuccess =>
      'CSV gerado! Escolha onde salvar ou compartilhar.';

  @override
  String get totalsUnique => 'Impressões únicas';

  @override
  String get totalsQuantity => 'Cartas no total';

  @override
  String get searchHint => 'Buscar por nome...';

  @override
  String get filterSet => 'Edição';

  @override
  String get filterRarity => 'Raridade';

  @override
  String get filterAll => 'Todas';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get clearAllConfirmTitle => 'Limpar a coleção?';

  @override
  String get clearAllConfirmBody =>
      'Todas as cartas serão removidas. Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get removeEntry => 'Remover carta';

  @override
  String get increaseQuantity => 'Aumentar quantidade';

  @override
  String get decreaseQuantity => 'Diminuir quantidade';

  @override
  String get collectionLoadError => 'Não foi possível carregar a coleção.';

  @override
  String get newScan => 'Novo scan';

  @override
  String get identifyButton => 'Identificar';

  @override
  String get identifying => 'Identificando a carta...';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get quickMode => 'Modo rápido';

  @override
  String get quickModeSubtitle =>
      'Ao identificar, adiciona 1 unidade automaticamente (NM, EN, sem foil)';

  @override
  String get quickModeAdded =>
      'Adicionada à coleção pelo modo rápido (1x, NM, EN).';

  @override
  String get addToCollection => 'Adicionar à coleção';

  @override
  String addedToCollection(String name) {
    return '$name adicionada à coleção!';
  }

  @override
  String get quantity => 'Quantidade';

  @override
  String get foil => 'Foil';

  @override
  String get conditionLabel => 'Condição';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get openInScryfall => 'Ver no Scryfall';

  @override
  String get identifiedByOcr => 'Identificada por OCR local (grátis, offline)';

  @override
  String get identifiedByAi => 'Identificada pela IA (fallback)';

  @override
  String get aiSectionHint =>
      'Usada só quando o OCR local não resolve. A chave fica no armazenamento seguro do aparelho e nunca sai dele (exceto para o próprio provedor).';

  @override
  String get aiProviderLabel => 'Provedor';

  @override
  String get apiKeyLabel => 'Chave da API';

  @override
  String get apiKeyHint => 'Cole a chave aqui';

  @override
  String get saveKey => 'Salvar chave';

  @override
  String get keySaved => 'Chave salva com segurança.';

  @override
  String get keyRemoved => 'Chave removida.';

  @override
  String get keyConfigured => 'Chave configurada';

  @override
  String get keyNotConfigured => 'Nenhuma chave configurada';

  @override
  String get removeKey => 'Remover';

  @override
  String get importSection => 'Importar coleção';

  @override
  String get importHint =>
      'Traga sua coleção do app web (JSON) ou de um CSV exportado por este app. Cartas repetidas são mescladas somando a quantidade.';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get importing => 'Importando...';

  @override
  String importProgress(int done, int total) {
    return 'Importando $done de $total...';
  }

  @override
  String importDone(int imported, int failed) {
    return 'Importação concluída: $imported cartas importadas, $failed falharam.';
  }

  @override
  String get cameraAlignHint =>
      'Encaixe a carta na moldura, com o rodapé na faixa destacada';

  @override
  String get cameraTorch => 'Lanterna';

  @override
  String get cameraCapture => 'Capturar';

  @override
  String get cameraProcessing => 'Processando imagem...';

  @override
  String get cameraError => 'Não foi possível abrir a câmera.';

  @override
  String get cameraPermissionDenied =>
      'Permita o acesso à câmera nas configurações do aparelho para escanear cartas.';

  @override
  String get back => 'Voltar';
}
