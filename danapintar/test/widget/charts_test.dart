import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/presentation/widgets/kategori_breakdown.dart';
import 'package:danapintar/presentation/widgets/wajib_sukarela_chart.dart';

void main() {
  testWidgets('WajibSukarelaChart menampilkan judul & legenda', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WajibSukarelaChart(wajib: 600000, sukarela: 400000),
        ),
      ),
    );
    // Judul & legenda adalah widget Text (label persen dilukis fl_chart di
    // canvas, jadi tidak dicari lewat find.text).
    expect(find.text('⚖️ Wajib vs Sukarela'), findsOneWidget);
    expect(find.text('Wajib'), findsOneWidget);
    expect(find.text('Sukarela'), findsOneWidget);
  });

  testWidgets('WajibSukarelaChart kosong saat total 0', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WajibSukarelaChart(wajib: 0, sukarela: 0)),
      ),
    );
    expect(find.text('⚖️ Wajib vs Sukarela'), findsNothing);
  });

  testWidgets('KategoriBreakdown menampilkan kategori', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KategoriBreakdown(
              perKategori: {'Makanan': 50000, 'Transportasi': 30000},
            ),
          ),
        ),
      ),
    );
    expect(find.text('📊 Pengeluaran per Kategori'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('Transportasi'), findsOneWidget);
  });
}
