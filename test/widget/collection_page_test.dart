import 'package:arcane_scanner/data/collection_repository.dart';
import 'package:arcane_scanner/domain/models/collection_entry.dart';
import 'package:arcane_scanner/domain/models/condition.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:arcane_scanner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

CollectionEntry _entry({
  String scryfallId = 'bolt-1',
  String name = 'Lightning Bolt',
  int quantity = 2,
  String? usd = '1.50',
}) =>
    CollectionEntry(
      scryfallId: scryfallId,
      name: name,
      setCode: 'neo',
      setName: 'Kamigawa: Neon Dynasty',
      collectorNumber: '123',
      rarity: 'rare',
      quantity: quantity,
      foil: false,
      condition: Condition.nm,
      language: Language.en,
      priceUsdAtAdd: usd,
      addedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  testWidgets('coleção mostra carta do banco e atualiza ao mudar quantidade',
      (tester) async {
    final db = await pumpArcaneApp(tester);
    addTearDown(db.close);

    final repo = CollectionRepository(db);
    await repo.add(_entry(quantity: 2));

    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    await tester.tap(find.text(l10n.navCollection));
    await tester.pumpAndSettle();

    // A carta aparece.
    expect(find.text('Lightning Bolt'), findsOneWidget);
    // Total de cartas = 2 (quantidade), impressões únicas = 1.
    expect(find.text('2'), findsWidgets);

    // Incrementa a quantidade pelo stepper (+).
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();

    // O banco agora tem quantity = 3 (a stream reconstrói a UI).
    final entries = await repo.watch(const CollectionFilter()).first;
    expect(entries.single.quantity, 3);
  });

  testWidgets('busca filtra a lista', (tester) async {
    final db = await pumpArcaneApp(tester);
    addTearDown(db.close);

    final repo = CollectionRepository(db);
    await repo.add(_entry(scryfallId: 'a', name: 'Lightning Bolt'));
    await repo.add(_entry(scryfallId: 'b', name: 'Counterspell'));

    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    await tester.tap(find.text(l10n.navCollection));
    await tester.pumpAndSettle();

    expect(find.text('Lightning Bolt'), findsOneWidget);
    expect(find.text('Counterspell'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'counter');
    // Aguarda o debounce (350ms) + rebuild.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Lightning Bolt'), findsNothing);
    expect(find.text('Counterspell'), findsOneWidget);
  });

  testWidgets('limpar tudo pede confirmação e esvazia a coleção',
      (tester) async {
    final db = await pumpArcaneApp(tester);
    addTearDown(db.close);

    final repo = CollectionRepository(db);
    await repo.add(_entry());

    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    await tester.tap(find.text(l10n.navCollection));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();

    // Dialog de confirmação aberto.
    expect(find.text(l10n.clearAllConfirmTitle), findsOneWidget);

    await tester.tap(find.text(l10n.clearAll));
    await tester.pumpAndSettle();

    expect(find.text('Lightning Bolt'), findsNothing);
    expect(await repo.watch(const CollectionFilter()).first, isEmpty);
  });
}
