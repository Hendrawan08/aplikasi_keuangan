import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/domain/health_score.dart';
import 'package:danapintar/presentation/widgets/health_card.dart';

void main() {
  testWidgets('HealthCard menampilkan skor & label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HealthCard(
            health: HealthResult(
              total: 72,
              rasioTabungan: 30,
              konsistensi: 18,
              porsiSukarela: 14,
              tren: 10,
            ),
            label: HealthLabel.sehat,
          ),
        ),
      ),
    );

    expect(find.text('🏅 Financial Health Score'), findsOneWidget);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('💛 Sehat'), findsOneWidget);
    // Empat komponen rincian tampil.
    expect(find.text('Rasio Tabungan'), findsOneWidget);
    expect(find.text('Tren Pengeluaran'), findsOneWidget);
  });
}
