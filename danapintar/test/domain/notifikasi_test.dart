import 'package:flutter_test/flutter_test.dart';
import 'package:danapintar/domain/notifikasi.dart';

void main() {
  Set<String> ikon(List<Notif> n) => n.map((e) => e.ikon).toSet();

  test('anggaran belum dikunci → peringatan kunci', () {
    final n = generateNotifikasi(
      anggaranTerkunci: false,
      targetAda: false,
      totalPengeluaran: 0,
      batasBelanja: 0,
      belanjaJamRawan: 0,
      sukarelaBerlebihan: false,
    );
    expect(ikon(n).contains('🔒'), true);
  });

  test('terkunci tanpa target → info target', () {
    final n = generateNotifikasi(
      anggaranTerkunci: true,
      targetAda: false,
      totalPengeluaran: 100,
      batasBelanja: 0,
      belanjaJamRawan: 0,
      sukarelaBerlebihan: false,
    );
    expect(ikon(n).contains('🎯'), true);
  });

  test('melebihi batas → bahaya', () {
    final n = generateNotifikasi(
      anggaranTerkunci: true,
      targetAda: true,
      totalPengeluaran: 900000,
      batasBelanja: 800000,
      belanjaJamRawan: 0,
      sukarelaBerlebihan: false,
    );
    expect(n.any((e) => e.level == NotifLevel.bahaya), true);
  });

  test('dalam batas → sukses', () {
    final n = generateNotifikasi(
      anggaranTerkunci: true,
      targetAda: true,
      totalPengeluaran: 500000,
      batasBelanja: 800000,
      belanjaJamRawan: 0,
      sukarelaBerlebihan: false,
    );
    expect(n.any((e) => e.level == NotifLevel.sukses), true);
  });

  test('jam rawan & sukarela berlebihan muncul', () {
    final n = generateNotifikasi(
      anggaranTerkunci: true,
      targetAda: true,
      totalPengeluaran: 500000,
      batasBelanja: 800000,
      belanjaJamRawan: 50000,
      sukarelaBerlebihan: true,
    );
    expect(ikon(n).contains('🌙'), true);
    expect(ikon(n).contains('💸'), true);
  });
}
