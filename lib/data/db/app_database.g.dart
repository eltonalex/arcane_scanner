// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CollectionEntriesTable extends CollectionEntries
    with TableInfo<$CollectionEntriesTable, CollectionEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _scryfallIdMeta =
      const VerificationMeta('scryfallId');
  @override
  late final GeneratedColumn<String> scryfallId = GeneratedColumn<String>(
      'scryfall_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setCodeMeta =
      const VerificationMeta('setCode');
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
      'set_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setNameMeta =
      const VerificationMeta('setName');
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
      'set_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectorNumberMeta =
      const VerificationMeta('collectorNumber');
  @override
  late final GeneratedColumn<String> collectorNumber = GeneratedColumn<String>(
      'collector_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
      'rarity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scryfallUriMeta =
      const VerificationMeta('scryfallUri');
  @override
  late final GeneratedColumn<String> scryfallUri = GeneratedColumn<String>(
      'scryfall_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _foilMeta = const VerificationMeta('foil');
  @override
  late final GeneratedColumn<bool> foil = GeneratedColumn<bool>(
      'foil', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("foil" IN (0, 1))'));
  @override
  late final GeneratedColumnWithTypeConverter<Condition, String> condition =
      GeneratedColumn<String>('condition', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Condition>(
              $CollectionEntriesTable.$convertercondition);
  @override
  late final GeneratedColumnWithTypeConverter<Language, String> language =
      GeneratedColumn<String>('language', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Language>($CollectionEntriesTable.$converterlanguage);
  static const VerificationMeta _priceUsdAtAddMeta =
      const VerificationMeta('priceUsdAtAdd');
  @override
  late final GeneratedColumn<String> priceUsdAtAdd = GeneratedColumn<String>(
      'price_usd_at_add', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceEurAtAddMeta =
      const VerificationMeta('priceEurAtAdd');
  @override
  late final GeneratedColumn<String> priceEurAtAdd = GeneratedColumn<String>(
      'price_eur_at_add', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scryfallId,
        name,
        setCode,
        setName,
        collectorNumber,
        rarity,
        imageUrl,
        scryfallUri,
        quantity,
        foil,
        condition,
        language,
        priceUsdAtAdd,
        priceEurAtAdd,
        addedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_entries';
  @override
  VerificationContext validateIntegrity(Insertable<CollectionEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scryfall_id')) {
      context.handle(
          _scryfallIdMeta,
          scryfallId.isAcceptableOrUnknown(
              data['scryfall_id']!, _scryfallIdMeta));
    } else if (isInserting) {
      context.missing(_scryfallIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(_setCodeMeta,
          setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta));
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    if (data.containsKey('set_name')) {
      context.handle(_setNameMeta,
          setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta));
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('collector_number')) {
      context.handle(
          _collectorNumberMeta,
          collectorNumber.isAcceptableOrUnknown(
              data['collector_number']!, _collectorNumberMeta));
    } else if (isInserting) {
      context.missing(_collectorNumberMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(_rarityMeta,
          rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('scryfall_uri')) {
      context.handle(
          _scryfallUriMeta,
          scryfallUri.isAcceptableOrUnknown(
              data['scryfall_uri']!, _scryfallUriMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('foil')) {
      context.handle(
          _foilMeta, foil.isAcceptableOrUnknown(data['foil']!, _foilMeta));
    } else if (isInserting) {
      context.missing(_foilMeta);
    }
    if (data.containsKey('price_usd_at_add')) {
      context.handle(
          _priceUsdAtAddMeta,
          priceUsdAtAdd.isAcceptableOrUnknown(
              data['price_usd_at_add']!, _priceUsdAtAddMeta));
    }
    if (data.containsKey('price_eur_at_add')) {
      context.handle(
          _priceEurAtAddMeta,
          priceEurAtAdd.isAcceptableOrUnknown(
              data['price_eur_at_add']!, _priceEurAtAddMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {scryfallId, foil, condition, language},
      ];
  @override
  CollectionEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scryfallId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scryfall_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      setCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_code'])!,
      setName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_name'])!,
      collectorNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collector_number'])!,
      rarity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rarity']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      scryfallUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scryfall_uri']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      foil: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}foil'])!,
      condition: $CollectionEntriesTable.$convertercondition.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}condition'])!),
      language: $CollectionEntriesTable.$converterlanguage.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}language'])!),
      priceUsdAtAdd: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}price_usd_at_add']),
      priceEurAtAdd: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}price_eur_at_add']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $CollectionEntriesTable createAlias(String alias) {
    return $CollectionEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Condition, String, String> $convertercondition =
      const EnumNameConverter<Condition>(Condition.values);
  static JsonTypeConverter2<Language, String, String> $converterlanguage =
      const EnumNameConverter<Language>(Language.values);
}

class CollectionEntryRow extends DataClass
    implements Insertable<CollectionEntryRow> {
  final int id;
  final String scryfallId;
  final String name;
  final String setCode;
  final String setName;
  final String collectorNumber;
  final String? rarity;
  final String? imageUrl;
  final String? scryfallUri;
  final int quantity;
  final bool foil;
  final Condition condition;
  final Language language;
  final String? priceUsdAtAdd;
  final String? priceEurAtAdd;
  final DateTime addedAt;
  const CollectionEntryRow(
      {required this.id,
      required this.scryfallId,
      required this.name,
      required this.setCode,
      required this.setName,
      required this.collectorNumber,
      this.rarity,
      this.imageUrl,
      this.scryfallUri,
      required this.quantity,
      required this.foil,
      required this.condition,
      required this.language,
      this.priceUsdAtAdd,
      this.priceEurAtAdd,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scryfall_id'] = Variable<String>(scryfallId);
    map['name'] = Variable<String>(name);
    map['set_code'] = Variable<String>(setCode);
    map['set_name'] = Variable<String>(setName);
    map['collector_number'] = Variable<String>(collectorNumber);
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || scryfallUri != null) {
      map['scryfall_uri'] = Variable<String>(scryfallUri);
    }
    map['quantity'] = Variable<int>(quantity);
    map['foil'] = Variable<bool>(foil);
    {
      map['condition'] = Variable<String>(
          $CollectionEntriesTable.$convertercondition.toSql(condition));
    }
    {
      map['language'] = Variable<String>(
          $CollectionEntriesTable.$converterlanguage.toSql(language));
    }
    if (!nullToAbsent || priceUsdAtAdd != null) {
      map['price_usd_at_add'] = Variable<String>(priceUsdAtAdd);
    }
    if (!nullToAbsent || priceEurAtAdd != null) {
      map['price_eur_at_add'] = Variable<String>(priceEurAtAdd);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionEntriesCompanion toCompanion(bool nullToAbsent) {
    return CollectionEntriesCompanion(
      id: Value(id),
      scryfallId: Value(scryfallId),
      name: Value(name),
      setCode: Value(setCode),
      setName: Value(setName),
      collectorNumber: Value(collectorNumber),
      rarity:
          rarity == null && nullToAbsent ? const Value.absent() : Value(rarity),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      scryfallUri: scryfallUri == null && nullToAbsent
          ? const Value.absent()
          : Value(scryfallUri),
      quantity: Value(quantity),
      foil: Value(foil),
      condition: Value(condition),
      language: Value(language),
      priceUsdAtAdd: priceUsdAtAdd == null && nullToAbsent
          ? const Value.absent()
          : Value(priceUsdAtAdd),
      priceEurAtAdd: priceEurAtAdd == null && nullToAbsent
          ? const Value.absent()
          : Value(priceEurAtAdd),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionEntryRow(
      id: serializer.fromJson<int>(json['id']),
      scryfallId: serializer.fromJson<String>(json['scryfallId']),
      name: serializer.fromJson<String>(json['name']),
      setCode: serializer.fromJson<String>(json['setCode']),
      setName: serializer.fromJson<String>(json['setName']),
      collectorNumber: serializer.fromJson<String>(json['collectorNumber']),
      rarity: serializer.fromJson<String?>(json['rarity']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      scryfallUri: serializer.fromJson<String?>(json['scryfallUri']),
      quantity: serializer.fromJson<int>(json['quantity']),
      foil: serializer.fromJson<bool>(json['foil']),
      condition: $CollectionEntriesTable.$convertercondition
          .fromJson(serializer.fromJson<String>(json['condition'])),
      language: $CollectionEntriesTable.$converterlanguage
          .fromJson(serializer.fromJson<String>(json['language'])),
      priceUsdAtAdd: serializer.fromJson<String?>(json['priceUsdAtAdd']),
      priceEurAtAdd: serializer.fromJson<String?>(json['priceEurAtAdd']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scryfallId': serializer.toJson<String>(scryfallId),
      'name': serializer.toJson<String>(name),
      'setCode': serializer.toJson<String>(setCode),
      'setName': serializer.toJson<String>(setName),
      'collectorNumber': serializer.toJson<String>(collectorNumber),
      'rarity': serializer.toJson<String?>(rarity),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'scryfallUri': serializer.toJson<String?>(scryfallUri),
      'quantity': serializer.toJson<int>(quantity),
      'foil': serializer.toJson<bool>(foil),
      'condition': serializer.toJson<String>(
          $CollectionEntriesTable.$convertercondition.toJson(condition)),
      'language': serializer.toJson<String>(
          $CollectionEntriesTable.$converterlanguage.toJson(language)),
      'priceUsdAtAdd': serializer.toJson<String?>(priceUsdAtAdd),
      'priceEurAtAdd': serializer.toJson<String?>(priceEurAtAdd),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionEntryRow copyWith(
          {int? id,
          String? scryfallId,
          String? name,
          String? setCode,
          String? setName,
          String? collectorNumber,
          Value<String?> rarity = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> scryfallUri = const Value.absent(),
          int? quantity,
          bool? foil,
          Condition? condition,
          Language? language,
          Value<String?> priceUsdAtAdd = const Value.absent(),
          Value<String?> priceEurAtAdd = const Value.absent(),
          DateTime? addedAt}) =>
      CollectionEntryRow(
        id: id ?? this.id,
        scryfallId: scryfallId ?? this.scryfallId,
        name: name ?? this.name,
        setCode: setCode ?? this.setCode,
        setName: setName ?? this.setName,
        collectorNumber: collectorNumber ?? this.collectorNumber,
        rarity: rarity.present ? rarity.value : this.rarity,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        scryfallUri: scryfallUri.present ? scryfallUri.value : this.scryfallUri,
        quantity: quantity ?? this.quantity,
        foil: foil ?? this.foil,
        condition: condition ?? this.condition,
        language: language ?? this.language,
        priceUsdAtAdd:
            priceUsdAtAdd.present ? priceUsdAtAdd.value : this.priceUsdAtAdd,
        priceEurAtAdd:
            priceEurAtAdd.present ? priceEurAtAdd.value : this.priceEurAtAdd,
        addedAt: addedAt ?? this.addedAt,
      );
  CollectionEntryRow copyWithCompanion(CollectionEntriesCompanion data) {
    return CollectionEntryRow(
      id: data.id.present ? data.id.value : this.id,
      scryfallId:
          data.scryfallId.present ? data.scryfallId.value : this.scryfallId,
      name: data.name.present ? data.name.value : this.name,
      setCode: data.setCode.present ? data.setCode.value : this.setCode,
      setName: data.setName.present ? data.setName.value : this.setName,
      collectorNumber: data.collectorNumber.present
          ? data.collectorNumber.value
          : this.collectorNumber,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      scryfallUri:
          data.scryfallUri.present ? data.scryfallUri.value : this.scryfallUri,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      foil: data.foil.present ? data.foil.value : this.foil,
      condition: data.condition.present ? data.condition.value : this.condition,
      language: data.language.present ? data.language.value : this.language,
      priceUsdAtAdd: data.priceUsdAtAdd.present
          ? data.priceUsdAtAdd.value
          : this.priceUsdAtAdd,
      priceEurAtAdd: data.priceEurAtAdd.present
          ? data.priceEurAtAdd.value
          : this.priceEurAtAdd,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionEntryRow(')
          ..write('id: $id, ')
          ..write('scryfallId: $scryfallId, ')
          ..write('name: $name, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('rarity: $rarity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('scryfallUri: $scryfallUri, ')
          ..write('quantity: $quantity, ')
          ..write('foil: $foil, ')
          ..write('condition: $condition, ')
          ..write('language: $language, ')
          ..write('priceUsdAtAdd: $priceUsdAtAdd, ')
          ..write('priceEurAtAdd: $priceEurAtAdd, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      scryfallId,
      name,
      setCode,
      setName,
      collectorNumber,
      rarity,
      imageUrl,
      scryfallUri,
      quantity,
      foil,
      condition,
      language,
      priceUsdAtAdd,
      priceEurAtAdd,
      addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionEntryRow &&
          other.id == this.id &&
          other.scryfallId == this.scryfallId &&
          other.name == this.name &&
          other.setCode == this.setCode &&
          other.setName == this.setName &&
          other.collectorNumber == this.collectorNumber &&
          other.rarity == this.rarity &&
          other.imageUrl == this.imageUrl &&
          other.scryfallUri == this.scryfallUri &&
          other.quantity == this.quantity &&
          other.foil == this.foil &&
          other.condition == this.condition &&
          other.language == this.language &&
          other.priceUsdAtAdd == this.priceUsdAtAdd &&
          other.priceEurAtAdd == this.priceEurAtAdd &&
          other.addedAt == this.addedAt);
}

class CollectionEntriesCompanion extends UpdateCompanion<CollectionEntryRow> {
  final Value<int> id;
  final Value<String> scryfallId;
  final Value<String> name;
  final Value<String> setCode;
  final Value<String> setName;
  final Value<String> collectorNumber;
  final Value<String?> rarity;
  final Value<String?> imageUrl;
  final Value<String?> scryfallUri;
  final Value<int> quantity;
  final Value<bool> foil;
  final Value<Condition> condition;
  final Value<Language> language;
  final Value<String?> priceUsdAtAdd;
  final Value<String?> priceEurAtAdd;
  final Value<DateTime> addedAt;
  const CollectionEntriesCompanion({
    this.id = const Value.absent(),
    this.scryfallId = const Value.absent(),
    this.name = const Value.absent(),
    this.setCode = const Value.absent(),
    this.setName = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.rarity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.scryfallUri = const Value.absent(),
    this.quantity = const Value.absent(),
    this.foil = const Value.absent(),
    this.condition = const Value.absent(),
    this.language = const Value.absent(),
    this.priceUsdAtAdd = const Value.absent(),
    this.priceEurAtAdd = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  CollectionEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String scryfallId,
    required String name,
    required String setCode,
    required String setName,
    required String collectorNumber,
    this.rarity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.scryfallUri = const Value.absent(),
    required int quantity,
    required bool foil,
    required Condition condition,
    required Language language,
    this.priceUsdAtAdd = const Value.absent(),
    this.priceEurAtAdd = const Value.absent(),
    required DateTime addedAt,
  })  : scryfallId = Value(scryfallId),
        name = Value(name),
        setCode = Value(setCode),
        setName = Value(setName),
        collectorNumber = Value(collectorNumber),
        quantity = Value(quantity),
        foil = Value(foil),
        condition = Value(condition),
        language = Value(language),
        addedAt = Value(addedAt);
  static Insertable<CollectionEntryRow> custom({
    Expression<int>? id,
    Expression<String>? scryfallId,
    Expression<String>? name,
    Expression<String>? setCode,
    Expression<String>? setName,
    Expression<String>? collectorNumber,
    Expression<String>? rarity,
    Expression<String>? imageUrl,
    Expression<String>? scryfallUri,
    Expression<int>? quantity,
    Expression<bool>? foil,
    Expression<String>? condition,
    Expression<String>? language,
    Expression<String>? priceUsdAtAdd,
    Expression<String>? priceEurAtAdd,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scryfallId != null) 'scryfall_id': scryfallId,
      if (name != null) 'name': name,
      if (setCode != null) 'set_code': setCode,
      if (setName != null) 'set_name': setName,
      if (collectorNumber != null) 'collector_number': collectorNumber,
      if (rarity != null) 'rarity': rarity,
      if (imageUrl != null) 'image_url': imageUrl,
      if (scryfallUri != null) 'scryfall_uri': scryfallUri,
      if (quantity != null) 'quantity': quantity,
      if (foil != null) 'foil': foil,
      if (condition != null) 'condition': condition,
      if (language != null) 'language': language,
      if (priceUsdAtAdd != null) 'price_usd_at_add': priceUsdAtAdd,
      if (priceEurAtAdd != null) 'price_eur_at_add': priceEurAtAdd,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  CollectionEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? scryfallId,
      Value<String>? name,
      Value<String>? setCode,
      Value<String>? setName,
      Value<String>? collectorNumber,
      Value<String?>? rarity,
      Value<String?>? imageUrl,
      Value<String?>? scryfallUri,
      Value<int>? quantity,
      Value<bool>? foil,
      Value<Condition>? condition,
      Value<Language>? language,
      Value<String?>? priceUsdAtAdd,
      Value<String?>? priceEurAtAdd,
      Value<DateTime>? addedAt}) {
    return CollectionEntriesCompanion(
      id: id ?? this.id,
      scryfallId: scryfallId ?? this.scryfallId,
      name: name ?? this.name,
      setCode: setCode ?? this.setCode,
      setName: setName ?? this.setName,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      rarity: rarity ?? this.rarity,
      imageUrl: imageUrl ?? this.imageUrl,
      scryfallUri: scryfallUri ?? this.scryfallUri,
      quantity: quantity ?? this.quantity,
      foil: foil ?? this.foil,
      condition: condition ?? this.condition,
      language: language ?? this.language,
      priceUsdAtAdd: priceUsdAtAdd ?? this.priceUsdAtAdd,
      priceEurAtAdd: priceEurAtAdd ?? this.priceEurAtAdd,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scryfallId.present) {
      map['scryfall_id'] = Variable<String>(scryfallId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (collectorNumber.present) {
      map['collector_number'] = Variable<String>(collectorNumber.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (scryfallUri.present) {
      map['scryfall_uri'] = Variable<String>(scryfallUri.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (foil.present) {
      map['foil'] = Variable<bool>(foil.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(
          $CollectionEntriesTable.$convertercondition.toSql(condition.value));
    }
    if (language.present) {
      map['language'] = Variable<String>(
          $CollectionEntriesTable.$converterlanguage.toSql(language.value));
    }
    if (priceUsdAtAdd.present) {
      map['price_usd_at_add'] = Variable<String>(priceUsdAtAdd.value);
    }
    if (priceEurAtAdd.present) {
      map['price_eur_at_add'] = Variable<String>(priceEurAtAdd.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('scryfallId: $scryfallId, ')
          ..write('name: $name, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('rarity: $rarity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('scryfallUri: $scryfallUri, ')
          ..write('quantity: $quantity, ')
          ..write('foil: $foil, ')
          ..write('condition: $condition, ')
          ..write('language: $language, ')
          ..write('priceUsdAtAdd: $priceUsdAtAdd, ')
          ..write('priceEurAtAdd: $priceEurAtAdd, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionEntriesTable collectionEntries =
      $CollectionEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [collectionEntries];
}

typedef $$CollectionEntriesTableCreateCompanionBuilder
    = CollectionEntriesCompanion Function({
  Value<int> id,
  required String scryfallId,
  required String name,
  required String setCode,
  required String setName,
  required String collectorNumber,
  Value<String?> rarity,
  Value<String?> imageUrl,
  Value<String?> scryfallUri,
  required int quantity,
  required bool foil,
  required Condition condition,
  required Language language,
  Value<String?> priceUsdAtAdd,
  Value<String?> priceEurAtAdd,
  required DateTime addedAt,
});
typedef $$CollectionEntriesTableUpdateCompanionBuilder
    = CollectionEntriesCompanion Function({
  Value<int> id,
  Value<String> scryfallId,
  Value<String> name,
  Value<String> setCode,
  Value<String> setName,
  Value<String> collectorNumber,
  Value<String?> rarity,
  Value<String?> imageUrl,
  Value<String?> scryfallUri,
  Value<int> quantity,
  Value<bool> foil,
  Value<Condition> condition,
  Value<Language> language,
  Value<String?> priceUsdAtAdd,
  Value<String?> priceEurAtAdd,
  Value<DateTime> addedAt,
});

class $$CollectionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionEntriesTable> {
  $$CollectionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scryfallId => $composableBuilder(
      column: $table.scryfallId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setCode => $composableBuilder(
      column: $table.setCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setName => $composableBuilder(
      column: $table.setName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectorNumber => $composableBuilder(
      column: $table.collectorNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rarity => $composableBuilder(
      column: $table.rarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scryfallUri => $composableBuilder(
      column: $table.scryfallUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get foil => $composableBuilder(
      column: $table.foil, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Condition, Condition, String> get condition =>
      $composableBuilder(
          column: $table.condition,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Language, Language, String> get language =>
      $composableBuilder(
          column: $table.language,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get priceUsdAtAdd => $composableBuilder(
      column: $table.priceUsdAtAdd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priceEurAtAdd => $composableBuilder(
      column: $table.priceEurAtAdd, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$CollectionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionEntriesTable> {
  $$CollectionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scryfallId => $composableBuilder(
      column: $table.scryfallId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setCode => $composableBuilder(
      column: $table.setCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setName => $composableBuilder(
      column: $table.setName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectorNumber => $composableBuilder(
      column: $table.collectorNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rarity => $composableBuilder(
      column: $table.rarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scryfallUri => $composableBuilder(
      column: $table.scryfallUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get foil => $composableBuilder(
      column: $table.foil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priceUsdAtAdd => $composableBuilder(
      column: $table.priceUsdAtAdd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priceEurAtAdd => $composableBuilder(
      column: $table.priceEurAtAdd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$CollectionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionEntriesTable> {
  $$CollectionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scryfallId => $composableBuilder(
      column: $table.scryfallId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get collectorNumber => $composableBuilder(
      column: $table.collectorNumber, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get scryfallUri => $composableBuilder(
      column: $table.scryfallUri, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get foil =>
      $composableBuilder(column: $table.foil, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Condition, String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Language, String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get priceUsdAtAdd => $composableBuilder(
      column: $table.priceUsdAtAdd, builder: (column) => column);

  GeneratedColumn<String> get priceEurAtAdd => $composableBuilder(
      column: $table.priceEurAtAdd, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$CollectionEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionEntriesTable,
    CollectionEntryRow,
    $$CollectionEntriesTableFilterComposer,
    $$CollectionEntriesTableOrderingComposer,
    $$CollectionEntriesTableAnnotationComposer,
    $$CollectionEntriesTableCreateCompanionBuilder,
    $$CollectionEntriesTableUpdateCompanionBuilder,
    (
      CollectionEntryRow,
      BaseReferences<_$AppDatabase, $CollectionEntriesTable, CollectionEntryRow>
    ),
    CollectionEntryRow,
    PrefetchHooks Function()> {
  $$CollectionEntriesTableTableManager(
      _$AppDatabase db, $CollectionEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> scryfallId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> setCode = const Value.absent(),
            Value<String> setName = const Value.absent(),
            Value<String> collectorNumber = const Value.absent(),
            Value<String?> rarity = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> scryfallUri = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<bool> foil = const Value.absent(),
            Value<Condition> condition = const Value.absent(),
            Value<Language> language = const Value.absent(),
            Value<String?> priceUsdAtAdd = const Value.absent(),
            Value<String?> priceEurAtAdd = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              CollectionEntriesCompanion(
            id: id,
            scryfallId: scryfallId,
            name: name,
            setCode: setCode,
            setName: setName,
            collectorNumber: collectorNumber,
            rarity: rarity,
            imageUrl: imageUrl,
            scryfallUri: scryfallUri,
            quantity: quantity,
            foil: foil,
            condition: condition,
            language: language,
            priceUsdAtAdd: priceUsdAtAdd,
            priceEurAtAdd: priceEurAtAdd,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String scryfallId,
            required String name,
            required String setCode,
            required String setName,
            required String collectorNumber,
            Value<String?> rarity = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> scryfallUri = const Value.absent(),
            required int quantity,
            required bool foil,
            required Condition condition,
            required Language language,
            Value<String?> priceUsdAtAdd = const Value.absent(),
            Value<String?> priceEurAtAdd = const Value.absent(),
            required DateTime addedAt,
          }) =>
              CollectionEntriesCompanion.insert(
            id: id,
            scryfallId: scryfallId,
            name: name,
            setCode: setCode,
            setName: setName,
            collectorNumber: collectorNumber,
            rarity: rarity,
            imageUrl: imageUrl,
            scryfallUri: scryfallUri,
            quantity: quantity,
            foil: foil,
            condition: condition,
            language: language,
            priceUsdAtAdd: priceUsdAtAdd,
            priceEurAtAdd: priceEurAtAdd,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CollectionEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionEntriesTable,
    CollectionEntryRow,
    $$CollectionEntriesTableFilterComposer,
    $$CollectionEntriesTableOrderingComposer,
    $$CollectionEntriesTableAnnotationComposer,
    $$CollectionEntriesTableCreateCompanionBuilder,
    $$CollectionEntriesTableUpdateCompanionBuilder,
    (
      CollectionEntryRow,
      BaseReferences<_$AppDatabase, $CollectionEntriesTable, CollectionEntryRow>
    ),
    CollectionEntryRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionEntriesTableTableManager get collectionEntries =>
      $$CollectionEntriesTableTableManager(_db, _db.collectionEntries);
}
