import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/main.dart';

void main() {
  testWidgets('App boots and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const DanaPintarApp());

    // Judul aplikasi tampil.
    expect(find.text('📊 DanaPintar AI'), findsOneWidget);
    // Keadaan kosong Fase 0 tampil.
    expect(find.text('Belum ada data keuangan'), findsOneWidget);
  });
}
