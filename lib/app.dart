import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';

class ArcaneScannerApp extends ConsumerWidget {
  const ArcaneScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildArcaneTheme(),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('pt'),
        Locale('en'),
      ],
      // PT-BR como padrão; EN como fallback para qualquer outro idioma.
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale == null) return const Locale('pt', 'BR');
        for (final locale in supported) {
          if (locale.languageCode == deviceLocale.languageCode) return locale;
        }
        return const Locale('en');
      },
    );
  }
}
