import 'package:arcane_scanner/data/collection_repository.dart';
import 'package:arcane_scanner/domain/models/collection_entry.dart';
import 'package:arcane_scanner/domain/models/condition.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:arcane_scanner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('tela de scan cumpre as diretrizes de acessibilidade',
      (tester) async {
    final handle = tester.ensureSemantics();
    final db = await pumpArcaneApp(tester);
    addTearDown(db.close);

    // Alvos de toque >= 48dp, contraste de texto AA e rótulos de botão.
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('tela de coleção (com dados) cumpre as diretrizes',
      (tester) async {
    final handle = tester.ensureSemantics();
    final db = await pumpArcaneApp(tester);
    addTearDown(db.close);

    await CollectionRepository(db).add(CollectionEntry(
      scryfallId: 'x',
      name: 'Lightning Bolt',
      setCode: 'neo',
      setName: 'Kamigawa: Neon Dynasty',
      collectorNumber: '123',
      rarity: 'rare',
      quantity: 3,
      foil: true,
      condition: Condition.nm,
      language: Language.en,
      priceUsdAtAdd: '1.50',
      addedAt: DateTime.utc(2026, 1, 1),
    ));

    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    await tester.tap(find.text(l10n.navCollection));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}
