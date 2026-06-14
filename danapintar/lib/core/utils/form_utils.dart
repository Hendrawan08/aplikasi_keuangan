import 'package:flutter/material.dart';

/// Helper bersama untuk form input — menghapus duplikasi di form transaksi,
/// pemasukan, dan dialog pengaturan.

/// Ambil bilangan bulat dari teks (mengabaikan non-digit). 0 bila kosong.
int parseNominal(String? raw) =>
    int.tryParse((raw ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Validator field nominal: harus > 0.
String? validatorNominal(String? v) =>
    parseNominal(v) <= 0 ? 'Nominal tidak valid' : null;

/// Bangun item dropdown dari daftar string.
List<DropdownMenuItem<String>> dropdownItems(List<String> values) => values
    .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
    .toList();
