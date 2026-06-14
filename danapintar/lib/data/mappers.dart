import '../core/utils/formatters.dart';
import '../domain/models.dart';
import 'local/database.dart';

/// Pemetaan baris drift → model domain.
extension TransaksiMapper on TransaksiData {
  TxView toTxView() => TxView(
        waktuWib: waktuTransaksi,
        nominal: nominal,
        kategori: kategori,
        sifat: sifat,
        bulanKey: bulanKey(waktuTransaksi.month, waktuTransaksi.year),
      );
}

extension TransaksiListMapper on List<TransaksiData> {
  List<TxView> toTxViews() => map((d) => d.toTxView()).toList();
}
