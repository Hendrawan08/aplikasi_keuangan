// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lokasiMeta = const VerificationMeta('lokasi');
  @override
  late final GeneratedColumn<String> lokasi = GeneratedColumn<String>(
    'lokasi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nama, lokasi, fotoPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    }
    if (data.containsKey('lokasi')) {
      context.handle(
        _lokasiMeta,
        lokasi.isAcceptableOrUnknown(data['lokasi']!, _lokasiMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      ),
      lokasi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lokasi'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String? nama;
  final String? lokasi;
  final String? fotoPath;
  const Profile({required this.id, this.nama, this.lokasi, this.fotoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || nama != null) {
      map['nama'] = Variable<String>(nama);
    }
    if (!nullToAbsent || lokasi != null) {
      map['lokasi'] = Variable<String>(lokasi);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      nama: nama == null && nullToAbsent ? const Value.absent() : Value(nama),
      lokasi: lokasi == null && nullToAbsent
          ? const Value.absent()
          : Value(lokasi),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String?>(json['nama']),
      lokasi: serializer.fromJson<String?>(json['lokasi']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String?>(nama),
      'lokasi': serializer.toJson<String?>(lokasi),
      'fotoPath': serializer.toJson<String?>(fotoPath),
    };
  }

  Profile copyWith({
    int? id,
    Value<String?> nama = const Value.absent(),
    Value<String?> lokasi = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
  }) => Profile(
    id: id ?? this.id,
    nama: nama.present ? nama.value : this.nama,
    lokasi: lokasi.present ? lokasi.value : this.lokasi,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      lokasi: data.lokasi.present ? data.lokasi.value : this.lokasi,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('lokasi: $lokasi, ')
          ..write('fotoPath: $fotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama, lokasi, fotoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.lokasi == this.lokasi &&
          other.fotoPath == this.fotoPath);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String?> nama;
  final Value<String?> lokasi;
  final Value<String?> fotoPath;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.lokasi = const Value.absent(),
    this.fotoPath = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.lokasi = const Value.absent(),
    this.fotoPath = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? nama,
    Expression<String>? lokasi,
    Expression<String>? fotoPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (lokasi != null) 'lokasi': lokasi,
      if (fotoPath != null) 'foto_path': fotoPath,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String?>? nama,
    Value<String?>? lokasi,
    Value<String?>? fotoPath,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (lokasi.present) {
      map['lokasi'] = Variable<String>(lokasi.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('lokasi: $lokasi, ')
          ..write('fotoPath: $fotoPath')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bulanKeyMeta = const VerificationMeta(
    'bulanKey',
  );
  @override
  late final GeneratedColumn<String> bulanKey = GeneratedColumn<String>(
    'bulan_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bulanKey, nominal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bulan_key')) {
      context.handle(
        _bulanKeyMeta,
        bulanKey.isAcceptableOrUnknown(data['bulan_key']!, _bulanKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_bulanKeyMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bulanKey};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      bulanKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bulan_key'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nominal'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String bulanKey;
  final int nominal;
  const Budget({required this.bulanKey, required this.nominal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bulan_key'] = Variable<String>(bulanKey);
    map['nominal'] = Variable<int>(nominal);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(bulanKey: Value(bulanKey), nominal: Value(nominal));
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      bulanKey: serializer.fromJson<String>(json['bulanKey']),
      nominal: serializer.fromJson<int>(json['nominal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bulanKey': serializer.toJson<String>(bulanKey),
      'nominal': serializer.toJson<int>(nominal),
    };
  }

  Budget copyWith({String? bulanKey, int? nominal}) => Budget(
    bulanKey: bulanKey ?? this.bulanKey,
    nominal: nominal ?? this.nominal,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      bulanKey: data.bulanKey.present ? data.bulanKey.value : this.bulanKey,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('bulanKey: $bulanKey, ')
          ..write('nominal: $nominal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bulanKey, nominal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.bulanKey == this.bulanKey &&
          other.nominal == this.nominal);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> bulanKey;
  final Value<int> nominal;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.bulanKey = const Value.absent(),
    this.nominal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String bulanKey,
    required int nominal,
    this.rowid = const Value.absent(),
  }) : bulanKey = Value(bulanKey),
       nominal = Value(nominal);
  static Insertable<Budget> custom({
    Expression<String>? bulanKey,
    Expression<int>? nominal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bulanKey != null) 'bulan_key': bulanKey,
      if (nominal != null) 'nominal': nominal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? bulanKey,
    Value<int>? nominal,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      bulanKey: bulanKey ?? this.bulanKey,
      nominal: nominal ?? this.nominal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bulanKey.present) {
      map['bulan_key'] = Variable<String>(bulanKey.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('bulanKey: $bulanKey, ')
          ..write('nominal: $nominal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bulanKeyMeta = const VerificationMeta(
    'bulanKey',
  );
  @override
  late final GeneratedColumn<String> bulanKey = GeneratedColumn<String>(
    'bulan_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetNominalMeta = const VerificationMeta(
    'targetNominal',
  );
  @override
  late final GeneratedColumn<int> targetNominal = GeneratedColumn<int>(
    'target_nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bulanKey, targetNominal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bulan_key')) {
      context.handle(
        _bulanKeyMeta,
        bulanKey.isAcceptableOrUnknown(data['bulan_key']!, _bulanKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_bulanKeyMeta);
    }
    if (data.containsKey('target_nominal')) {
      context.handle(
        _targetNominalMeta,
        targetNominal.isAcceptableOrUnknown(
          data['target_nominal']!,
          _targetNominalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetNominalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bulanKey};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      bulanKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bulan_key'],
      )!,
      targetNominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_nominal'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final String bulanKey;
  final int targetNominal;
  const SavingsGoal({required this.bulanKey, required this.targetNominal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bulan_key'] = Variable<String>(bulanKey);
    map['target_nominal'] = Variable<int>(targetNominal);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      bulanKey: Value(bulanKey),
      targetNominal: Value(targetNominal),
    );
  }

  factory SavingsGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      bulanKey: serializer.fromJson<String>(json['bulanKey']),
      targetNominal: serializer.fromJson<int>(json['targetNominal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bulanKey': serializer.toJson<String>(bulanKey),
      'targetNominal': serializer.toJson<int>(targetNominal),
    };
  }

  SavingsGoal copyWith({String? bulanKey, int? targetNominal}) => SavingsGoal(
    bulanKey: bulanKey ?? this.bulanKey,
    targetNominal: targetNominal ?? this.targetNominal,
  );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      bulanKey: data.bulanKey.present ? data.bulanKey.value : this.bulanKey,
      targetNominal: data.targetNominal.present
          ? data.targetNominal.value
          : this.targetNominal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('bulanKey: $bulanKey, ')
          ..write('targetNominal: $targetNominal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bulanKey, targetNominal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.bulanKey == this.bulanKey &&
          other.targetNominal == this.targetNominal);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<String> bulanKey;
  final Value<int> targetNominal;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.bulanKey = const Value.absent(),
    this.targetNominal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String bulanKey,
    required int targetNominal,
    this.rowid = const Value.absent(),
  }) : bulanKey = Value(bulanKey),
       targetNominal = Value(targetNominal);
  static Insertable<SavingsGoal> custom({
    Expression<String>? bulanKey,
    Expression<int>? targetNominal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bulanKey != null) 'bulan_key': bulanKey,
      if (targetNominal != null) 'target_nominal': targetNominal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<String>? bulanKey,
    Value<int>? targetNominal,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      bulanKey: bulanKey ?? this.bulanKey,
      targetNominal: targetNominal ?? this.targetNominal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bulanKey.present) {
      map['bulan_key'] = Variable<String>(bulanKey.value);
    }
    if (targetNominal.present) {
      map['target_nominal'] = Variable<int>(targetNominal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('bulanKey: $bulanKey, ')
          ..write('targetNominal: $targetNominal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetKategoriTable extends BudgetKategori
    with TableInfo<$BudgetKategoriTable, BudgetKategoriData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetKategoriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bulanKeyMeta = const VerificationMeta(
    'bulanKey',
  );
  @override
  late final GeneratedColumn<String> bulanKey = GeneratedColumn<String>(
    'bulan_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bulanKey, kategori, nominal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_kategori';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetKategoriData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bulan_key')) {
      context.handle(
        _bulanKeyMeta,
        bulanKey.isAcceptableOrUnknown(data['bulan_key']!, _bulanKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_bulanKeyMeta);
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetKategoriData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetKategoriData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bulanKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bulan_key'],
      )!,
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nominal'],
      )!,
    );
  }

  @override
  $BudgetKategoriTable createAlias(String alias) {
    return $BudgetKategoriTable(attachedDatabase, alias);
  }
}

class BudgetKategoriData extends DataClass
    implements Insertable<BudgetKategoriData> {
  final int id;
  final String bulanKey;
  final String kategori;
  final int nominal;
  const BudgetKategoriData({
    required this.id,
    required this.bulanKey,
    required this.kategori,
    required this.nominal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bulan_key'] = Variable<String>(bulanKey);
    map['kategori'] = Variable<String>(kategori);
    map['nominal'] = Variable<int>(nominal);
    return map;
  }

  BudgetKategoriCompanion toCompanion(bool nullToAbsent) {
    return BudgetKategoriCompanion(
      id: Value(id),
      bulanKey: Value(bulanKey),
      kategori: Value(kategori),
      nominal: Value(nominal),
    );
  }

  factory BudgetKategoriData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetKategoriData(
      id: serializer.fromJson<int>(json['id']),
      bulanKey: serializer.fromJson<String>(json['bulanKey']),
      kategori: serializer.fromJson<String>(json['kategori']),
      nominal: serializer.fromJson<int>(json['nominal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bulanKey': serializer.toJson<String>(bulanKey),
      'kategori': serializer.toJson<String>(kategori),
      'nominal': serializer.toJson<int>(nominal),
    };
  }

  BudgetKategoriData copyWith({
    int? id,
    String? bulanKey,
    String? kategori,
    int? nominal,
  }) => BudgetKategoriData(
    id: id ?? this.id,
    bulanKey: bulanKey ?? this.bulanKey,
    kategori: kategori ?? this.kategori,
    nominal: nominal ?? this.nominal,
  );
  BudgetKategoriData copyWithCompanion(BudgetKategoriCompanion data) {
    return BudgetKategoriData(
      id: data.id.present ? data.id.value : this.id,
      bulanKey: data.bulanKey.present ? data.bulanKey.value : this.bulanKey,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetKategoriData(')
          ..write('id: $id, ')
          ..write('bulanKey: $bulanKey, ')
          ..write('kategori: $kategori, ')
          ..write('nominal: $nominal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bulanKey, kategori, nominal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetKategoriData &&
          other.id == this.id &&
          other.bulanKey == this.bulanKey &&
          other.kategori == this.kategori &&
          other.nominal == this.nominal);
}

class BudgetKategoriCompanion extends UpdateCompanion<BudgetKategoriData> {
  final Value<int> id;
  final Value<String> bulanKey;
  final Value<String> kategori;
  final Value<int> nominal;
  const BudgetKategoriCompanion({
    this.id = const Value.absent(),
    this.bulanKey = const Value.absent(),
    this.kategori = const Value.absent(),
    this.nominal = const Value.absent(),
  });
  BudgetKategoriCompanion.insert({
    this.id = const Value.absent(),
    required String bulanKey,
    required String kategori,
    required int nominal,
  }) : bulanKey = Value(bulanKey),
       kategori = Value(kategori),
       nominal = Value(nominal);
  static Insertable<BudgetKategoriData> custom({
    Expression<int>? id,
    Expression<String>? bulanKey,
    Expression<String>? kategori,
    Expression<int>? nominal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bulanKey != null) 'bulan_key': bulanKey,
      if (kategori != null) 'kategori': kategori,
      if (nominal != null) 'nominal': nominal,
    });
  }

  BudgetKategoriCompanion copyWith({
    Value<int>? id,
    Value<String>? bulanKey,
    Value<String>? kategori,
    Value<int>? nominal,
  }) {
    return BudgetKategoriCompanion(
      id: id ?? this.id,
      bulanKey: bulanKey ?? this.bulanKey,
      kategori: kategori ?? this.kategori,
      nominal: nominal ?? this.nominal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bulanKey.present) {
      map['bulan_key'] = Variable<String>(bulanKey.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetKategoriCompanion(')
          ..write('id: $id, ')
          ..write('bulanKey: $bulanKey, ')
          ..write('kategori: $kategori, ')
          ..write('nominal: $nominal')
          ..write(')'))
        .toString();
  }
}

class $CustomKategoriTable extends CustomKategori
    with TableInfo<$CustomKategoriTable, CustomKategoriData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomKategoriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
    'tipe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ikonMeta = const VerificationMeta('ikon');
  @override
  late final GeneratedColumn<String> ikon = GeneratedColumn<String>(
    'ikon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📌'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nama, tipe, ikon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_kategori';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomKategoriData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
        _tipeMeta,
        tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    if (data.containsKey('ikon')) {
      context.handle(
        _ikonMeta,
        ikon.isAcceptableOrUnknown(data['ikon']!, _ikonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomKategoriData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomKategoriData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      tipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipe'],
      )!,
      ikon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikon'],
      )!,
    );
  }

  @override
  $CustomKategoriTable createAlias(String alias) {
    return $CustomKategoriTable(attachedDatabase, alias);
  }
}

class CustomKategoriData extends DataClass
    implements Insertable<CustomKategoriData> {
  final String id;
  final String nama;
  final String tipe;
  final String ikon;
  const CustomKategoriData({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.ikon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['tipe'] = Variable<String>(tipe);
    map['ikon'] = Variable<String>(ikon);
    return map;
  }

  CustomKategoriCompanion toCompanion(bool nullToAbsent) {
    return CustomKategoriCompanion(
      id: Value(id),
      nama: Value(nama),
      tipe: Value(tipe),
      ikon: Value(ikon),
    );
  }

  factory CustomKategoriData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomKategoriData(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      tipe: serializer.fromJson<String>(json['tipe']),
      ikon: serializer.fromJson<String>(json['ikon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'tipe': serializer.toJson<String>(tipe),
      'ikon': serializer.toJson<String>(ikon),
    };
  }

  CustomKategoriData copyWith({
    String? id,
    String? nama,
    String? tipe,
    String? ikon,
  }) => CustomKategoriData(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    tipe: tipe ?? this.tipe,
    ikon: ikon ?? this.ikon,
  );
  CustomKategoriData copyWithCompanion(CustomKategoriCompanion data) {
    return CustomKategoriData(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      ikon: data.ikon.present ? data.ikon.value : this.ikon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomKategoriData(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('tipe: $tipe, ')
          ..write('ikon: $ikon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama, tipe, ikon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomKategoriData &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.tipe == this.tipe &&
          other.ikon == this.ikon);
}

class CustomKategoriCompanion extends UpdateCompanion<CustomKategoriData> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> tipe;
  final Value<String> ikon;
  final Value<int> rowid;
  const CustomKategoriCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.tipe = const Value.absent(),
    this.ikon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomKategoriCompanion.insert({
    required String id,
    required String nama,
    required String tipe,
    this.ikon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       tipe = Value(tipe);
  static Insertable<CustomKategoriData> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? tipe,
    Expression<String>? ikon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (tipe != null) 'tipe': tipe,
      if (ikon != null) 'ikon': ikon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomKategoriCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? tipe,
    Value<String>? ikon,
    Value<int>? rowid,
  }) {
    return CustomKategoriCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      ikon: ikon ?? this.ikon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (ikon.present) {
      map['ikon'] = Variable<String>(ikon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomKategoriCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('tipe: $tipe, ')
          ..write('ikon: $ikon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
    'tipe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saldoAwalMeta = const VerificationMeta(
    'saldoAwal',
  );
  @override
  late final GeneratedColumn<int> saldoAwal = GeneratedColumn<int>(
    'saldo_awal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warnaMeta = const VerificationMeta('warna');
  @override
  late final GeneratedColumn<String> warna = GeneratedColumn<String>(
    'warna',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#2E7D32'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nama, tipe, saldoAwal, warna];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
        _tipeMeta,
        tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    if (data.containsKey('saldo_awal')) {
      context.handle(
        _saldoAwalMeta,
        saldoAwal.isAcceptableOrUnknown(data['saldo_awal']!, _saldoAwalMeta),
      );
    }
    if (data.containsKey('warna')) {
      context.handle(
        _warnaMeta,
        warna.isAcceptableOrUnknown(data['warna']!, _warnaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      tipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipe'],
      )!,
      saldoAwal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_awal'],
      )!,
      warna: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warna'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final String id;
  final String nama;
  final String tipe;
  final int saldoAwal;
  final String warna;
  const Wallet({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.saldoAwal,
    required this.warna,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['tipe'] = Variable<String>(tipe);
    map['saldo_awal'] = Variable<int>(saldoAwal);
    map['warna'] = Variable<String>(warna);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      nama: Value(nama),
      tipe: Value(tipe),
      saldoAwal: Value(saldoAwal),
      warna: Value(warna),
    );
  }

  factory Wallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      tipe: serializer.fromJson<String>(json['tipe']),
      saldoAwal: serializer.fromJson<int>(json['saldoAwal']),
      warna: serializer.fromJson<String>(json['warna']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'tipe': serializer.toJson<String>(tipe),
      'saldoAwal': serializer.toJson<int>(saldoAwal),
      'warna': serializer.toJson<String>(warna),
    };
  }

  Wallet copyWith({
    String? id,
    String? nama,
    String? tipe,
    int? saldoAwal,
    String? warna,
  }) => Wallet(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    tipe: tipe ?? this.tipe,
    saldoAwal: saldoAwal ?? this.saldoAwal,
    warna: warna ?? this.warna,
  );
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      saldoAwal: data.saldoAwal.present ? data.saldoAwal.value : this.saldoAwal,
      warna: data.warna.present ? data.warna.value : this.warna,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('tipe: $tipe, ')
          ..write('saldoAwal: $saldoAwal, ')
          ..write('warna: $warna')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama, tipe, saldoAwal, warna);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.tipe == this.tipe &&
          other.saldoAwal == this.saldoAwal &&
          other.warna == this.warna);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> tipe;
  final Value<int> saldoAwal;
  final Value<String> warna;
  final Value<int> rowid;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.tipe = const Value.absent(),
    this.saldoAwal = const Value.absent(),
    this.warna = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String id,
    required String nama,
    required String tipe,
    this.saldoAwal = const Value.absent(),
    this.warna = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       tipe = Value(tipe);
  static Insertable<Wallet> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? tipe,
    Expression<int>? saldoAwal,
    Expression<String>? warna,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (tipe != null) 'tipe': tipe,
      if (saldoAwal != null) 'saldo_awal': saldoAwal,
      if (warna != null) 'warna': warna,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? tipe,
    Value<int>? saldoAwal,
    Value<String>? warna,
    Value<int>? rowid,
  }) {
    return WalletsCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      saldoAwal: saldoAwal ?? this.saldoAwal,
      warna: warna ?? this.warna,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (saldoAwal.present) {
      map['saldo_awal'] = Variable<int>(saldoAwal.value);
    }
    if (warna.present) {
      map['warna'] = Variable<String>(warna.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('tipe: $tipe, ')
          ..write('saldoAwal: $saldoAwal, ')
          ..write('warna: $warna, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialGoalsTable extends FinancialGoals
    with TableInfo<$FinancialGoalsTable, FinancialGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetNominalMeta = const VerificationMeta(
    'targetNominal',
  );
  @override
  late final GeneratedColumn<int> targetNominal = GeneratedColumn<int>(
    'target_nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _terkumpulMeta = const VerificationMeta(
    'terkumpul',
  );
  @override
  late final GeneratedColumn<int> terkumpul = GeneratedColumn<int>(
    'terkumpul',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Tabungan'),
  );
  static const VerificationMeta _ikonMeta = const VerificationMeta('ikon');
  @override
  late final GeneratedColumn<String> ikon = GeneratedColumn<String>(
    'ikon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🎯'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    targetNominal,
    terkumpul,
    deadline,
    kategori,
    ikon,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('target_nominal')) {
      context.handle(
        _targetNominalMeta,
        targetNominal.isAcceptableOrUnknown(
          data['target_nominal']!,
          _targetNominalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetNominalMeta);
    }
    if (data.containsKey('terkumpul')) {
      context.handle(
        _terkumpulMeta,
        terkumpul.isAcceptableOrUnknown(data['terkumpul']!, _terkumpulMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    }
    if (data.containsKey('ikon')) {
      context.handle(
        _ikonMeta,
        ikon.isAcceptableOrUnknown(data['ikon']!, _ikonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      targetNominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_nominal'],
      )!,
      terkumpul: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}terkumpul'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      ikon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikon'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FinancialGoalsTable createAlias(String alias) {
    return $FinancialGoalsTable(attachedDatabase, alias);
  }
}

class FinancialGoal extends DataClass implements Insertable<FinancialGoal> {
  final String id;
  final String nama;
  final int targetNominal;
  final int terkumpul;
  final DateTime? deadline;
  final String kategori;
  final String ikon;
  final DateTime createdAt;
  const FinancialGoal({
    required this.id,
    required this.nama,
    required this.targetNominal,
    required this.terkumpul,
    this.deadline,
    required this.kategori,
    required this.ikon,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['target_nominal'] = Variable<int>(targetNominal);
    map['terkumpul'] = Variable<int>(terkumpul);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['kategori'] = Variable<String>(kategori);
    map['ikon'] = Variable<String>(ikon);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FinancialGoalsCompanion toCompanion(bool nullToAbsent) {
    return FinancialGoalsCompanion(
      id: Value(id),
      nama: Value(nama),
      targetNominal: Value(targetNominal),
      terkumpul: Value(terkumpul),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      kategori: Value(kategori),
      ikon: Value(ikon),
      createdAt: Value(createdAt),
    );
  }

  factory FinancialGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialGoal(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      targetNominal: serializer.fromJson<int>(json['targetNominal']),
      terkumpul: serializer.fromJson<int>(json['terkumpul']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      kategori: serializer.fromJson<String>(json['kategori']),
      ikon: serializer.fromJson<String>(json['ikon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'targetNominal': serializer.toJson<int>(targetNominal),
      'terkumpul': serializer.toJson<int>(terkumpul),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'kategori': serializer.toJson<String>(kategori),
      'ikon': serializer.toJson<String>(ikon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FinancialGoal copyWith({
    String? id,
    String? nama,
    int? targetNominal,
    int? terkumpul,
    Value<DateTime?> deadline = const Value.absent(),
    String? kategori,
    String? ikon,
    DateTime? createdAt,
  }) => FinancialGoal(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    targetNominal: targetNominal ?? this.targetNominal,
    terkumpul: terkumpul ?? this.terkumpul,
    deadline: deadline.present ? deadline.value : this.deadline,
    kategori: kategori ?? this.kategori,
    ikon: ikon ?? this.ikon,
    createdAt: createdAt ?? this.createdAt,
  );
  FinancialGoal copyWithCompanion(FinancialGoalsCompanion data) {
    return FinancialGoal(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      targetNominal: data.targetNominal.present
          ? data.targetNominal.value
          : this.targetNominal,
      terkumpul: data.terkumpul.present ? data.terkumpul.value : this.terkumpul,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      ikon: data.ikon.present ? data.ikon.value : this.ikon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialGoal(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('targetNominal: $targetNominal, ')
          ..write('terkumpul: $terkumpul, ')
          ..write('deadline: $deadline, ')
          ..write('kategori: $kategori, ')
          ..write('ikon: $ikon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    targetNominal,
    terkumpul,
    deadline,
    kategori,
    ikon,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialGoal &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.targetNominal == this.targetNominal &&
          other.terkumpul == this.terkumpul &&
          other.deadline == this.deadline &&
          other.kategori == this.kategori &&
          other.ikon == this.ikon &&
          other.createdAt == this.createdAt);
}

class FinancialGoalsCompanion extends UpdateCompanion<FinancialGoal> {
  final Value<String> id;
  final Value<String> nama;
  final Value<int> targetNominal;
  final Value<int> terkumpul;
  final Value<DateTime?> deadline;
  final Value<String> kategori;
  final Value<String> ikon;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FinancialGoalsCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.targetNominal = const Value.absent(),
    this.terkumpul = const Value.absent(),
    this.deadline = const Value.absent(),
    this.kategori = const Value.absent(),
    this.ikon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialGoalsCompanion.insert({
    required String id,
    required String nama,
    required int targetNominal,
    this.terkumpul = const Value.absent(),
    this.deadline = const Value.absent(),
    this.kategori = const Value.absent(),
    this.ikon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       targetNominal = Value(targetNominal);
  static Insertable<FinancialGoal> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<int>? targetNominal,
    Expression<int>? terkumpul,
    Expression<DateTime>? deadline,
    Expression<String>? kategori,
    Expression<String>? ikon,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (targetNominal != null) 'target_nominal': targetNominal,
      if (terkumpul != null) 'terkumpul': terkumpul,
      if (deadline != null) 'deadline': deadline,
      if (kategori != null) 'kategori': kategori,
      if (ikon != null) 'ikon': ikon,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<int>? targetNominal,
    Value<int>? terkumpul,
    Value<DateTime?>? deadline,
    Value<String>? kategori,
    Value<String>? ikon,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FinancialGoalsCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      targetNominal: targetNominal ?? this.targetNominal,
      terkumpul: terkumpul ?? this.terkumpul,
      deadline: deadline ?? this.deadline,
      kategori: kategori ?? this.kategori,
      ikon: ikon ?? this.ikon,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (targetNominal.present) {
      map['target_nominal'] = Variable<int>(targetNominal.value);
    }
    if (terkumpul.present) {
      map['terkumpul'] = Variable<int>(terkumpul.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (ikon.present) {
      map['ikon'] = Variable<String>(ikon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialGoalsCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('targetNominal: $targetNominal, ')
          ..write('terkumpul: $terkumpul, ')
          ..write('deadline: $deadline, ')
          ..write('kategori: $kategori, ')
          ..write('ikon: $ikon, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetworthHistoryTable extends NetworthHistory
    with TableInfo<$NetworthHistoryTable, NetworthHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetworthHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bulanKeyMeta = const VerificationMeta(
    'bulanKey',
  );
  @override
  late final GeneratedColumn<String> bulanKey = GeneratedColumn<String>(
    'bulan_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAsetMeta = const VerificationMeta(
    'totalAset',
  );
  @override
  late final GeneratedColumn<int> totalAset = GeneratedColumn<int>(
    'total_aset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalLiabilitasMeta = const VerificationMeta(
    'totalLiabilitas',
  );
  @override
  late final GeneratedColumn<int> totalLiabilitas = GeneratedColumn<int>(
    'total_liabilitas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _catatanAsetMeta = const VerificationMeta(
    'catatanAset',
  );
  @override
  late final GeneratedColumn<String> catatanAset = GeneratedColumn<String>(
    'catatan_aset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _catatanLiabilitasMeta = const VerificationMeta(
    'catatanLiabilitas',
  );
  @override
  late final GeneratedColumn<String> catatanLiabilitas =
      GeneratedColumn<String>(
        'catatan_liabilitas',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bulanKey,
    totalAset,
    totalLiabilitas,
    catatanAset,
    catatanLiabilitas,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'networth_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetworthHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bulan_key')) {
      context.handle(
        _bulanKeyMeta,
        bulanKey.isAcceptableOrUnknown(data['bulan_key']!, _bulanKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_bulanKeyMeta);
    }
    if (data.containsKey('total_aset')) {
      context.handle(
        _totalAsetMeta,
        totalAset.isAcceptableOrUnknown(data['total_aset']!, _totalAsetMeta),
      );
    }
    if (data.containsKey('total_liabilitas')) {
      context.handle(
        _totalLiabilitasMeta,
        totalLiabilitas.isAcceptableOrUnknown(
          data['total_liabilitas']!,
          _totalLiabilitasMeta,
        ),
      );
    }
    if (data.containsKey('catatan_aset')) {
      context.handle(
        _catatanAsetMeta,
        catatanAset.isAcceptableOrUnknown(
          data['catatan_aset']!,
          _catatanAsetMeta,
        ),
      );
    }
    if (data.containsKey('catatan_liabilitas')) {
      context.handle(
        _catatanLiabilitasMeta,
        catatanLiabilitas.isAcceptableOrUnknown(
          data['catatan_liabilitas']!,
          _catatanLiabilitasMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetworthHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetworthHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bulanKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bulan_key'],
      )!,
      totalAset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_aset'],
      )!,
      totalLiabilitas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_liabilitas'],
      )!,
      catatanAset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan_aset'],
      )!,
      catatanLiabilitas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan_liabilitas'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $NetworthHistoryTable createAlias(String alias) {
    return $NetworthHistoryTable(attachedDatabase, alias);
  }
}

class NetworthHistoryData extends DataClass
    implements Insertable<NetworthHistoryData> {
  final String id;
  final String bulanKey;
  final int totalAset;
  final int totalLiabilitas;
  final String catatanAset;
  final String catatanLiabilitas;
  final DateTime recordedAt;
  const NetworthHistoryData({
    required this.id,
    required this.bulanKey,
    required this.totalAset,
    required this.totalLiabilitas,
    required this.catatanAset,
    required this.catatanLiabilitas,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bulan_key'] = Variable<String>(bulanKey);
    map['total_aset'] = Variable<int>(totalAset);
    map['total_liabilitas'] = Variable<int>(totalLiabilitas);
    map['catatan_aset'] = Variable<String>(catatanAset);
    map['catatan_liabilitas'] = Variable<String>(catatanLiabilitas);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  NetworthHistoryCompanion toCompanion(bool nullToAbsent) {
    return NetworthHistoryCompanion(
      id: Value(id),
      bulanKey: Value(bulanKey),
      totalAset: Value(totalAset),
      totalLiabilitas: Value(totalLiabilitas),
      catatanAset: Value(catatanAset),
      catatanLiabilitas: Value(catatanLiabilitas),
      recordedAt: Value(recordedAt),
    );
  }

  factory NetworthHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetworthHistoryData(
      id: serializer.fromJson<String>(json['id']),
      bulanKey: serializer.fromJson<String>(json['bulanKey']),
      totalAset: serializer.fromJson<int>(json['totalAset']),
      totalLiabilitas: serializer.fromJson<int>(json['totalLiabilitas']),
      catatanAset: serializer.fromJson<String>(json['catatanAset']),
      catatanLiabilitas: serializer.fromJson<String>(json['catatanLiabilitas']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bulanKey': serializer.toJson<String>(bulanKey),
      'totalAset': serializer.toJson<int>(totalAset),
      'totalLiabilitas': serializer.toJson<int>(totalLiabilitas),
      'catatanAset': serializer.toJson<String>(catatanAset),
      'catatanLiabilitas': serializer.toJson<String>(catatanLiabilitas),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  NetworthHistoryData copyWith({
    String? id,
    String? bulanKey,
    int? totalAset,
    int? totalLiabilitas,
    String? catatanAset,
    String? catatanLiabilitas,
    DateTime? recordedAt,
  }) => NetworthHistoryData(
    id: id ?? this.id,
    bulanKey: bulanKey ?? this.bulanKey,
    totalAset: totalAset ?? this.totalAset,
    totalLiabilitas: totalLiabilitas ?? this.totalLiabilitas,
    catatanAset: catatanAset ?? this.catatanAset,
    catatanLiabilitas: catatanLiabilitas ?? this.catatanLiabilitas,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  NetworthHistoryData copyWithCompanion(NetworthHistoryCompanion data) {
    return NetworthHistoryData(
      id: data.id.present ? data.id.value : this.id,
      bulanKey: data.bulanKey.present ? data.bulanKey.value : this.bulanKey,
      totalAset: data.totalAset.present ? data.totalAset.value : this.totalAset,
      totalLiabilitas: data.totalLiabilitas.present
          ? data.totalLiabilitas.value
          : this.totalLiabilitas,
      catatanAset: data.catatanAset.present
          ? data.catatanAset.value
          : this.catatanAset,
      catatanLiabilitas: data.catatanLiabilitas.present
          ? data.catatanLiabilitas.value
          : this.catatanLiabilitas,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetworthHistoryData(')
          ..write('id: $id, ')
          ..write('bulanKey: $bulanKey, ')
          ..write('totalAset: $totalAset, ')
          ..write('totalLiabilitas: $totalLiabilitas, ')
          ..write('catatanAset: $catatanAset, ')
          ..write('catatanLiabilitas: $catatanLiabilitas, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bulanKey,
    totalAset,
    totalLiabilitas,
    catatanAset,
    catatanLiabilitas,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetworthHistoryData &&
          other.id == this.id &&
          other.bulanKey == this.bulanKey &&
          other.totalAset == this.totalAset &&
          other.totalLiabilitas == this.totalLiabilitas &&
          other.catatanAset == this.catatanAset &&
          other.catatanLiabilitas == this.catatanLiabilitas &&
          other.recordedAt == this.recordedAt);
}

class NetworthHistoryCompanion extends UpdateCompanion<NetworthHistoryData> {
  final Value<String> id;
  final Value<String> bulanKey;
  final Value<int> totalAset;
  final Value<int> totalLiabilitas;
  final Value<String> catatanAset;
  final Value<String> catatanLiabilitas;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const NetworthHistoryCompanion({
    this.id = const Value.absent(),
    this.bulanKey = const Value.absent(),
    this.totalAset = const Value.absent(),
    this.totalLiabilitas = const Value.absent(),
    this.catatanAset = const Value.absent(),
    this.catatanLiabilitas = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetworthHistoryCompanion.insert({
    required String id,
    required String bulanKey,
    this.totalAset = const Value.absent(),
    this.totalLiabilitas = const Value.absent(),
    this.catatanAset = const Value.absent(),
    this.catatanLiabilitas = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bulanKey = Value(bulanKey);
  static Insertable<NetworthHistoryData> custom({
    Expression<String>? id,
    Expression<String>? bulanKey,
    Expression<int>? totalAset,
    Expression<int>? totalLiabilitas,
    Expression<String>? catatanAset,
    Expression<String>? catatanLiabilitas,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bulanKey != null) 'bulan_key': bulanKey,
      if (totalAset != null) 'total_aset': totalAset,
      if (totalLiabilitas != null) 'total_liabilitas': totalLiabilitas,
      if (catatanAset != null) 'catatan_aset': catatanAset,
      if (catatanLiabilitas != null) 'catatan_liabilitas': catatanLiabilitas,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetworthHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? bulanKey,
    Value<int>? totalAset,
    Value<int>? totalLiabilitas,
    Value<String>? catatanAset,
    Value<String>? catatanLiabilitas,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return NetworthHistoryCompanion(
      id: id ?? this.id,
      bulanKey: bulanKey ?? this.bulanKey,
      totalAset: totalAset ?? this.totalAset,
      totalLiabilitas: totalLiabilitas ?? this.totalLiabilitas,
      catatanAset: catatanAset ?? this.catatanAset,
      catatanLiabilitas: catatanLiabilitas ?? this.catatanLiabilitas,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bulanKey.present) {
      map['bulan_key'] = Variable<String>(bulanKey.value);
    }
    if (totalAset.present) {
      map['total_aset'] = Variable<int>(totalAset.value);
    }
    if (totalLiabilitas.present) {
      map['total_liabilitas'] = Variable<int>(totalLiabilitas.value);
    }
    if (catatanAset.present) {
      map['catatan_aset'] = Variable<String>(catatanAset.value);
    }
    if (catatanLiabilitas.present) {
      map['catatan_liabilitas'] = Variable<String>(catatanLiabilitas.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetworthHistoryCompanion(')
          ..write('id: $id, ')
          ..write('bulanKey: $bulanKey, ')
          ..write('totalAset: $totalAset, ')
          ..write('totalLiabilitas: $totalLiabilitas, ')
          ..write('catatanAset: $catatanAset, ')
          ..write('catatanLiabilitas: $catatanLiabilitas, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransaksiTable extends Transaksi
    with TableInfo<$TransaksiTable, TransaksiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sifatMeta = const VerificationMeta('sifat');
  @override
  late final GeneratedColumn<String> sifat = GeneratedColumn<String>(
    'sifat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waktuTransaksiMeta = const VerificationMeta(
    'waktuTransaksi',
  );
  @override
  late final GeneratedColumn<DateTime> waktuTransaksi =
      GeneratedColumn<DateTime>(
        'waktu_transaksi',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catatan,
    nominal,
    kategori,
    sifat,
    walletId,
    waktuTransaksi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaksi';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransaksiData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    } else if (isInserting) {
      context.missing(_catatanMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('sifat')) {
      context.handle(
        _sifatMeta,
        sifat.isAcceptableOrUnknown(data['sifat']!, _sifatMeta),
      );
    } else if (isInserting) {
      context.missing(_sifatMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('waktu_transaksi')) {
      context.handle(
        _waktuTransaksiMeta,
        waktuTransaksi.isAcceptableOrUnknown(
          data['waktu_transaksi']!,
          _waktuTransaksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waktuTransaksiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransaksiData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransaksiData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nominal'],
      )!,
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      sifat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sifat'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      ),
      waktuTransaksi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}waktu_transaksi'],
      )!,
    );
  }

  @override
  $TransaksiTable createAlias(String alias) {
    return $TransaksiTable(attachedDatabase, alias);
  }
}

class TransaksiData extends DataClass implements Insertable<TransaksiData> {
  final String id;
  final String catatan;
  final int nominal;
  final String kategori;
  final String sifat;
  final String? walletId;
  final DateTime waktuTransaksi;
  const TransaksiData({
    required this.id,
    required this.catatan,
    required this.nominal,
    required this.kategori,
    required this.sifat,
    this.walletId,
    required this.waktuTransaksi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['catatan'] = Variable<String>(catatan);
    map['nominal'] = Variable<int>(nominal);
    map['kategori'] = Variable<String>(kategori);
    map['sifat'] = Variable<String>(sifat);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<String>(walletId);
    }
    map['waktu_transaksi'] = Variable<DateTime>(waktuTransaksi);
    return map;
  }

  TransaksiCompanion toCompanion(bool nullToAbsent) {
    return TransaksiCompanion(
      id: Value(id),
      catatan: Value(catatan),
      nominal: Value(nominal),
      kategori: Value(kategori),
      sifat: Value(sifat),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      waktuTransaksi: Value(waktuTransaksi),
    );
  }

  factory TransaksiData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransaksiData(
      id: serializer.fromJson<String>(json['id']),
      catatan: serializer.fromJson<String>(json['catatan']),
      nominal: serializer.fromJson<int>(json['nominal']),
      kategori: serializer.fromJson<String>(json['kategori']),
      sifat: serializer.fromJson<String>(json['sifat']),
      walletId: serializer.fromJson<String?>(json['walletId']),
      waktuTransaksi: serializer.fromJson<DateTime>(json['waktuTransaksi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'catatan': serializer.toJson<String>(catatan),
      'nominal': serializer.toJson<int>(nominal),
      'kategori': serializer.toJson<String>(kategori),
      'sifat': serializer.toJson<String>(sifat),
      'walletId': serializer.toJson<String?>(walletId),
      'waktuTransaksi': serializer.toJson<DateTime>(waktuTransaksi),
    };
  }

  TransaksiData copyWith({
    String? id,
    String? catatan,
    int? nominal,
    String? kategori,
    String? sifat,
    Value<String?> walletId = const Value.absent(),
    DateTime? waktuTransaksi,
  }) => TransaksiData(
    id: id ?? this.id,
    catatan: catatan ?? this.catatan,
    nominal: nominal ?? this.nominal,
    kategori: kategori ?? this.kategori,
    sifat: sifat ?? this.sifat,
    walletId: walletId.present ? walletId.value : this.walletId,
    waktuTransaksi: waktuTransaksi ?? this.waktuTransaksi,
  );
  TransaksiData copyWithCompanion(TransaksiCompanion data) {
    return TransaksiData(
      id: data.id.present ? data.id.value : this.id,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      sifat: data.sifat.present ? data.sifat.value : this.sifat,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      waktuTransaksi: data.waktuTransaksi.present
          ? data.waktuTransaksi.value
          : this.waktuTransaksi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransaksiData(')
          ..write('id: $id, ')
          ..write('catatan: $catatan, ')
          ..write('nominal: $nominal, ')
          ..write('kategori: $kategori, ')
          ..write('sifat: $sifat, ')
          ..write('walletId: $walletId, ')
          ..write('waktuTransaksi: $waktuTransaksi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catatan,
    nominal,
    kategori,
    sifat,
    walletId,
    waktuTransaksi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransaksiData &&
          other.id == this.id &&
          other.catatan == this.catatan &&
          other.nominal == this.nominal &&
          other.kategori == this.kategori &&
          other.sifat == this.sifat &&
          other.walletId == this.walletId &&
          other.waktuTransaksi == this.waktuTransaksi);
}

class TransaksiCompanion extends UpdateCompanion<TransaksiData> {
  final Value<String> id;
  final Value<String> catatan;
  final Value<int> nominal;
  final Value<String> kategori;
  final Value<String> sifat;
  final Value<String?> walletId;
  final Value<DateTime> waktuTransaksi;
  final Value<int> rowid;
  const TransaksiCompanion({
    this.id = const Value.absent(),
    this.catatan = const Value.absent(),
    this.nominal = const Value.absent(),
    this.kategori = const Value.absent(),
    this.sifat = const Value.absent(),
    this.walletId = const Value.absent(),
    this.waktuTransaksi = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransaksiCompanion.insert({
    required String id,
    required String catatan,
    required int nominal,
    required String kategori,
    required String sifat,
    this.walletId = const Value.absent(),
    required DateTime waktuTransaksi,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       catatan = Value(catatan),
       nominal = Value(nominal),
       kategori = Value(kategori),
       sifat = Value(sifat),
       waktuTransaksi = Value(waktuTransaksi);
  static Insertable<TransaksiData> custom({
    Expression<String>? id,
    Expression<String>? catatan,
    Expression<int>? nominal,
    Expression<String>? kategori,
    Expression<String>? sifat,
    Expression<String>? walletId,
    Expression<DateTime>? waktuTransaksi,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catatan != null) 'catatan': catatan,
      if (nominal != null) 'nominal': nominal,
      if (kategori != null) 'kategori': kategori,
      if (sifat != null) 'sifat': sifat,
      if (walletId != null) 'wallet_id': walletId,
      if (waktuTransaksi != null) 'waktu_transaksi': waktuTransaksi,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransaksiCompanion copyWith({
    Value<String>? id,
    Value<String>? catatan,
    Value<int>? nominal,
    Value<String>? kategori,
    Value<String>? sifat,
    Value<String?>? walletId,
    Value<DateTime>? waktuTransaksi,
    Value<int>? rowid,
  }) {
    return TransaksiCompanion(
      id: id ?? this.id,
      catatan: catatan ?? this.catatan,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
      sifat: sifat ?? this.sifat,
      walletId: walletId ?? this.walletId,
      waktuTransaksi: waktuTransaksi ?? this.waktuTransaksi,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (sifat.present) {
      map['sifat'] = Variable<String>(sifat.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (waktuTransaksi.present) {
      map['waktu_transaksi'] = Variable<DateTime>(waktuTransaksi.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaksiCompanion(')
          ..write('id: $id, ')
          ..write('catatan: $catatan, ')
          ..write('nominal: $nominal, ')
          ..write('kategori: $kategori, ')
          ..write('sifat: $sifat, ')
          ..write('walletId: $walletId, ')
          ..write('waktuTransaksi: $waktuTransaksi, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PemasukanTable extends Pemasukan
    with TableInfo<$PemasukanTable, PemasukanData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PemasukanTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sumberMeta = const VerificationMeta('sumber');
  @override
  late final GeneratedColumn<String> sumber = GeneratedColumn<String>(
    'sumber',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waktuPemasukanMeta = const VerificationMeta(
    'waktuPemasukan',
  );
  @override
  late final GeneratedColumn<DateTime> waktuPemasukan =
      GeneratedColumn<DateTime>(
        'waktu_pemasukan',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sumber,
    nominal,
    kategori,
    walletId,
    waktuPemasukan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pemasukan';
  @override
  VerificationContext validateIntegrity(
    Insertable<PemasukanData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sumber')) {
      context.handle(
        _sumberMeta,
        sumber.isAcceptableOrUnknown(data['sumber']!, _sumberMeta),
      );
    } else if (isInserting) {
      context.missing(_sumberMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('waktu_pemasukan')) {
      context.handle(
        _waktuPemasukanMeta,
        waktuPemasukan.isAcceptableOrUnknown(
          data['waktu_pemasukan']!,
          _waktuPemasukanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waktuPemasukanMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PemasukanData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PemasukanData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sumber'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nominal'],
      )!,
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      ),
      waktuPemasukan: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}waktu_pemasukan'],
      )!,
    );
  }

  @override
  $PemasukanTable createAlias(String alias) {
    return $PemasukanTable(attachedDatabase, alias);
  }
}

class PemasukanData extends DataClass implements Insertable<PemasukanData> {
  final String id;
  final String sumber;
  final int nominal;
  final String kategori;
  final String? walletId;
  final DateTime waktuPemasukan;
  const PemasukanData({
    required this.id,
    required this.sumber,
    required this.nominal,
    required this.kategori,
    this.walletId,
    required this.waktuPemasukan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sumber'] = Variable<String>(sumber);
    map['nominal'] = Variable<int>(nominal);
    map['kategori'] = Variable<String>(kategori);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<String>(walletId);
    }
    map['waktu_pemasukan'] = Variable<DateTime>(waktuPemasukan);
    return map;
  }

  PemasukanCompanion toCompanion(bool nullToAbsent) {
    return PemasukanCompanion(
      id: Value(id),
      sumber: Value(sumber),
      nominal: Value(nominal),
      kategori: Value(kategori),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      waktuPemasukan: Value(waktuPemasukan),
    );
  }

  factory PemasukanData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PemasukanData(
      id: serializer.fromJson<String>(json['id']),
      sumber: serializer.fromJson<String>(json['sumber']),
      nominal: serializer.fromJson<int>(json['nominal']),
      kategori: serializer.fromJson<String>(json['kategori']),
      walletId: serializer.fromJson<String?>(json['walletId']),
      waktuPemasukan: serializer.fromJson<DateTime>(json['waktuPemasukan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sumber': serializer.toJson<String>(sumber),
      'nominal': serializer.toJson<int>(nominal),
      'kategori': serializer.toJson<String>(kategori),
      'walletId': serializer.toJson<String?>(walletId),
      'waktuPemasukan': serializer.toJson<DateTime>(waktuPemasukan),
    };
  }

  PemasukanData copyWith({
    String? id,
    String? sumber,
    int? nominal,
    String? kategori,
    Value<String?> walletId = const Value.absent(),
    DateTime? waktuPemasukan,
  }) => PemasukanData(
    id: id ?? this.id,
    sumber: sumber ?? this.sumber,
    nominal: nominal ?? this.nominal,
    kategori: kategori ?? this.kategori,
    walletId: walletId.present ? walletId.value : this.walletId,
    waktuPemasukan: waktuPemasukan ?? this.waktuPemasukan,
  );
  PemasukanData copyWithCompanion(PemasukanCompanion data) {
    return PemasukanData(
      id: data.id.present ? data.id.value : this.id,
      sumber: data.sumber.present ? data.sumber.value : this.sumber,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      waktuPemasukan: data.waktuPemasukan.present
          ? data.waktuPemasukan.value
          : this.waktuPemasukan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PemasukanData(')
          ..write('id: $id, ')
          ..write('sumber: $sumber, ')
          ..write('nominal: $nominal, ')
          ..write('kategori: $kategori, ')
          ..write('walletId: $walletId, ')
          ..write('waktuPemasukan: $waktuPemasukan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sumber, nominal, kategori, walletId, waktuPemasukan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PemasukanData &&
          other.id == this.id &&
          other.sumber == this.sumber &&
          other.nominal == this.nominal &&
          other.kategori == this.kategori &&
          other.walletId == this.walletId &&
          other.waktuPemasukan == this.waktuPemasukan);
}

class PemasukanCompanion extends UpdateCompanion<PemasukanData> {
  final Value<String> id;
  final Value<String> sumber;
  final Value<int> nominal;
  final Value<String> kategori;
  final Value<String?> walletId;
  final Value<DateTime> waktuPemasukan;
  final Value<int> rowid;
  const PemasukanCompanion({
    this.id = const Value.absent(),
    this.sumber = const Value.absent(),
    this.nominal = const Value.absent(),
    this.kategori = const Value.absent(),
    this.walletId = const Value.absent(),
    this.waktuPemasukan = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PemasukanCompanion.insert({
    required String id,
    required String sumber,
    required int nominal,
    required String kategori,
    this.walletId = const Value.absent(),
    required DateTime waktuPemasukan,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sumber = Value(sumber),
       nominal = Value(nominal),
       kategori = Value(kategori),
       waktuPemasukan = Value(waktuPemasukan);
  static Insertable<PemasukanData> custom({
    Expression<String>? id,
    Expression<String>? sumber,
    Expression<int>? nominal,
    Expression<String>? kategori,
    Expression<String>? walletId,
    Expression<DateTime>? waktuPemasukan,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sumber != null) 'sumber': sumber,
      if (nominal != null) 'nominal': nominal,
      if (kategori != null) 'kategori': kategori,
      if (walletId != null) 'wallet_id': walletId,
      if (waktuPemasukan != null) 'waktu_pemasukan': waktuPemasukan,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PemasukanCompanion copyWith({
    Value<String>? id,
    Value<String>? sumber,
    Value<int>? nominal,
    Value<String>? kategori,
    Value<String?>? walletId,
    Value<DateTime>? waktuPemasukan,
    Value<int>? rowid,
  }) {
    return PemasukanCompanion(
      id: id ?? this.id,
      sumber: sumber ?? this.sumber,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
      walletId: walletId ?? this.walletId,
      waktuPemasukan: waktuPemasukan ?? this.waktuPemasukan,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sumber.present) {
      map['sumber'] = Variable<String>(sumber.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (waktuPemasukan.present) {
      map['waktu_pemasukan'] = Variable<DateTime>(waktuPemasukan.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PemasukanCompanion(')
          ..write('id: $id, ')
          ..write('sumber: $sumber, ')
          ..write('nominal: $nominal, ')
          ..write('kategori: $kategori, ')
          ..write('walletId: $walletId, ')
          ..write('waktuPemasukan: $waktuPemasukan, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HutangPiutangTable extends HutangPiutang
    with TableInfo<$HutangPiutangTable, HutangPiutangData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HutangPiutangTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
    'tipe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('belum'),
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipe,
    nama,
    nominal,
    status,
    tanggal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hutang_piutang';
  @override
  VerificationContext validateIntegrity(
    Insertable<HutangPiutangData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
        _tipeMeta,
        tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HutangPiutangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HutangPiutangData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipe'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nominal'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
    );
  }

  @override
  $HutangPiutangTable createAlias(String alias) {
    return $HutangPiutangTable(attachedDatabase, alias);
  }
}

class HutangPiutangData extends DataClass
    implements Insertable<HutangPiutangData> {
  final String id;
  final String tipe;
  final String nama;
  final int nominal;
  final String status;
  final DateTime tanggal;
  const HutangPiutangData({
    required this.id,
    required this.tipe,
    required this.nama,
    required this.nominal,
    required this.status,
    required this.tanggal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tipe'] = Variable<String>(tipe);
    map['nama'] = Variable<String>(nama);
    map['nominal'] = Variable<int>(nominal);
    map['status'] = Variable<String>(status);
    map['tanggal'] = Variable<DateTime>(tanggal);
    return map;
  }

  HutangPiutangCompanion toCompanion(bool nullToAbsent) {
    return HutangPiutangCompanion(
      id: Value(id),
      tipe: Value(tipe),
      nama: Value(nama),
      nominal: Value(nominal),
      status: Value(status),
      tanggal: Value(tanggal),
    );
  }

  factory HutangPiutangData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HutangPiutangData(
      id: serializer.fromJson<String>(json['id']),
      tipe: serializer.fromJson<String>(json['tipe']),
      nama: serializer.fromJson<String>(json['nama']),
      nominal: serializer.fromJson<int>(json['nominal']),
      status: serializer.fromJson<String>(json['status']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tipe': serializer.toJson<String>(tipe),
      'nama': serializer.toJson<String>(nama),
      'nominal': serializer.toJson<int>(nominal),
      'status': serializer.toJson<String>(status),
      'tanggal': serializer.toJson<DateTime>(tanggal),
    };
  }

  HutangPiutangData copyWith({
    String? id,
    String? tipe,
    String? nama,
    int? nominal,
    String? status,
    DateTime? tanggal,
  }) => HutangPiutangData(
    id: id ?? this.id,
    tipe: tipe ?? this.tipe,
    nama: nama ?? this.nama,
    nominal: nominal ?? this.nominal,
    status: status ?? this.status,
    tanggal: tanggal ?? this.tanggal,
  );
  HutangPiutangData copyWithCompanion(HutangPiutangCompanion data) {
    return HutangPiutangData(
      id: data.id.present ? data.id.value : this.id,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      nama: data.nama.present ? data.nama.value : this.nama,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
      status: data.status.present ? data.status.value : this.status,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HutangPiutangData(')
          ..write('id: $id, ')
          ..write('tipe: $tipe, ')
          ..write('nama: $nama, ')
          ..write('nominal: $nominal, ')
          ..write('status: $status, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tipe, nama, nominal, status, tanggal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HutangPiutangData &&
          other.id == this.id &&
          other.tipe == this.tipe &&
          other.nama == this.nama &&
          other.nominal == this.nominal &&
          other.status == this.status &&
          other.tanggal == this.tanggal);
}

class HutangPiutangCompanion extends UpdateCompanion<HutangPiutangData> {
  final Value<String> id;
  final Value<String> tipe;
  final Value<String> nama;
  final Value<int> nominal;
  final Value<String> status;
  final Value<DateTime> tanggal;
  final Value<int> rowid;
  const HutangPiutangCompanion({
    this.id = const Value.absent(),
    this.tipe = const Value.absent(),
    this.nama = const Value.absent(),
    this.nominal = const Value.absent(),
    this.status = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HutangPiutangCompanion.insert({
    required String id,
    required String tipe,
    required String nama,
    required int nominal,
    this.status = const Value.absent(),
    required DateTime tanggal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tipe = Value(tipe),
       nama = Value(nama),
       nominal = Value(nominal),
       tanggal = Value(tanggal);
  static Insertable<HutangPiutangData> custom({
    Expression<String>? id,
    Expression<String>? tipe,
    Expression<String>? nama,
    Expression<int>? nominal,
    Expression<String>? status,
    Expression<DateTime>? tanggal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipe != null) 'tipe': tipe,
      if (nama != null) 'nama': nama,
      if (nominal != null) 'nominal': nominal,
      if (status != null) 'status': status,
      if (tanggal != null) 'tanggal': tanggal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HutangPiutangCompanion copyWith({
    Value<String>? id,
    Value<String>? tipe,
    Value<String>? nama,
    Value<int>? nominal,
    Value<String>? status,
    Value<DateTime>? tanggal,
    Value<int>? rowid,
  }) {
    return HutangPiutangCompanion(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      nama: nama ?? this.nama,
      nominal: nominal ?? this.nominal,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HutangPiutangCompanion(')
          ..write('id: $id, ')
          ..write('tipe: $tipe, ')
          ..write('nama: $nama, ')
          ..write('nominal: $nominal, ')
          ..write('status: $status, ')
          ..write('tanggal: $tanggal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTemplatesTable extends RecurringTemplates
    with TableInfo<$RecurringTemplatesTable, RecurringTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sifatMeta = const VerificationMeta('sifat');
  @override
  late final GeneratedColumn<String> sifat = GeneratedColumn<String>(
    'sifat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frekuensiMeta = const VerificationMeta(
    'frekuensi',
  );
  @override
  late final GeneratedColumn<String> frekuensi = GeneratedColumn<String>(
    'frekuensi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catatan,
    nominal,
    kategori,
    sifat,
    frekuensi,
    walletId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    } else if (isInserting) {
      context.missing(_catatanMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('sifat')) {
      context.handle(
        _sifatMeta,
        sifat.isAcceptableOrUnknown(data['sifat']!, _sifatMeta),
      );
    } else if (isInserting) {
      context.missing(_sifatMeta);
    }
    if (data.containsKey('frekuensi')) {
      context.handle(
        _frekuensiMeta,
        frekuensi.isAcceptableOrUnknown(data['frekuensi']!, _frekuensiMeta),
      );
    } else if (isInserting) {
      context.missing(_frekuensiMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nominal'],
      )!,
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      sifat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sifat'],
      )!,
      frekuensi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frekuensi'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      ),
    );
  }

  @override
  $RecurringTemplatesTable createAlias(String alias) {
    return $RecurringTemplatesTable(attachedDatabase, alias);
  }
}

class RecurringTemplate extends DataClass
    implements Insertable<RecurringTemplate> {
  final String id;
  final String catatan;
  final int nominal;
  final String kategori;
  final String sifat;
  final String frekuensi;
  final String? walletId;
  const RecurringTemplate({
    required this.id,
    required this.catatan,
    required this.nominal,
    required this.kategori,
    required this.sifat,
    required this.frekuensi,
    this.walletId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['catatan'] = Variable<String>(catatan);
    map['nominal'] = Variable<int>(nominal);
    map['kategori'] = Variable<String>(kategori);
    map['sifat'] = Variable<String>(sifat);
    map['frekuensi'] = Variable<String>(frekuensi);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<String>(walletId);
    }
    return map;
  }

  RecurringTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTemplatesCompanion(
      id: Value(id),
      catatan: Value(catatan),
      nominal: Value(nominal),
      kategori: Value(kategori),
      sifat: Value(sifat),
      frekuensi: Value(frekuensi),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
    );
  }

  factory RecurringTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTemplate(
      id: serializer.fromJson<String>(json['id']),
      catatan: serializer.fromJson<String>(json['catatan']),
      nominal: serializer.fromJson<int>(json['nominal']),
      kategori: serializer.fromJson<String>(json['kategori']),
      sifat: serializer.fromJson<String>(json['sifat']),
      frekuensi: serializer.fromJson<String>(json['frekuensi']),
      walletId: serializer.fromJson<String?>(json['walletId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'catatan': serializer.toJson<String>(catatan),
      'nominal': serializer.toJson<int>(nominal),
      'kategori': serializer.toJson<String>(kategori),
      'sifat': serializer.toJson<String>(sifat),
      'frekuensi': serializer.toJson<String>(frekuensi),
      'walletId': serializer.toJson<String?>(walletId),
    };
  }

  RecurringTemplate copyWith({
    String? id,
    String? catatan,
    int? nominal,
    String? kategori,
    String? sifat,
    String? frekuensi,
    Value<String?> walletId = const Value.absent(),
  }) => RecurringTemplate(
    id: id ?? this.id,
    catatan: catatan ?? this.catatan,
    nominal: nominal ?? this.nominal,
    kategori: kategori ?? this.kategori,
    sifat: sifat ?? this.sifat,
    frekuensi: frekuensi ?? this.frekuensi,
    walletId: walletId.present ? walletId.value : this.walletId,
  );
  RecurringTemplate copyWithCompanion(RecurringTemplatesCompanion data) {
    return RecurringTemplate(
      id: data.id.present ? data.id.value : this.id,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      sifat: data.sifat.present ? data.sifat.value : this.sifat,
      frekuensi: data.frekuensi.present ? data.frekuensi.value : this.frekuensi,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplate(')
          ..write('id: $id, ')
          ..write('catatan: $catatan, ')
          ..write('nominal: $nominal, ')
          ..write('kategori: $kategori, ')
          ..write('sifat: $sifat, ')
          ..write('frekuensi: $frekuensi, ')
          ..write('walletId: $walletId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catatan, nominal, kategori, sifat, frekuensi, walletId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTemplate &&
          other.id == this.id &&
          other.catatan == this.catatan &&
          other.nominal == this.nominal &&
          other.kategori == this.kategori &&
          other.sifat == this.sifat &&
          other.frekuensi == this.frekuensi &&
          other.walletId == this.walletId);
}

class RecurringTemplatesCompanion extends UpdateCompanion<RecurringTemplate> {
  final Value<String> id;
  final Value<String> catatan;
  final Value<int> nominal;
  final Value<String> kategori;
  final Value<String> sifat;
  final Value<String> frekuensi;
  final Value<String?> walletId;
  final Value<int> rowid;
  const RecurringTemplatesCompanion({
    this.id = const Value.absent(),
    this.catatan = const Value.absent(),
    this.nominal = const Value.absent(),
    this.kategori = const Value.absent(),
    this.sifat = const Value.absent(),
    this.frekuensi = const Value.absent(),
    this.walletId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTemplatesCompanion.insert({
    required String id,
    required String catatan,
    required int nominal,
    required String kategori,
    required String sifat,
    required String frekuensi,
    this.walletId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       catatan = Value(catatan),
       nominal = Value(nominal),
       kategori = Value(kategori),
       sifat = Value(sifat),
       frekuensi = Value(frekuensi);
  static Insertable<RecurringTemplate> custom({
    Expression<String>? id,
    Expression<String>? catatan,
    Expression<int>? nominal,
    Expression<String>? kategori,
    Expression<String>? sifat,
    Expression<String>? frekuensi,
    Expression<String>? walletId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catatan != null) 'catatan': catatan,
      if (nominal != null) 'nominal': nominal,
      if (kategori != null) 'kategori': kategori,
      if (sifat != null) 'sifat': sifat,
      if (frekuensi != null) 'frekuensi': frekuensi,
      if (walletId != null) 'wallet_id': walletId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? catatan,
    Value<int>? nominal,
    Value<String>? kategori,
    Value<String>? sifat,
    Value<String>? frekuensi,
    Value<String?>? walletId,
    Value<int>? rowid,
  }) {
    return RecurringTemplatesCompanion(
      id: id ?? this.id,
      catatan: catatan ?? this.catatan,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
      sifat: sifat ?? this.sifat,
      frekuensi: frekuensi ?? this.frekuensi,
      walletId: walletId ?? this.walletId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (sifat.present) {
      map['sifat'] = Variable<String>(sifat.value);
    }
    if (frekuensi.present) {
      map['frekuensi'] = Variable<String>(frekuensi.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('catatan: $catatan, ')
          ..write('nominal: $nominal, ')
          ..write('kategori: $kategori, ')
          ..write('sifat: $sifat, ')
          ..write('frekuensi: $frekuensi, ')
          ..write('walletId: $walletId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $BudgetKategoriTable budgetKategori = $BudgetKategoriTable(this);
  late final $CustomKategoriTable customKategori = $CustomKategoriTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $FinancialGoalsTable financialGoals = $FinancialGoalsTable(this);
  late final $NetworthHistoryTable networthHistory = $NetworthHistoryTable(
    this,
  );
  late final $TransaksiTable transaksi = $TransaksiTable(this);
  late final $PemasukanTable pemasukan = $PemasukanTable(this);
  late final $HutangPiutangTable hutangPiutang = $HutangPiutangTable(this);
  late final $RecurringTemplatesTable recurringTemplates =
      $RecurringTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    budgets,
    savingsGoals,
    budgetKategori,
    customKategori,
    wallets,
    financialGoals,
    networthHistory,
    transaksi,
    pemasukan,
    hutangPiutang,
    recurringTemplates,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String?> nama,
      Value<String?> lokasi,
      Value<String?> fotoPath,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String?> nama,
      Value<String?> lokasi,
      Value<String?> fotoPath,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lokasi => $composableBuilder(
    column: $table.lokasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lokasi => $composableBuilder(
    column: $table.lokasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get lokasi =>
      $composableBuilder(column: $table.lokasi, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> nama = const Value.absent(),
                Value<String?> lokasi = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                nama: nama,
                lokasi: lokasi,
                fotoPath: fotoPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> nama = const Value.absent(),
                Value<String?> lokasi = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                nama: nama,
                lokasi: lokasi,
                fotoPath: fotoPath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String bulanKey,
      required int nominal,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> bulanKey,
      Value<int> nominal,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bulanKey =>
      $composableBuilder(column: $table.bulanKey, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bulanKey = const Value.absent(),
                Value<int> nominal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                bulanKey: bulanKey,
                nominal: nominal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bulanKey,
                required int nominal,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                bulanKey: bulanKey,
                nominal: nominal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      required String bulanKey,
      required int targetNominal,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<String> bulanKey,
      Value<int> targetNominal,
      Value<int> rowid,
    });

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetNominal => $composableBuilder(
    column: $table.targetNominal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetNominal => $composableBuilder(
    column: $table.targetNominal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bulanKey =>
      $composableBuilder(column: $table.bulanKey, builder: (column) => column);

  GeneratedColumn<int> get targetNominal => $composableBuilder(
    column: $table.targetNominal,
    builder: (column) => column,
  );
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoal,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (
            SavingsGoal,
            BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
          ),
          SavingsGoal,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bulanKey = const Value.absent(),
                Value<int> targetNominal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                bulanKey: bulanKey,
                targetNominal: targetNominal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bulanKey,
                required int targetNominal,
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                bulanKey: bulanKey,
                targetNominal: targetNominal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoal,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (
        SavingsGoal,
        BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
      ),
      SavingsGoal,
      PrefetchHooks Function()
    >;
typedef $$BudgetKategoriTableCreateCompanionBuilder =
    BudgetKategoriCompanion Function({
      Value<int> id,
      required String bulanKey,
      required String kategori,
      required int nominal,
    });
typedef $$BudgetKategoriTableUpdateCompanionBuilder =
    BudgetKategoriCompanion Function({
      Value<int> id,
      Value<String> bulanKey,
      Value<String> kategori,
      Value<int> nominal,
    });

class $$BudgetKategoriTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetKategoriTable> {
  $$BudgetKategoriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetKategoriTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetKategoriTable> {
  $$BudgetKategoriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetKategoriTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetKategoriTable> {
  $$BudgetKategoriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bulanKey =>
      $composableBuilder(column: $table.bulanKey, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);
}

class $$BudgetKategoriTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetKategoriTable,
          BudgetKategoriData,
          $$BudgetKategoriTableFilterComposer,
          $$BudgetKategoriTableOrderingComposer,
          $$BudgetKategoriTableAnnotationComposer,
          $$BudgetKategoriTableCreateCompanionBuilder,
          $$BudgetKategoriTableUpdateCompanionBuilder,
          (
            BudgetKategoriData,
            BaseReferences<
              _$AppDatabase,
              $BudgetKategoriTable,
              BudgetKategoriData
            >,
          ),
          BudgetKategoriData,
          PrefetchHooks Function()
        > {
  $$BudgetKategoriTableTableManager(
    _$AppDatabase db,
    $BudgetKategoriTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetKategoriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetKategoriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetKategoriTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bulanKey = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<int> nominal = const Value.absent(),
              }) => BudgetKategoriCompanion(
                id: id,
                bulanKey: bulanKey,
                kategori: kategori,
                nominal: nominal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bulanKey,
                required String kategori,
                required int nominal,
              }) => BudgetKategoriCompanion.insert(
                id: id,
                bulanKey: bulanKey,
                kategori: kategori,
                nominal: nominal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetKategoriTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetKategoriTable,
      BudgetKategoriData,
      $$BudgetKategoriTableFilterComposer,
      $$BudgetKategoriTableOrderingComposer,
      $$BudgetKategoriTableAnnotationComposer,
      $$BudgetKategoriTableCreateCompanionBuilder,
      $$BudgetKategoriTableUpdateCompanionBuilder,
      (
        BudgetKategoriData,
        BaseReferences<_$AppDatabase, $BudgetKategoriTable, BudgetKategoriData>,
      ),
      BudgetKategoriData,
      PrefetchHooks Function()
    >;
typedef $$CustomKategoriTableCreateCompanionBuilder =
    CustomKategoriCompanion Function({
      required String id,
      required String nama,
      required String tipe,
      Value<String> ikon,
      Value<int> rowid,
    });
typedef $$CustomKategoriTableUpdateCompanionBuilder =
    CustomKategoriCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> tipe,
      Value<String> ikon,
      Value<int> rowid,
    });

class $$CustomKategoriTableFilterComposer
    extends Composer<_$AppDatabase, $CustomKategoriTable> {
  $$CustomKategoriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomKategoriTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomKategoriTable> {
  $$CustomKategoriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomKategoriTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomKategoriTable> {
  $$CustomKategoriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<String> get ikon =>
      $composableBuilder(column: $table.ikon, builder: (column) => column);
}

class $$CustomKategoriTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomKategoriTable,
          CustomKategoriData,
          $$CustomKategoriTableFilterComposer,
          $$CustomKategoriTableOrderingComposer,
          $$CustomKategoriTableAnnotationComposer,
          $$CustomKategoriTableCreateCompanionBuilder,
          $$CustomKategoriTableUpdateCompanionBuilder,
          (
            CustomKategoriData,
            BaseReferences<
              _$AppDatabase,
              $CustomKategoriTable,
              CustomKategoriData
            >,
          ),
          CustomKategoriData,
          PrefetchHooks Function()
        > {
  $$CustomKategoriTableTableManager(
    _$AppDatabase db,
    $CustomKategoriTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomKategoriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomKategoriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomKategoriTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> tipe = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomKategoriCompanion(
                id: id,
                nama: nama,
                tipe: tipe,
                ikon: ikon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String tipe,
                Value<String> ikon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomKategoriCompanion.insert(
                id: id,
                nama: nama,
                tipe: tipe,
                ikon: ikon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomKategoriTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomKategoriTable,
      CustomKategoriData,
      $$CustomKategoriTableFilterComposer,
      $$CustomKategoriTableOrderingComposer,
      $$CustomKategoriTableAnnotationComposer,
      $$CustomKategoriTableCreateCompanionBuilder,
      $$CustomKategoriTableUpdateCompanionBuilder,
      (
        CustomKategoriData,
        BaseReferences<_$AppDatabase, $CustomKategoriTable, CustomKategoriData>,
      ),
      CustomKategoriData,
      PrefetchHooks Function()
    >;
typedef $$WalletsTableCreateCompanionBuilder =
    WalletsCompanion Function({
      required String id,
      required String nama,
      required String tipe,
      Value<int> saldoAwal,
      Value<String> warna,
      Value<int> rowid,
    });
typedef $$WalletsTableUpdateCompanionBuilder =
    WalletsCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> tipe,
      Value<int> saldoAwal,
      Value<String> warna,
      Value<int> rowid,
    });

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saldoAwal => $composableBuilder(
    column: $table.saldoAwal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warna => $composableBuilder(
    column: $table.warna,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoAwal => $composableBuilder(
    column: $table.saldoAwal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warna => $composableBuilder(
    column: $table.warna,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<int> get saldoAwal =>
      $composableBuilder(column: $table.saldoAwal, builder: (column) => column);

  GeneratedColumn<String> get warna =>
      $composableBuilder(column: $table.warna, builder: (column) => column);
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          Wallet,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (Wallet, BaseReferences<_$AppDatabase, $WalletsTable, Wallet>),
          Wallet,
          PrefetchHooks Function()
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> tipe = const Value.absent(),
                Value<int> saldoAwal = const Value.absent(),
                Value<String> warna = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletsCompanion(
                id: id,
                nama: nama,
                tipe: tipe,
                saldoAwal: saldoAwal,
                warna: warna,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String tipe,
                Value<int> saldoAwal = const Value.absent(),
                Value<String> warna = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletsCompanion.insert(
                id: id,
                nama: nama,
                tipe: tipe,
                saldoAwal: saldoAwal,
                warna: warna,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      Wallet,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (Wallet, BaseReferences<_$AppDatabase, $WalletsTable, Wallet>),
      Wallet,
      PrefetchHooks Function()
    >;
typedef $$FinancialGoalsTableCreateCompanionBuilder =
    FinancialGoalsCompanion Function({
      required String id,
      required String nama,
      required int targetNominal,
      Value<int> terkumpul,
      Value<DateTime?> deadline,
      Value<String> kategori,
      Value<String> ikon,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$FinancialGoalsTableUpdateCompanionBuilder =
    FinancialGoalsCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<int> targetNominal,
      Value<int> terkumpul,
      Value<DateTime?> deadline,
      Value<String> kategori,
      Value<String> ikon,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FinancialGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialGoalsTable> {
  $$FinancialGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetNominal => $composableBuilder(
    column: $table.targetNominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get terkumpul => $composableBuilder(
    column: $table.terkumpul,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancialGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialGoalsTable> {
  $$FinancialGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetNominal => $composableBuilder(
    column: $table.targetNominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get terkumpul => $composableBuilder(
    column: $table.terkumpul,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ikon => $composableBuilder(
    column: $table.ikon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancialGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialGoalsTable> {
  $$FinancialGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<int> get targetNominal => $composableBuilder(
    column: $table.targetNominal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get terkumpul =>
      $composableBuilder(column: $table.terkumpul, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<String> get ikon =>
      $composableBuilder(column: $table.ikon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FinancialGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancialGoalsTable,
          FinancialGoal,
          $$FinancialGoalsTableFilterComposer,
          $$FinancialGoalsTableOrderingComposer,
          $$FinancialGoalsTableAnnotationComposer,
          $$FinancialGoalsTableCreateCompanionBuilder,
          $$FinancialGoalsTableUpdateCompanionBuilder,
          (
            FinancialGoal,
            BaseReferences<_$AppDatabase, $FinancialGoalsTable, FinancialGoal>,
          ),
          FinancialGoal,
          PrefetchHooks Function()
        > {
  $$FinancialGoalsTableTableManager(
    _$AppDatabase db,
    $FinancialGoalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<int> targetNominal = const Value.absent(),
                Value<int> terkumpul = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialGoalsCompanion(
                id: id,
                nama: nama,
                targetNominal: targetNominal,
                terkumpul: terkumpul,
                deadline: deadline,
                kategori: kategori,
                ikon: ikon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required int targetNominal,
                Value<int> terkumpul = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<String> ikon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialGoalsCompanion.insert(
                id: id,
                nama: nama,
                targetNominal: targetNominal,
                terkumpul: terkumpul,
                deadline: deadline,
                kategori: kategori,
                ikon: ikon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancialGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancialGoalsTable,
      FinancialGoal,
      $$FinancialGoalsTableFilterComposer,
      $$FinancialGoalsTableOrderingComposer,
      $$FinancialGoalsTableAnnotationComposer,
      $$FinancialGoalsTableCreateCompanionBuilder,
      $$FinancialGoalsTableUpdateCompanionBuilder,
      (
        FinancialGoal,
        BaseReferences<_$AppDatabase, $FinancialGoalsTable, FinancialGoal>,
      ),
      FinancialGoal,
      PrefetchHooks Function()
    >;
typedef $$NetworthHistoryTableCreateCompanionBuilder =
    NetworthHistoryCompanion Function({
      required String id,
      required String bulanKey,
      Value<int> totalAset,
      Value<int> totalLiabilitas,
      Value<String> catatanAset,
      Value<String> catatanLiabilitas,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });
typedef $$NetworthHistoryTableUpdateCompanionBuilder =
    NetworthHistoryCompanion Function({
      Value<String> id,
      Value<String> bulanKey,
      Value<int> totalAset,
      Value<int> totalLiabilitas,
      Value<String> catatanAset,
      Value<String> catatanLiabilitas,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$NetworthHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $NetworthHistoryTable> {
  $$NetworthHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAset => $composableBuilder(
    column: $table.totalAset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalLiabilitas => $composableBuilder(
    column: $table.totalLiabilitas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatanAset => $composableBuilder(
    column: $table.catatanAset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatanLiabilitas => $composableBuilder(
    column: $table.catatanLiabilitas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NetworthHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $NetworthHistoryTable> {
  $$NetworthHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bulanKey => $composableBuilder(
    column: $table.bulanKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAset => $composableBuilder(
    column: $table.totalAset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalLiabilitas => $composableBuilder(
    column: $table.totalLiabilitas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatanAset => $composableBuilder(
    column: $table.catatanAset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatanLiabilitas => $composableBuilder(
    column: $table.catatanLiabilitas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NetworthHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetworthHistoryTable> {
  $$NetworthHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bulanKey =>
      $composableBuilder(column: $table.bulanKey, builder: (column) => column);

  GeneratedColumn<int> get totalAset =>
      $composableBuilder(column: $table.totalAset, builder: (column) => column);

  GeneratedColumn<int> get totalLiabilitas => $composableBuilder(
    column: $table.totalLiabilitas,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatanAset => $composableBuilder(
    column: $table.catatanAset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatanLiabilitas => $composableBuilder(
    column: $table.catatanLiabilitas,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$NetworthHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NetworthHistoryTable,
          NetworthHistoryData,
          $$NetworthHistoryTableFilterComposer,
          $$NetworthHistoryTableOrderingComposer,
          $$NetworthHistoryTableAnnotationComposer,
          $$NetworthHistoryTableCreateCompanionBuilder,
          $$NetworthHistoryTableUpdateCompanionBuilder,
          (
            NetworthHistoryData,
            BaseReferences<
              _$AppDatabase,
              $NetworthHistoryTable,
              NetworthHistoryData
            >,
          ),
          NetworthHistoryData,
          PrefetchHooks Function()
        > {
  $$NetworthHistoryTableTableManager(
    _$AppDatabase db,
    $NetworthHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetworthHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetworthHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetworthHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bulanKey = const Value.absent(),
                Value<int> totalAset = const Value.absent(),
                Value<int> totalLiabilitas = const Value.absent(),
                Value<String> catatanAset = const Value.absent(),
                Value<String> catatanLiabilitas = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetworthHistoryCompanion(
                id: id,
                bulanKey: bulanKey,
                totalAset: totalAset,
                totalLiabilitas: totalLiabilitas,
                catatanAset: catatanAset,
                catatanLiabilitas: catatanLiabilitas,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bulanKey,
                Value<int> totalAset = const Value.absent(),
                Value<int> totalLiabilitas = const Value.absent(),
                Value<String> catatanAset = const Value.absent(),
                Value<String> catatanLiabilitas = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetworthHistoryCompanion.insert(
                id: id,
                bulanKey: bulanKey,
                totalAset: totalAset,
                totalLiabilitas: totalLiabilitas,
                catatanAset: catatanAset,
                catatanLiabilitas: catatanLiabilitas,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NetworthHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NetworthHistoryTable,
      NetworthHistoryData,
      $$NetworthHistoryTableFilterComposer,
      $$NetworthHistoryTableOrderingComposer,
      $$NetworthHistoryTableAnnotationComposer,
      $$NetworthHistoryTableCreateCompanionBuilder,
      $$NetworthHistoryTableUpdateCompanionBuilder,
      (
        NetworthHistoryData,
        BaseReferences<
          _$AppDatabase,
          $NetworthHistoryTable,
          NetworthHistoryData
        >,
      ),
      NetworthHistoryData,
      PrefetchHooks Function()
    >;
typedef $$TransaksiTableCreateCompanionBuilder =
    TransaksiCompanion Function({
      required String id,
      required String catatan,
      required int nominal,
      required String kategori,
      required String sifat,
      Value<String?> walletId,
      required DateTime waktuTransaksi,
      Value<int> rowid,
    });
typedef $$TransaksiTableUpdateCompanionBuilder =
    TransaksiCompanion Function({
      Value<String> id,
      Value<String> catatan,
      Value<int> nominal,
      Value<String> kategori,
      Value<String> sifat,
      Value<String?> walletId,
      Value<DateTime> waktuTransaksi,
      Value<int> rowid,
    });

class $$TransaksiTableFilterComposer
    extends Composer<_$AppDatabase, $TransaksiTable> {
  $$TransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sifat => $composableBuilder(
    column: $table.sifat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get waktuTransaksi => $composableBuilder(
    column: $table.waktuTransaksi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransaksiTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaksiTable> {
  $$TransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sifat => $composableBuilder(
    column: $table.sifat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get waktuTransaksi => $composableBuilder(
    column: $table.waktuTransaksi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransaksiTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaksiTable> {
  $$TransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<String> get sifat =>
      $composableBuilder(column: $table.sifat, builder: (column) => column);

  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<DateTime> get waktuTransaksi => $composableBuilder(
    column: $table.waktuTransaksi,
    builder: (column) => column,
  );
}

class $$TransaksiTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaksiTable,
          TransaksiData,
          $$TransaksiTableFilterComposer,
          $$TransaksiTableOrderingComposer,
          $$TransaksiTableAnnotationComposer,
          $$TransaksiTableCreateCompanionBuilder,
          $$TransaksiTableUpdateCompanionBuilder,
          (
            TransaksiData,
            BaseReferences<_$AppDatabase, $TransaksiTable, TransaksiData>,
          ),
          TransaksiData,
          PrefetchHooks Function()
        > {
  $$TransaksiTableTableManager(_$AppDatabase db, $TransaksiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaksiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> catatan = const Value.absent(),
                Value<int> nominal = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<String> sifat = const Value.absent(),
                Value<String?> walletId = const Value.absent(),
                Value<DateTime> waktuTransaksi = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransaksiCompanion(
                id: id,
                catatan: catatan,
                nominal: nominal,
                kategori: kategori,
                sifat: sifat,
                walletId: walletId,
                waktuTransaksi: waktuTransaksi,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String catatan,
                required int nominal,
                required String kategori,
                required String sifat,
                Value<String?> walletId = const Value.absent(),
                required DateTime waktuTransaksi,
                Value<int> rowid = const Value.absent(),
              }) => TransaksiCompanion.insert(
                id: id,
                catatan: catatan,
                nominal: nominal,
                kategori: kategori,
                sifat: sifat,
                walletId: walletId,
                waktuTransaksi: waktuTransaksi,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransaksiTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaksiTable,
      TransaksiData,
      $$TransaksiTableFilterComposer,
      $$TransaksiTableOrderingComposer,
      $$TransaksiTableAnnotationComposer,
      $$TransaksiTableCreateCompanionBuilder,
      $$TransaksiTableUpdateCompanionBuilder,
      (
        TransaksiData,
        BaseReferences<_$AppDatabase, $TransaksiTable, TransaksiData>,
      ),
      TransaksiData,
      PrefetchHooks Function()
    >;
typedef $$PemasukanTableCreateCompanionBuilder =
    PemasukanCompanion Function({
      required String id,
      required String sumber,
      required int nominal,
      required String kategori,
      Value<String?> walletId,
      required DateTime waktuPemasukan,
      Value<int> rowid,
    });
typedef $$PemasukanTableUpdateCompanionBuilder =
    PemasukanCompanion Function({
      Value<String> id,
      Value<String> sumber,
      Value<int> nominal,
      Value<String> kategori,
      Value<String?> walletId,
      Value<DateTime> waktuPemasukan,
      Value<int> rowid,
    });

class $$PemasukanTableFilterComposer
    extends Composer<_$AppDatabase, $PemasukanTable> {
  $$PemasukanTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sumber => $composableBuilder(
    column: $table.sumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get waktuPemasukan => $composableBuilder(
    column: $table.waktuPemasukan,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PemasukanTableOrderingComposer
    extends Composer<_$AppDatabase, $PemasukanTable> {
  $$PemasukanTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sumber => $composableBuilder(
    column: $table.sumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get waktuPemasukan => $composableBuilder(
    column: $table.waktuPemasukan,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PemasukanTableAnnotationComposer
    extends Composer<_$AppDatabase, $PemasukanTable> {
  $$PemasukanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sumber =>
      $composableBuilder(column: $table.sumber, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<DateTime> get waktuPemasukan => $composableBuilder(
    column: $table.waktuPemasukan,
    builder: (column) => column,
  );
}

class $$PemasukanTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PemasukanTable,
          PemasukanData,
          $$PemasukanTableFilterComposer,
          $$PemasukanTableOrderingComposer,
          $$PemasukanTableAnnotationComposer,
          $$PemasukanTableCreateCompanionBuilder,
          $$PemasukanTableUpdateCompanionBuilder,
          (
            PemasukanData,
            BaseReferences<_$AppDatabase, $PemasukanTable, PemasukanData>,
          ),
          PemasukanData,
          PrefetchHooks Function()
        > {
  $$PemasukanTableTableManager(_$AppDatabase db, $PemasukanTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PemasukanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PemasukanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PemasukanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sumber = const Value.absent(),
                Value<int> nominal = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<String?> walletId = const Value.absent(),
                Value<DateTime> waktuPemasukan = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PemasukanCompanion(
                id: id,
                sumber: sumber,
                nominal: nominal,
                kategori: kategori,
                walletId: walletId,
                waktuPemasukan: waktuPemasukan,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sumber,
                required int nominal,
                required String kategori,
                Value<String?> walletId = const Value.absent(),
                required DateTime waktuPemasukan,
                Value<int> rowid = const Value.absent(),
              }) => PemasukanCompanion.insert(
                id: id,
                sumber: sumber,
                nominal: nominal,
                kategori: kategori,
                walletId: walletId,
                waktuPemasukan: waktuPemasukan,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PemasukanTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PemasukanTable,
      PemasukanData,
      $$PemasukanTableFilterComposer,
      $$PemasukanTableOrderingComposer,
      $$PemasukanTableAnnotationComposer,
      $$PemasukanTableCreateCompanionBuilder,
      $$PemasukanTableUpdateCompanionBuilder,
      (
        PemasukanData,
        BaseReferences<_$AppDatabase, $PemasukanTable, PemasukanData>,
      ),
      PemasukanData,
      PrefetchHooks Function()
    >;
typedef $$HutangPiutangTableCreateCompanionBuilder =
    HutangPiutangCompanion Function({
      required String id,
      required String tipe,
      required String nama,
      required int nominal,
      Value<String> status,
      required DateTime tanggal,
      Value<int> rowid,
    });
typedef $$HutangPiutangTableUpdateCompanionBuilder =
    HutangPiutangCompanion Function({
      Value<String> id,
      Value<String> tipe,
      Value<String> nama,
      Value<int> nominal,
      Value<String> status,
      Value<DateTime> tanggal,
      Value<int> rowid,
    });

class $$HutangPiutangTableFilterComposer
    extends Composer<_$AppDatabase, $HutangPiutangTable> {
  $$HutangPiutangTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HutangPiutangTableOrderingComposer
    extends Composer<_$AppDatabase, $HutangPiutangTable> {
  $$HutangPiutangTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipe => $composableBuilder(
    column: $table.tipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HutangPiutangTableAnnotationComposer
    extends Composer<_$AppDatabase, $HutangPiutangTable> {
  $$HutangPiutangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);
}

class $$HutangPiutangTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HutangPiutangTable,
          HutangPiutangData,
          $$HutangPiutangTableFilterComposer,
          $$HutangPiutangTableOrderingComposer,
          $$HutangPiutangTableAnnotationComposer,
          $$HutangPiutangTableCreateCompanionBuilder,
          $$HutangPiutangTableUpdateCompanionBuilder,
          (
            HutangPiutangData,
            BaseReferences<
              _$AppDatabase,
              $HutangPiutangTable,
              HutangPiutangData
            >,
          ),
          HutangPiutangData,
          PrefetchHooks Function()
        > {
  $$HutangPiutangTableTableManager(_$AppDatabase db, $HutangPiutangTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HutangPiutangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HutangPiutangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HutangPiutangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tipe = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<int> nominal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HutangPiutangCompanion(
                id: id,
                tipe: tipe,
                nama: nama,
                nominal: nominal,
                status: status,
                tanggal: tanggal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tipe,
                required String nama,
                required int nominal,
                Value<String> status = const Value.absent(),
                required DateTime tanggal,
                Value<int> rowid = const Value.absent(),
              }) => HutangPiutangCompanion.insert(
                id: id,
                tipe: tipe,
                nama: nama,
                nominal: nominal,
                status: status,
                tanggal: tanggal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HutangPiutangTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HutangPiutangTable,
      HutangPiutangData,
      $$HutangPiutangTableFilterComposer,
      $$HutangPiutangTableOrderingComposer,
      $$HutangPiutangTableAnnotationComposer,
      $$HutangPiutangTableCreateCompanionBuilder,
      $$HutangPiutangTableUpdateCompanionBuilder,
      (
        HutangPiutangData,
        BaseReferences<_$AppDatabase, $HutangPiutangTable, HutangPiutangData>,
      ),
      HutangPiutangData,
      PrefetchHooks Function()
    >;
typedef $$RecurringTemplatesTableCreateCompanionBuilder =
    RecurringTemplatesCompanion Function({
      required String id,
      required String catatan,
      required int nominal,
      required String kategori,
      required String sifat,
      required String frekuensi,
      Value<String?> walletId,
      Value<int> rowid,
    });
typedef $$RecurringTemplatesTableUpdateCompanionBuilder =
    RecurringTemplatesCompanion Function({
      Value<String> id,
      Value<String> catatan,
      Value<int> nominal,
      Value<String> kategori,
      Value<String> sifat,
      Value<String> frekuensi,
      Value<String?> walletId,
      Value<int> rowid,
    });

class $$RecurringTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sifat => $composableBuilder(
    column: $table.sifat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frekuensi => $composableBuilder(
    column: $table.frekuensi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sifat => $composableBuilder(
    column: $table.sifat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frekuensi => $composableBuilder(
    column: $table.frekuensi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<String> get sifat =>
      $composableBuilder(column: $table.sifat, builder: (column) => column);

  GeneratedColumn<String> get frekuensi =>
      $composableBuilder(column: $table.frekuensi, builder: (column) => column);

  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);
}

class $$RecurringTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTemplatesTable,
          RecurringTemplate,
          $$RecurringTemplatesTableFilterComposer,
          $$RecurringTemplatesTableOrderingComposer,
          $$RecurringTemplatesTableAnnotationComposer,
          $$RecurringTemplatesTableCreateCompanionBuilder,
          $$RecurringTemplatesTableUpdateCompanionBuilder,
          (
            RecurringTemplate,
            BaseReferences<
              _$AppDatabase,
              $RecurringTemplatesTable,
              RecurringTemplate
            >,
          ),
          RecurringTemplate,
          PrefetchHooks Function()
        > {
  $$RecurringTemplatesTableTableManager(
    _$AppDatabase db,
    $RecurringTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> catatan = const Value.absent(),
                Value<int> nominal = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<String> sifat = const Value.absent(),
                Value<String> frekuensi = const Value.absent(),
                Value<String?> walletId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTemplatesCompanion(
                id: id,
                catatan: catatan,
                nominal: nominal,
                kategori: kategori,
                sifat: sifat,
                frekuensi: frekuensi,
                walletId: walletId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String catatan,
                required int nominal,
                required String kategori,
                required String sifat,
                required String frekuensi,
                Value<String?> walletId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTemplatesCompanion.insert(
                id: id,
                catatan: catatan,
                nominal: nominal,
                kategori: kategori,
                sifat: sifat,
                frekuensi: frekuensi,
                walletId: walletId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTemplatesTable,
      RecurringTemplate,
      $$RecurringTemplatesTableFilterComposer,
      $$RecurringTemplatesTableOrderingComposer,
      $$RecurringTemplatesTableAnnotationComposer,
      $$RecurringTemplatesTableCreateCompanionBuilder,
      $$RecurringTemplatesTableUpdateCompanionBuilder,
      (
        RecurringTemplate,
        BaseReferences<
          _$AppDatabase,
          $RecurringTemplatesTable,
          RecurringTemplate
        >,
      ),
      RecurringTemplate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$BudgetKategoriTableTableManager get budgetKategori =>
      $$BudgetKategoriTableTableManager(_db, _db.budgetKategori);
  $$CustomKategoriTableTableManager get customKategori =>
      $$CustomKategoriTableTableManager(_db, _db.customKategori);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$FinancialGoalsTableTableManager get financialGoals =>
      $$FinancialGoalsTableTableManager(_db, _db.financialGoals);
  $$NetworthHistoryTableTableManager get networthHistory =>
      $$NetworthHistoryTableTableManager(_db, _db.networthHistory);
  $$TransaksiTableTableManager get transaksi =>
      $$TransaksiTableTableManager(_db, _db.transaksi);
  $$PemasukanTableTableManager get pemasukan =>
      $$PemasukanTableTableManager(_db, _db.pemasukan);
  $$HutangPiutangTableTableManager get hutangPiutang =>
      $$HutangPiutangTableTableManager(_db, _db.hutangPiutang);
  $$RecurringTemplatesTableTableManager get recurringTemplates =>
      $$RecurringTemplatesTableTableManager(_db, _db.recurringTemplates);
}
