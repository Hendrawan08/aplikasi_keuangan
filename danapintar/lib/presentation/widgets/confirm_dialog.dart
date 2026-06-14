import 'package:flutter/material.dart';

/// Dialog konfirmasi hapus bersama — menggantikan salinan terpisah di
/// halaman transaksi & pemasukan.
Future<bool> konfirmasiHapus(
  BuildContext context, {
  required String judul,
  required String pesan,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(judul),
      content: Text(pesan),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
