import 'package:flutter_test/flutter_test.dart';
import 'package:danapintar/domain/badges.dart';

import 'tx_helper.dart';

void main() {
  Set<String> nama(List badges) => badges.map((b) => b.nama).toSet().cast<String>();

  test('transaksi kosong → tidak ada badge', () {
    expect(
      cekBadges(transaksi: [], budgetByMonth: {}, targetByMonth: {}),
      isEmpty,
    );
  });

  test('dataset lengkap memicu keempat badge', () {
    final transaksi = [
      // 7 hari berturut-turut di Juni dengan 6 kategori berbeda
      tx('2026-06-01', kategori: 'Makanan'),
      tx('2026-06-02', kategori: 'Transportasi'),
      tx('2026-06-03', kategori: 'Hiburan/Gaya Hidup'),
      tx('2026-06-04', kategori: 'Kebutuhan Rumah/Kesehatan'),
      tx('2026-06-05', kategori: 'Tagihan Wajib'),
      tx('2026-06-06', kategori: 'Lain-lain'),
      tx('2026-06-07', kategori: 'Makanan'),
      // 1 transaksi di Mei (bulan kedua di bawah batas)
      tx('2026-05-20', kategori: 'Makanan'),
    ];
    final budget = {'Juni_2026': 1000000, 'Mei_2026': 500000};
    final target = {'Juni_2026': 300000, 'Mei_2026': 100000};

    final badges = cekBadges(
      transaksi: transaksi,
      budgetByMonth: budget,
      targetByMonth: target,
    );
    final n = nama(badges);
    expect(n.contains('Pencatat Setia'), true);
    expect(n.contains('Penabung Konsisten'), true);
    expect(n.contains('Pengelola Lengkap'), true);
    expect(n.contains('Big Saver'), true);

    final penabung = badges.firstWhere((b) => b.nama == 'Penabung Konsisten');
    expect(penabung.deskripsi, '2 bulan di bawah batas');
  });

  test('streak < 7 → tanpa Pencatat Setia', () {
    final transaksi = [
      tx('2026-06-01'),
      tx('2026-06-02'),
      tx('2026-06-03'),
    ];
    final badges =
        cekBadges(transaksi: transaksi, budgetByMonth: {}, targetByMonth: {});
    expect(nama(badges).contains('Pencatat Setia'), false);
  });

  test('Pengelola Lengkap butuh ≥5 kategori di bulan terakhir', () {
    final transaksi = [
      tx('2026-06-01', kategori: 'Makanan'),
      tx('2026-06-02', kategori: 'Transportasi'),
      tx('2026-06-03', kategori: 'Makanan'), // hanya 2 kategori unik
    ];
    final badges =
        cekBadges(transaksi: transaksi, budgetByMonth: {}, targetByMonth: {});
    expect(nama(badges).contains('Pengelola Lengkap'), false);
  });

  test('Big Saver tidak muncul bila target < 20% anggaran', () {
    final transaksi = [tx('2026-06-01', nominal: 10000)];
    final budget = {'Juni_2026': 1000000};
    final target = {'Juni_2026': 100000}; // 10% < 20%
    final badges = cekBadges(
      transaksi: transaksi,
      budgetByMonth: budget,
      targetByMonth: target,
    );
    expect(nama(badges).contains('Big Saver'), false);
  });
}
