import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Ditampilkan saat fitur AI belum dikonfigurasi (anon key kosong).
class AiBelumSiap extends StatelessWidget {
  const AiBelumSiap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔌', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'Fitur AI belum aktif',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Aktifkan Edge Function di Supabase & isi anon key pada '
              'lib/core/config/ai_config.dart untuk mengaktifkan Scan Struk '
              '& DanaBot.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text2, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
