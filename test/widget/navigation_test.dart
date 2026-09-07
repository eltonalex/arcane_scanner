import 'package:arcane_scanner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('abre na aba Escanear e navega pelas três abas',
      (tester) async {
    final db = await pumpArcaneApp(tester);
    addTearDown(db.close);

    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));

    // Começa na tela de scan (headline visível).
    expect(find.text(l10n.scanHeadline), findsOneWidget);

    // Vai para a Coleção -> estado vazio.
    await tester.tap(find.text(l10n.navCollection));
    await tester.pumpAndSettle();
    expect(find.text(l10n.collectionEmpty), findsOneWidget);

    // Vai para os Ajustes -> seção de IA.
    await tester.tap(find.text(l10n.navSettings));
    await tester.pumpAndSettle();
    expect(find.text(l10n.settingsAiSection), findsOneWidget);

    // Volta para Escanear.
    await tester.tap(find.text(l10n.navScan));
    await tester.pumpAndSettle();
    expect(find.text(l10n.scanHeadline), findsOneWidget);
  });
}
