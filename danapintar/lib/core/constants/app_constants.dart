/// Konstanta aplikasi — port dari `aplikasi_keuangan.py` (KONSTANTA).
library;

/// Peta nomor bulan → nama bulan Indonesia.
const Map<int, String> kamusBulan = {
  1: 'Januari',
  2: 'Februari',
  3: 'Maret',
  4: 'April',
  5: 'Mei',
  6: 'Juni',
  7: 'Juli',
  8: 'Agustus',
  9: 'September',
  10: 'Oktober',
  11: 'November',
  12: 'Desember',
};

const List<String> kategoriPengeluaranDefault = [
  'Makanan',
  'Transportasi',
  'Hiburan/Gaya Hidup',
  'Kebutuhan Rumah/Kesehatan',
  'Tagihan Wajib',
  'Lain-lain',
];

const List<String> kategoriPemasukanDefault = [
  'Gaji',
  'Freelance',
  'Bisnis',
  'Investasi',
  'Hadiah/Bonus',
  'Passive Income',
  'Lain-lain',
];

const List<String> sifatList = ['Wajib', 'Sukarela'];

const List<String> frekuensiBerulang = ['Bulanan', 'Mingguan', '2 Mingguan'];

const List<String> tipeWallet = [
  '💵 Cash',
  '🏦 Bank',
  '📱 E-Wallet',
  '📈 Investasi',
  '💳 Kartu Kredit',
];

const List<String> goalIkonList = [
  '🎯',
  '🏠',
  '🚗',
  '✈️',
  '📱',
  '💍',
  '🎓',
  '💊',
  '🐾',
  '🛒',
  '🎸',
  '💻',
  '📷',
  '⛵',
  '🏋️',
];

const List<String> asetTipeList = [
  'Tabungan Bank',
  'Investasi',
  'Properti',
  'Kendaraan',
  'Emas/Logam Mulia',
  'Lainnya',
];

const List<String> liabTipeList = [
  'KPR',
  'Kredit Kendaraan',
  'Kartu Kredit',
  'Pinjaman Personal',
  'Hutang Usaha',
  'Lainnya',
];

const int anggaranMin = 10000;
const int anggaranDefault = 1000000;
