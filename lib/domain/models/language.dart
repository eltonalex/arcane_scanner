/// Idioma da carta impressa (códigos usados por Moxfield/Scryfall).
enum Language {
  en('EN'),
  pt('PT'),
  es('ES'),
  jp('JP'),
  de('DE'),
  fr('FR'),
  it('IT'),
  ru('RU'),
  ko('KO'),
  zhs('ZHS'),
  zht('ZHT');

  const Language(this.code);
  final String code;

  static Language fromCode(String code) => Language.values.firstWhere(
        (l) => l.code == code.toUpperCase(),
        orElse: () => Language.en,
      );
}
