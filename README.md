# Arcane Scanner

Scanner de cartas de *Magic: The Gathering* em Flutter. Fotografe uma
carta, identifique a **impressão exata** (edição + número) por OCR local
com fallback de IA multimodal, enriqueça os dados via API do Scryfall e
gerencie sua coleção com export/import em CSV.

Migração completa do app web original (TanStack Start + React 19).

---

## Recursos

- **Identificação híbrida**: OCR on-device (ML Kit, grátis e offline)
  como primeira via; IA multimodal (OpenAI / Gemini / Anthropic) apenas
  como fallback quando o OCR não resolve.
- **Enriquecimento Scryfall**: busca exata por `edição/número` e fallback
  fuzzy por nome.
- **Coleção offline-first** (drift/SQLite): totais, filtros por nome
  (com debounce), edição e raridade, quantidade editável, remoção.
- **Regra de merge**: mesma impressão + foil + condição + idioma soma a
  quantidade em vez de duplicar.
- **Modo rápido**: 1 toque adiciona 1 unidade com padrões (NM, EN).
- **Export CSV** compatível com Moxfield/Deckbox.
- **Import** da coleção do app web (JSON) ou de CSV (com enriquecimento).
- **Tema arcano** Material 3 escuro; i18n PT-BR (padrão) e EN.

---

## Pré-requisitos

- Flutter stable (testado em 3.35.7 / Dart 3.9)
- Android Studio (traz o JBR/Java 21) + Android SDK com
  *Command-line Tools*
- Um dispositivo Android físico com **Depuração USB** (a câmera e o OCR
  não funcionam em emulador com a mesma fidelidade)

Confirme o ambiente:

```bash
flutter doctor -v
```

Verde em *Flutter*, *Android toolchain* e *Android Studio* basta. Avisos
de *Visual Studio* (desktop Windows) e *Chrome* (web) são irrelevantes
para o alvo Android.

---

## Setup

```bash
# 1. Gere a base nativa do projeto (android/, ios/, ...)
flutter create --org br.com.seudominio arcane_scanner
cd arcane_scanner

# 2. Copie por cima: pubspec.yaml, l10n.yaml, lib/, test/, docs/

# 3. Dependências
flutter pub get

# 4. Geração de código (drift + localizações)
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# 5. Rode no dispositivo
flutter devices
flutter run
```

> Sempre que você editar `lib/data/db/app_database.dart` (colunas,
> tabelas), rode de novo o `build_runner`.

---

## Configuração de IA (opcional)

O app funciona 100% só com OCR. Para ativar o fallback de IA, vá em
**Ajustes**, escolha o provedor e cole a chave:

| Provedor | Modelo | Onde obter a chave |
|---|---|---|
| OpenAI | gpt-4o-mini | https://platform.openai.com/api-keys |
| Google Gemini | gemini-2.5-flash | https://aistudio.google.com/apikey (free tier) |
| Anthropic | claude-sonnet-4-5 | https://console.anthropic.com/settings/keys |

A chave fica no `flutter_secure_storage` (Android Keystore) e nunca é
relida pela interface nem gravada em logs. Trocar de provedor não exige
rebuild.

---

## Importar do app web

Veja o passo a passo em [`docs/MIGRACAO_WEB.md`](docs/MIGRACAO_WEB.md):
exporte o JSON do localStorage no navegador, transfira para o celular e
importe em **Ajustes → Importar JSON**.

---

## Testes

```bash
flutter test
```

Cobre a lógica de negócio e as telas principais:

- `csv_exporter_test.dart` — geração do CSV (cabeçalhos, escape, foil, ISO)
- `collection_repository_test.dart` — merge, filtros, quantidade, totais
- `identification_parsers_test.dart` — parser de OCR e parser da resposta da IA
- `collection_importer_test.dart` — parsers de JSON e CSV de importação
- `widget/` — navegação, coleção reativa, busca, limpar tudo, acessibilidade

> **Windows**: se os testes de banco falharem por falta de `sqlite3.dll`,
> baixe o *Precompiled Binaries for Windows* em
> https://www.sqlite.org/download.html e coloque a DLL na raiz do
> projeto. No app real a lib nativa vem embutida via `drift_flutter`.

---

## Build de release (Android)

### APK (instalação direta / testes)

```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```

Para reduzir o tamanho, gere um APK por arquitetura:

```bash
flutter build apk --release --split-per-abi
```

### App Bundle (publicação na Play Store)

```bash
flutter build appbundle --release
# saída: build/app/outputs/bundle/release/app-release.aab
```

### Assinatura

Um build de release **sem assinatura configurada** usa a chave de debug
e não pode ir à Play Store. Para assinar:

1. Gere um keystore:
   ```bash
   keytool -genkey -v -keystore ~/arcane-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Crie `android/key.properties` (NÃO comitar):
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=C:/Users/voce/arcane-upload.jks
   ```
3. Em `android/app/build.gradle`, carregue o `key.properties` e aponte o
   `signingConfigs.release` para ele (ver docs do Flutter:
   https://docs.flutter.dev/deployment/android#signing-the-app).

O ML Kit adiciona ~4 MB por causa do modelo de OCR embutido — normal.

---

## Estrutura

```
lib/
  main.dart · app.dart              # bootstrap, tema, i18n, rotas
  core/       theme · router · result
  domain/models/                    # modelos puros (entry, card, enums)
  data/
    db/app_database.dart            # drift (tabela + índice único de merge)
    collection_repository.dart      # merge, filtros, streams, totais
    scryfall_api.dart               # cliente Scryfall
    csv_exporter.dart               # export Moxfield/Deckbox
    collection_importer.dart        # import JSON/CSV
    ocr/                            # leitor ML Kit + parser puro
    ai/                             # interface + 3 provedores + config
    card_identification_service.dart# o pipeline híbrido
  features/
    scan/ · collection/ · settings/ # UI + controllers (Riverpod)
  l10n/                             # ARB PT-BR + EN
test/                               # unit + widget
docs/MIGRACAO_WEB.md
```

---

## Arquitetura (resumo)

- **Estado**: Riverpod (`Notifier`/`AsyncNotifier`), sem singletons globais.
- **Erros**: `Result<T>` selado com `AppFailure` — mensagens amigáveis em
  PT-BR, nunca stack trace na UI.
- **Reatividade**: as telas observam streams do drift; escrever no banco
  atualiza a UI sem `setState` manual.
- **Camadas**: `domain` (puro) ← `data` (banco/rede) ← `features` (UI).
  Os parsers (OCR, IA, CSV, JSON) são funções puras, testadas sem device.
- **Preparado para nuvem**: um `RemoteCollectionRepository` futuro
  (Supabase/Firebase) entra atrás da mesma interface, sem tocar na UI.

---

## Fora do escopo (MVP)

Sincronização multi-dispositivo, reconhecimento de várias cartas na mesma
foto e crop automático de bordas — a arquitetura já deixa espaço para
adicionar depois.
```
