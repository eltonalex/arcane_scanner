# Arcane Scanner — Iteração 1 (esqueleto + tema + roteamento)

Migração do app React (TanStack Start) para Flutter. Esta iteração entrega o
projeto compilável com tema arcano (Material 3 escuro), navegação por abas
(`go_router` + `StatefulShellRoute`) e i18n PT-BR/EN.

## Decisões já tomadas

| Tema | Decisão |
|---|---|
| Persistência | **drift** (SQLite tipado) — Isar 3.x está sem manutenção ativa |
| Identificação | **Híbrida**: OCR local (ML Kit) primeiro → IA multimodal como fallback |
| Teste inicial | Android em device físico |

## Setup

```bash
# 1. Crie o projeto base (gera android/, ios/, etc.)
flutter create --org br.com.seudominio arcane_scanner
cd arcane_scanner

# 2. Substitua pubspec.yaml, adicione l10n.yaml e substitua a pasta lib/
#    pelos arquivos deste pacote.

# 3. Dependências + geração das classes de localização
flutter pub get
flutter gen-l10n   # (o build normal também gera, por causa de generate: true)

# 4. Rodar no device físico (depuração USB ativada)
flutter devices
flutter run
```

> **Flutter < 3.27?** Descomente `synthetic-package: false` no `l10n.yaml`
> para que `app_localizations.dart` seja gerado dentro de `lib/l10n/`.
> Nas versões atuais esse já é o comportamento padrão.

## Estrutura desta iteração

```
lib/
  main.dart                  # ProviderScope + runApp
  app.dart                   # MaterialApp.router + tema + i18n (PT-BR padrão)
  core/
    theme.dart               # Paleta arcana + Material 3 (Cinzel nos títulos)
    router.dart              # go_router com shell de 3 abas
    result.dart              # sealed class Result<T> + AppFailure
  features/
    scan/scan_page.dart      # layout pronto; ações chegam na it. 3
    collection/collection_page.dart  # estado vazio; drift chega na it. 2
    settings/settings_page.dart      # provedores de IA chegam na it. 4
  l10n/
    app_pt.arb               # template (idioma padrão)
    app_en.arb               # fallback
```

## O que verificar no device

- [ ] App abre na aba **Escanear** com o tema roxo/dourado e título em Cinzel
- [ ] As 3 abas navegam sem transição e preservam estado (indexed stack)
- [ ] Botões da tela de scan mostram o aviso "Disponível na iteração 3"
- [ ] Trocar o idioma do celular para inglês muda os textos (PT-BR é o padrão)

## Próxima iteração (2)

- Schema drift do `CollectionEntry` (mesmos campos do modelo do prompt,
  com índice único em `scryfallId + foil + condition + language` para a
  regra de merge via UPSERT)
- `CollectionRepository` com streams reativas (drift `watch`)
- Tela de coleção real: totais, filtros (nome com debounce, edição,
  raridade), quantidade editável e remoção

## Adendo — Exportação CSV (antecipada)

O gerador de CSV foi antecipado da iteração 4 e já está funcional:

- `lib/data/csv_exporter.dart` — `buildCsv()` (puro, testado) +
  `exportAndShare()` (path_provider + share_plus, diálogo nativo)
- Cabeçalhos exatos Moxfield/Deckbox; Edition em UPPERCASE; Foil = "foil"/"";
  Added At em ISO 8601 (UTC); escape RFC 4180 via pacote `csv`
- Botão de exportar no AppBar da tela Coleção. Enquanto o banco não existe
  (iteração 2), a coleção está vazia e o botão avisa "Nada para exportar" —
  ao trocar o `collectionEntriesProvider` pelo stream do drift, o export
  passa a funcionar sem nenhuma mudança adicional
- Testes: `flutter test test/csv_exporter_test.dart`

---

# Iteração 2 — Persistência drift + tela de coleção

## Novos arquivos

```
lib/data/db/app_database.dart        # Tabela drift + mapeadores domínio<->row
lib/data/collection_repository.dart  # Merge (upsert), filtros, totais, streams
lib/features/collection/
  collection_controller.dart         # Providers Riverpod (db, repo, filtros)
  collection_page.dart               # Totais + filtros + lista reativa
  widgets/collection_totals_header.dart
  widgets/collection_entry_tile.dart
test/collection_repository_test.dart
```

## Passos obrigatórios após copiar os arquivos

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # gera app_database.g.dart
flutter run
```

O build_runner precisa rodar sempre que `app_database.dart` mudar
(novas colunas, tabelas). O arquivo gerado `*.g.dart` pode ir no
.gitignore ou no git — tanto faz, mas seja consistente.

## Como funciona a regra de merge

A tabela tem `uniqueKeys` em (scryfallId, foil, condition, language).
`CollectionRepository.add()` usa `INSERT ... ON CONFLICT DO UPDATE`
somando a quantidade — atômico no SQLite, sem risco de condição de
corrida entre ler e escrever.

## Testes

```powershell
flutter test
```

> **Windows**: se `collection_repository_test.dart` falhar com erro de
> sqlite3 ausente, baixe o "Precompiled Binaries for Windows (sqlite-dll)"
> em sqlite.org/download.html e coloque o `sqlite3.dll` na raiz do
> projeto (ou em uma pasta do PATH). Os testes usam banco em memória
> e precisam da dll no host; no app real a lib nativa vem embutida
> pelo drift_flutter.

## Notas

- `DropdownButtonFormField` usa `initialValue:` (Flutter 3.35+). Se o
  analyzer reclamar após um downgrade do Flutter, troque por `value:`.
- Os totais do cabeçalho consideram a coleção INTEIRA (sem filtros),
  como no app React.
- A lista usa `ListView.builder` — tranquilo para >500 cartas. Se a
  coleção passar de alguns milhares, o próximo passo seria paginação
  com `limit/offset` no drift.

## Próxima iteração (3)

Scryfall API (dio) + pipeline híbrido de identificação
(OCR ML Kit → fallback IA) + tela de scan funcional com modo rápido.

---

# Iteração 3 — Scryfall + pipeline híbrido (OCR → IA) + tela de scan

## Novos arquivos

```
lib/domain/models/scryfall_card.dart       # Parse (inclui cartas dupla-face)
lib/domain/models/card_identification.dart # Pistas + fonte (ocr/ai)
lib/data/scryfall_api.dart                 # dio + headers exigidos + erros PT-BR
lib/data/ocr/ocr_text_parser.dart          # Heurísticas PURAS (testáveis)
lib/data/ocr/ocr_card_reader.dart          # ML Kit (Android/iOS)
lib/data/ai/ai_identifier.dart             # Interface + prompt + parser JSON
lib/data/ai/openai_identifier.dart         # gpt-4o-mini
lib/data/ai/gemini_identifier.dart         # gemini-2.5-flash
lib/data/ai/anthropic_identifier.dart      # claude-sonnet-4-5
lib/data/ai/ai_config.dart                 # provedor (prefs) + chave (secure)
lib/data/card_identification_service.dart  # O pipeline em si
lib/features/scan/scan_controller.dart     # Estados + modo rápido + add
lib/features/scan/scan_page.dart           # UI completa do fluxo
lib/features/scan/widgets/card_result_panel.dart
test/identification_parsers_test.dart
```

## Fluxo do pipeline

```
foto -> OCR ML Kit -> pistas? -> Scryfall /cards/{set}/{num}
                                   └─ 404? -> /cards/named?fuzzy={name}
        └─ falhou/fraco -> IA (se chave configurada) -> Scryfall (mesma ordem)
```

- OCR é grátis, offline e resolve a maioria das cartas modernas
  (o rodapé "123/302 / NEO • EN" identifica a IMPRESSÃO exata).
- A IA só é chamada quando o OCR não resolve — economiza custo.
- Sem chave configurada, o app funciona 100% com OCR e explica como
  ativar o fallback.

## Passos no Windows

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run    # no device físico!
```

## Configuração Android/iOS

- **Android**: nada a fazer. `image_picker` usa intent (sem permissão
  CAMERA no manifest) e o modelo latino do ML Kit vem embutido (~4 MB
  no APK). minSdk 21+ (padrão do Flutter atual já atende).
- **iOS** (quando chegar lá): adicionar em `ios/Runner/Info.plist`:
  `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription`.

## Chave de IA (opcional nesta iteração)

A tela de Configurações chega na iteração 4. Até lá, o fallback fica
inativo (pipeline só-OCR). Para testar a IA antes, dá para gravar a
chave uma vez via código temporário:

```dart
// main.dart, antes do runApp (REMOVER depois de rodar 1x):
// await AiConfigRepository().setApiKey(AiProvider.gemini, 'SUA_CHAVE');
```

Gemini tem free tier em https://aistudio.google.com (API key gratuita).

## Observações

- A imagem vai para a IA comprimida a <=1600px/85% (menos tokens).
- O OCR usa o arquivo original do picker (mais resolução = melhor leitura).
- Idioma detectado no rodapé pré-preenche o dropdown do formulário.
- No navegador (flutter run -d chrome) o OCR não existe; o scan só
  funciona com IA configurada. No Android, tudo funciona.

## Próxima iteração (4)

Tela de Configurações (provedor + chave com secure storage, importador
JSON do app web) e polimento do export.

---

# Iteração 4 — Configurações + importador JSON/CSV

## Novos arquivos

```
lib/data/collection_importer.dart          # Parsers puros + importador
lib/features/settings/settings_controller.dart
lib/features/settings/settings_page.dart   # Provedor de IA, chave, import
test/collection_importer_test.dart
docs/MIGRACAO_WEB.md                       # Passo a passo da migração
```

## O que a tela de Configurações faz

- **Provedor de IA**: dropdown OpenAI/Gemini/Anthropic (persistido em
  SharedPreferences — trocar não exige rebuild, requisito do prompt).
- **Chave da API**: campo com olho mágico, salva no
  flutter_secure_storage (Keystore). A UI mostra apenas SE existe
  chave, nunca a chave. Botão Remover apaga do storage.
- **Importar JSON**: coleção do app web (ver docs/MIGRACAO_WEB.md).
- **Importar CSV**: re-importa um export deste app; cada linha é
  enriquecida no Scryfall por (Edition, Collector Number) com barra de
  progresso e relatório de falhas.

## Passos no Windows

```powershell
flutter pub get
flutter test
flutter run
```

(Sem mudança de schema — não precisa de build_runner desta vez.)

## Fluxo de teste sugerido

1. Configurações -> escolha Gemini -> cole a chave do AI Studio -> Salvar.
2. Scan de uma carta antiga (sem rodapé moderno) -> deve cair no
   fallback de IA e mostrar "Identificada pela IA".
3. Exporte o CSV da coleção, limpe tudo, importe o mesmo CSV ->
   a coleção volta (agora enriquecida pelo Scryfall).

## Próxima iteração (5)

Testes de widget, acessibilidade (Semantics), README final de
distribuição (build apk --release) e polish geral.

---

# Iteração 5 — Testes de widget, acessibilidade e distribuição

## Novos arquivos

```
test/widget/helpers.dart              # sobe o app com db em memória + prefs mock
test/widget/navigation_test.dart      # navegação entre as 3 abas
test/widget/collection_page_test.dart # coleção reativa, busca, stepper, limpar
test/widget/accessibility_test.dart   # diretrizes: tap target, contraste, rótulos
README.md                             # README definitivo (setup + release)
docs/HISTORICO_ITERACOES.md           # este arquivo (histórico das entregas)
```

## Acessibilidade

- Alvos de toque dos steppers e do botão remover garantidos em >=48dp
  via `BoxConstraints` (antes usavam densidade compacta).
- Totais da coleção agrupados em um único nó semântico ("Impressões
  únicas: 12") em vez de número e rótulo lidos soltos.
- Thumbnail da carta marcado como `Semantics(image: true, label: nome)`.
- Testes automatizados com `meetsGuideline(...)` cobrindo tap target
  (Android/iOS), contraste de texto e rótulos de botão.

## Rodar

```bash
flutter test              # unit + widget
flutter test test/widget  # só os de widget
```

## Distribuição

Instruções completas de build de release e assinatura no README.md
principal (seção "Build de release").

## Pendências de polimento para avaliar no device

- Estados de carregamento da imagem do Scryfall em conexões lentas.
- Feedback tátil (HapticFeedback) ao adicionar carta no modo rápido.
- Tela de captura em tempo real com `camera` (hoje usa image_picker) —
  era opcional no MVP.
