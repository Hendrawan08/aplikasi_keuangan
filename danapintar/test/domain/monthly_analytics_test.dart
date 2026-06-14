import 'package:flutter_test/flutter_test.dart';
import 'package:danapintar/domain/monthly_analytics.dart';

import 'tx_helper.dart';

void main() {
  group('rataRataBulanLain', () {
    test('rata-rata bulan selain bulan ini', () {
      final txs = [
        tx('2026-05-10', nominal: 60000),
        tx('2026-05-20', nominal: 40000), // Mei total 100.000
        tx('2026-06-01', nominal: 70000), // Juni total 70.000
      ];
      // Bulan ini Juni → pembanding hanya Mei = 100.000
      expect(rataRataBulanLain(txs, 'Juni_2026'), 100000);
      // Bulan ini April (tak ada) → (100.000 + 70.000)/2 = 85.000
      expect(rataRataBulanLain(txs, 'April_2026'), 85000);
    });

    test('tanpa bulan pembanding → null', () {
      final txs = [tx('2026-06-01', nominal: 70000)];
      expect(rataRataBulanLain(txs, 'Juni_2026'), isNull);
    });
  });

  test('hariUnikCatat menghitung tanggal berbeda', () {
    final txs = [
      tx('2026-06-01', jam: 9),
      tx('2026-06-01', jam: 21), // tanggal sama
      tx('2026-06-02'),
      tx('2026-06-05'),
    ];
    expect(hariUnikCatat(txs), 3);
  });

  test('totalSukarela hanya menjumlahkan sifat Sukarela', () {
    final txs = [
      tx('2026-06-01', nominal: 50000, sifat: 'Sukarela'),
      tx('2026-06-02', nominal: 30000, sifat: 'Wajib'),
      tx('2026-06-03', nominal: 20000, sifat: 'Sukarela'),
    ];
    expect(totalSukarela(txs), 70000);
  });
}
