import 'package:flutter_test/flutter_test.dart';
import 'package:danapintar/domain/budget_rules.dart';

void main() {
  group('batasBelanja', () {
    test('anggaran dikurangi target', () {
      expect(batasBelanja(1000000, 200000), 800000);
    });
    test('tidak pernah negatif', () {
      expect(batasBelanja(100000, 200000), 0);
    });
  });

  group('sisaAnggaran', () {
    test('surplus', () => expect(sisaAnggaran(1000000, 700000), 300000));
    test(
      'defisit boleh negatif',
      () => expect(sisaAnggaran(500000, 700000), -200000),
    );
  });

  group('porsiSukarelaPersen', () {
    test('20 persen', () => expect(porsiSukarelaPersen(200000, 1000000), 20.0));
    test('anggaran nol → 0', () => expect(porsiSukarelaPersen(100, 0), 0));
  });

  group('sukarelaBerlebihan (ambang > 50%)', () {
    test('60% → true', () => expect(sukarelaBerlebihan(600000, 1000000), true));
    test(
      'tepat 50% → false (bukan >50)',
      () => expect(sukarelaBerlebihan(500000, 1000000), false),
    );
    test(
      '50.0001% → true',
      () => expect(sukarelaBerlebihan(500001, 1000000), true),
    );
  });
}
