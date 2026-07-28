import 'package:flutter_test/flutter_test.dart';
import 'package:danapintar/domain/health_score.dart';

void main() {
  group('hitungHealthScore', () {
    test('tanpa anggaran → s1=20', () {
      // s1=20, s2=int(10/15*20)=13, s3=10 (budget 0), s4=10 → 53
      final r = hitungHealthScore(
        totalPengeluaran: 500000,
        budget: 0,
        target: 0,
        sukarela: 100000,
        hariUnikCatat: 10,
        adaData: true,
      );
      expect(r.rasioTabungan, 20);
      expect(r.konsistensi, 13);
      expect(r.porsiSukarela, 10);
      expect(r.tren, 10);
      expect(r.total, 53);
    });

    test('anggaran+target, di bawah batas, hemat → skor tinggi', () {
      // batas=800k, total<=batas → s1=40; s2=20; r=0.2→s3=20; s4=10 → 90
      final r = hitungHealthScore(
        totalPengeluaran: 700000,
        budget: 1000000,
        target: 200000,
        sukarela: 200000,
        hariUnikCatat: 15,
        adaData: true,
      );
      expect(r.rasioTabungan, 40);
      expect(r.konsistensi, 20);
      expect(r.porsiSukarela, 20);
      expect(r.tren, 10);
      expect(r.total, 90);
      expect(labelHealth(r.total), HealthLabel.excellent);
    });

    test('melebihi batas + sukarela tinggi + tren memburuk', () {
      // s1: 40-int(0.1*80)=32; s2: int(5/15*20)=6; r=0.6→s3=int(0.4*20)=8;
      // s4: int((1-0.8)*20)=int(3.9999..)=3 (IEEE754, identik dgn Python) → 49
      final r = hitungHealthScore(
        totalPengeluaran: 900000,
        budget: 1000000,
        target: 200000,
        sukarela: 600000,
        hariUnikCatat: 5,
        adaData: true,
        rataRataBulanLain: 500000,
      );
      expect(r.rasioTabungan, 32);
      expect(r.konsistensi, 6);
      expect(r.porsiSukarela, 8);
      expect(r.tren, 3);
      expect(r.total, 49);
      expect(labelHealth(r.total), HealthLabel.perluPerhatian);
    });

    test('anggaran tanpa target (cabang elif)', () {
      // s1=int((1-0.6)*40)=16; s2: int(20/15→cap1.0*20)=20; r=0.1→s3=20; s4=10 → 66
      final r = hitungHealthScore(
        totalPengeluaran: 600000,
        budget: 1000000,
        target: 0,
        sukarela: 100000,
        hariUnikCatat: 20,
        adaData: true,
      );
      expect(r.rasioTabungan, 16);
      expect(r.konsistensi, 20);
      expect(r.porsiSukarela, 20);
      expect(r.total, 66);
      expect(labelHealth(r.total), HealthLabel.sehat);
    });

    test('tanpa data bulan ini', () {
      // s1=40; s2=0; s3=10; s4=10 → 60
      final r = hitungHealthScore(
        totalPengeluaran: 0,
        budget: 1000000,
        target: 200000,
        sukarela: 0,
        hariUnikCatat: 0,
        adaData: false,
      );
      expect(r.total, 60);
    });

    test('total tidak melebihi 100', () {
      final r = hitungHealthScore(
        totalPengeluaran: 0,
        budget: 1000000,
        target: 100000,
        sukarela: 0,
        hariUnikCatat: 30,
        adaData: true,
        rataRataBulanLain: 999999,
      );
      expect(r.total, lessThanOrEqualTo(100));
    });
  });

  group('labelHealth ambang batas', () {
    test('batas-batas', () {
      expect(labelHealth(80), HealthLabel.excellent);
      expect(labelHealth(79), HealthLabel.sehat);
      expect(labelHealth(60), HealthLabel.sehat);
      expect(labelHealth(59), HealthLabel.perluPerhatian);
      expect(labelHealth(40), HealthLabel.perluPerhatian);
      expect(labelHealth(39), HealthLabel.kritis);
      expect(labelHealth(0), HealthLabel.kritis);
    });
  });
}
