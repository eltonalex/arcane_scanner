# Migrando a coleção do app web (React) para o Flutter

O app web guarda a coleção no localStorage do navegador. O caminho é:
exportar esse JSON -> transferir para o celular -> importar em
Configurações -> Importar JSON.

## 1. Exportar do navegador

Abra o app web, pressione F12 (DevTools) -> aba Console e rode:

```js
// Ajuste 'arcane-collection' para a chave usada pelo seu app web.
// Para descobrir a chave: Object.keys(localStorage)
copy(localStorage.getItem('arcane-collection'))
```

O conteúdo vai para a área de transferência. Cole em um arquivo
`colecao.json` (VS Code, Bloco de Notas...).

> Se o valor no localStorage estiver embrulhado (ex.: `{"state": {...}}`
> por causa do Zustand/persist), extraia apenas a LISTA de cartas antes
> de salvar. O importador aceita tanto uma lista `[...]` quanto um
> objeto `{"entries": [...]}`.

## 2. Formato esperado

Lista de objetos com os campos do modelo (mesmos nomes do app web):

```json
[
  {
    "scryfallId": "obrigatório",
    "name": "obrigatório",
    "setCode": "neo",
    "setName": "Kamigawa: Neon Dynasty",
    "collectorNumber": "123",
    "rarity": "rare",
    "imageUrl": "https://...",
    "scryfallUri": "https://...",
    "quantity": 2,
    "foil": false,
    "condition": "NM",
    "language": "EN",
    "priceUsdAtAdd": "1.23",
    "priceEurAtAdd": "1.10",
    "addedAt": "2025-06-01T12:00:00Z"
  }
]
```

Opcionais ausentes ganham defaults (quantity=1, NM, EN, addedAt=agora).
Entradas sem `scryfallId` são descartadas.

## 3. Transferir e importar

Mande o arquivo para o celular (Drive, WhatsApp, cabo USB...) e no app:
**Configurações -> Importar JSON**. Cartas que já existirem na coleção
são mescladas (mesma regra do app: soma a quantidade).

## Alternativa: CSV

Se você só tiver o CSV (formato Moxfield exportado por este app), use
**Importar CSV**. Como o CSV não carrega o scryfallId nem as imagens,
cada linha é buscada no Scryfall por (Edition, Collector Number) —
com ~500 cartas isso leva 1–2 minutos e exige internet. Linhas que o
Scryfall não encontrar aparecem no relatório ao final.
