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
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            isExpense ? '⬇' : '⬆',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
