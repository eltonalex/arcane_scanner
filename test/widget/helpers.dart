import 'package:arcane_scanner/app.dart';
import 'package:arcane_scanner/data/db/app_database.dart';
import 'package:arcane_scanner/features/collection/collection_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sobe o app inteiro com:
/// - banco drift EM MEMÓRIA (sem tocar o disco do host)
/// - SharedPreferences mockado
/// - google_fonts sem rede (usa a fonte padrão do ambiente de teste)
///
/// Retorna o banco para o teste popular/inspecionar. Feche-o no fim.
Future<AppDatabase> pumpArcaneApp(WidgetTester tester,
    {AppDatabase? database}) async {
  SharedPreferences.setMockInitialValues({});
  GoogleFonts.config.allowRuntimeFetching = false;

  final db = database ?? AppDatabase(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const ArcaneScannerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}
