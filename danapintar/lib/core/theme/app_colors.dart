import 'package:flutter/material.dart';

/// Palet warna — port dari variabel CSS di `inject_css()` (kode Python).
abstract class AppColors {
  static const bg = Color(0xFF0F172A); // background utama
  static const bg2 = Color(0xFF1E293B); // surface / card
  static const bg3 = Color(0xFF334155);
  static const text = Color(0xFFE2E8F0);
  static const text2 = Color(0xFF94A3B8); // teks sekunder / caption
  static const accent = Color(0xFF4ADE80); // hijau utama
  static const accent2 = Color(0xFF16A34A);
  static const border = Color(0xFF475569);
  static const sidebar = Color(0xFF080F1E);

  static const income = Color(0xFF22C55E);
  static const expense = Color(0xFFEF4444);
  static const incomeSoft = Color(0xFFBBF7D0);
  static const expenseSoft = Color(0xFFFCA5A5);

  /// Gradien kartu saldo (balance-card).
  static const balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2744), Color(0xFF0F3460)],
  );

  /// Gradien aksen merek (tombol utama, sorotan).
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
  );

  /// Latar gelap sinematik (dipakai layar pembuka & header).
  static const cinemaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF13203A), Color(0xFF0A1426), Color(0xFF050B16)],
  );
}
