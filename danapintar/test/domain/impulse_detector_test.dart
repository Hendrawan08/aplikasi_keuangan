import 'package:flutter_test/flutter_test.dart';
import 'package:danapintar/domain/impulse_detector.dart';

import 'tx_helper.dart';

void main() {
  group('isJamRawan (>=20 atau <=5)', () {
    test('jam malam & dini hari = rawan', () {
      for (final j in [20, 21, 23, 0, 3, 5]) {
        expect(isJamRawan(j), true, reason: 'jam $j harus rawan');
      }
    });
    test('jam siang = tidak rawan', () {
      for (final j in [6, 7, 12, 17, 19]) {
        expect(isJamRawan(j), false, reason: 'jam $j tidak rawan');
      }
    });
  });

  test('totalBelanjaJamRawan menjumlahkan hanya jam rawan', () {
    final txs = [
      tx('2026-06-01', nominal: 50000, jam: 22), // rawan
      tx('2026-06-01', nominal: 30000, jam: 2), // rawan
      tx('2026-06-02', nominal: 99000, jam: 13), // tidak
      tx('2026-06-03', nominal: 10000, jam: 5), // rawan
    ];
    expect(totalBelanjaJamRawan(txs), 90000);
    expect(transaksiJamRawan(txs).length, 3);
  });
}
