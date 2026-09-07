/// Condição física da carta (códigos padrão de mercado).
enum Condition {
  nm('NM'),
  lp('LP'),
  mp('MP'),
  hp('HP'),
  dmg('DMG');

  const Condition(this.code);
  final String code;

  static Condition fromCode(String code) => Condition.values.firstWhere(
        (c) => c.code == code.toUpperCase(),
        orElse: () => Condition.nm,
      );
}
