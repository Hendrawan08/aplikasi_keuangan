import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Baris item transaksi / pemasukan.
class TxTile extends StatelessWidget {
  const TxTile({
    super.key,
    required this.judul,
    required this.subtitle,
    required this.nominal,
    required this.waktu,
    required this.isExpense,
    this.onTap,
    this.onLongPress,
  });

  final String judul;
  final String subtitle;
  final int nominal;
  final DateTime waktu;
  final bool isExpense;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? AppColors.expense : AppColors.income;
    final tgl = DateFormat('d MMM, HH:mm', 'id_ID').format(waktu);
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isExpense ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          judul,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '$subtitle · $tgl',
          style: const TextStyle(color: AppColors.text2, fontSize: 12),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}${rp(nominal)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
