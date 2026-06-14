import 'package:flutter/material.dart';

import '../goals/goals_page.dart';
import '../hutang/hutang_page.dart';

/// Hub menu fitur tambahan.
class LainnyaPage extends StatelessWidget {
  const LainnyaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(
        '🎯',
        'Financial Goals',
        'Target finansial dengan progress',
        () => const GoalsPage(),
      ),
      _MenuItem(
        '💸',
        'Hutang & Piutang',
        'Lacak pinjaman & tagihan',
        () => const HutangPage(),
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...items.map(
          (m) => Card(
            child: ListTile(
              leading: Text(m.ikon, style: const TextStyle(fontSize: 22)),
              title: Text(
                m.judul,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(m.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => m.builder())),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final String ikon;
  final String judul;
  final String subtitle;
  final Widget Function() builder;
  const _MenuItem(this.ikon, this.judul, this.subtitle, this.builder);
}
