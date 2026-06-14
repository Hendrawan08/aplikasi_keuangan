import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';

/// Penyedia instance [AppDatabase] tunggal untuk seluruh aplikasi.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
