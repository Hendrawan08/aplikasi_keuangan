import 'package:drift/drift.dart';

/// Definisi tabel SQLite lokal — port skema Supabase (§5 dokumen rencana)
/// menjadi penyimpanan 100% lokal di perangkat. Tanpa user_id (single-user
/// per device). ID memakai UUID (TEXT) agar aman untuk fitur backup/restore.

/// Profil pengguna (single-row).
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().nullable()();
  TextColumn get lokasi => text().nullable()();
  TextColumn get fotoPath => text().nullable()();
}

/// Anggaran terkunci per bulan.
class Budgets extends Table {
  TextColumn get bulanKey => text()();
  IntColumn get nominal => integer()();

  @override
  Set<Column> get primaryKey => {bulanKey};
}

/// Target tabungan per bulan.
class SavingsGoals extends Table {
  TextColumn get bulanKey => text()();
  IntColumn get targetNominal => integer()();

  @override
  Set<Column> get primaryKey => {bulanKey};
}

/// Budget per kategori per bulan.
class BudgetKategori extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bulanKey => text()();
  TextColumn get kategori => text()();
  IntColumn get nominal => integer()();
}

/// Kategori custom (pengeluaran/pemasukan).
class CustomKategori extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  TextColumn get tipe => text()(); // 'pengeluaran' | 'pemasukan'
  TextColumn get ikon => text().withDefault(const Constant('📌'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Dompet (Cash/Bank/E-Wallet/Investasi/Kartu Kredit).
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  TextColumn get tipe => text()();
  IntColumn get saldoAwal => integer().withDefault(const Constant(0))();
  TextColumn get warna => text().withDefault(const Constant('#2E7D32'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Target finansial jangka pendek/panjang.
class FinancialGoals extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  IntColumn get targetNominal => integer()();
  IntColumn get terkumpul => integer().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get kategori => text().withDefault(const Constant('Tabungan'))();
  TextColumn get ikon => text().withDefault(const Constant('🎯'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Riwayat net worth per bulan. catatanAset/Liabilitas = JSON string.
class NetworthHistory extends Table {
  TextColumn get id => text()();
  TextColumn get bulanKey => text()();
  IntColumn get totalAset => integer().withDefault(const Constant(0))();
  IntColumn get totalLiabilitas => integer().withDefault(const Constant(0))();
  TextColumn get catatanAset => text().withDefault(const Constant('[]'))();
  TextColumn get catatanLiabilitas =>
      text().withDefault(const Constant('[]'))();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transaksi pengeluaran.
class Transaksi extends Table {
  TextColumn get id => text()();
  TextColumn get catatan => text()();
  IntColumn get nominal => integer()();
  TextColumn get kategori => text()();
  TextColumn get sifat => text()(); // 'Wajib' | 'Sukarela'
  TextColumn get walletId => text().nullable()();
  DateTimeColumn get waktuTransaksi => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transaksi pemasukan.
class Pemasukan extends Table {
  TextColumn get id => text()();
  TextColumn get sumber => text()();
  IntColumn get nominal => integer()();
  TextColumn get kategori => text()();
  TextColumn get walletId => text().nullable()();
  DateTimeColumn get waktuPemasukan => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Hutang & Piutang.
class HutangPiutang extends Table {
  TextColumn get id => text()();
  TextColumn get tipe => text()(); // 'hutang' | 'piutang'
  TextColumn get nama => text()();
  IntColumn get nominal => integer()();
  TextColumn get status => text().withDefault(const Constant('belum'))();
  DateTimeColumn get tanggal => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Template transaksi berulang.
class RecurringTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get catatan => text()();
  IntColumn get nominal => integer()();
  TextColumn get kategori => text()();
  TextColumn get sifat => text()();
  TextColumn get frekuensi => text()(); // Bulanan | Mingguan | 2 Mingguan
  TextColumn get walletId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
