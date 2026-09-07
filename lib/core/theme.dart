import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta arcana: roxos profundos de grimório + dourado místico.
abstract final class ArcanePalette {
  static const deepVoid = Color(0xFF120B1E); // fundo — quase-preto violáceo
  static const surface = Color(0xFF1C1230); // cartões e painéis
  static const surfaceHigh = Color(0xFF271A40); // elementos elevados
  static const arcanePurple = Color(0xFF9A6BFF); // primária — magia viva
  static const purpleDim = Color(0xFF5E3FA6); // bordas/estados desabilitados
  static const mysticGold = Color(0xFFD8B45A); // acentos raros — foil, valores
  static const moonlight = Color(0xFFECE4F7); // texto principal
  static const mist = Color(0xFFA795C4); // texto secundário
  static const bloodMoon = Color(0xFFE0566A); // erros / remover
}

ThemeData buildArcaneTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ArcanePalette.arcanePurple,
    onPrimary: Color(0xFF14082A),
    primaryContainer: ArcanePalette.purpleDim,
    onPrimaryContainer: ArcanePalette.moonlight,
    secondary: ArcanePalette.mysticGold,
    onSecondary: Color(0xFF241A05),
    secondaryContainer: Color(0xFF4A3B14),
    onSecondaryContainer: Color(0xFFF2E2B3),
    tertiary: ArcanePalette.mist,
    onTertiary: ArcanePalette.deepVoid,
    error: ArcanePalette.bloodMoon,
    onError: Color(0xFF2A0A10),
    surface: ArcanePalette.surface,
    onSurface: ArcanePalette.moonlight,
    surfaceContainerHighest: ArcanePalette.surfaceHigh,
    onSurfaceVariant: ArcanePalette.mist,
    outline: ArcanePalette.purpleDim,
    outlineVariant: Color(0xFF3A2A5C),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ArcanePalette.moonlight,
    onInverseSurface: ArcanePalette.deepVoid,
    inversePrimary: ArcanePalette.purpleDim,
  );

  // Títulos serifados (Cinzel) sobre corpo limpo (Inter):
  // a serifa carrega o clima de grimório; o corpo mantém legibilidade
  // em tabelas e formulários.
  final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
      .apply(bodyColor: ArcanePalette.moonlight, displayColor: ArcanePalette.moonlight);

  final textTheme = baseText.copyWith(
    displayLarge: GoogleFonts.cinzel(
        textStyle: baseText.displayLarge, fontWeight: FontWeight.w600),
    displayMedium: GoogleFonts.cinzel(
        textStyle: baseText.displayMedium, fontWeight: FontWeight.w600),
    displaySmall: GoogleFonts.cinzel(
        textStyle: baseText.displaySmall, fontWeight: FontWeight.w600),
    headlineLarge: GoogleFonts.cinzel(
        textStyle: baseText.headlineLarge, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.cinzel(
        textStyle: baseText.headlineMedium, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.cinzel(
        textStyle: baseText.headlineSmall, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.cinzel(
        textStyle: baseText.titleLarge, fontWeight: FontWeight.w600),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ArcanePalette.deepVoid,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: ArcanePalette.deepVoid,
      foregroundColor: ArcanePalette.moonlight,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ArcanePalette.surface,
      indicatorColor: ArcanePalette.purpleDim.withValues(alpha: 0.45),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? ArcanePalette.mysticGold
              : ArcanePalette.mist,
        ),
      ),
      labelTextStyle: WidgetStateProperty.all(
        textTheme.labelMedium!.copyWith(letterSpacing: 0.4),
      ),
    ),
    cardTheme: CardThemeData(
      color: ArcanePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3A2A5C)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52), // toque >= 48dp (acessibilidade)
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        foregroundColor: ArcanePalette.moonlight,
        side: const BorderSide(color: ArcanePalette.purpleDim),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ArcanePalette.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ArcanePalette.surfaceHigh,
      contentTextStyle: TextStyle(color: ArcanePalette.moonlight),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF3A2A5C)),
  );
}
