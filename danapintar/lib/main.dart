import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/features/dashboard/dashboard_page.dart';

void main() {
  runApp(const ProviderScope(child: DanaPintarApp()));
}

class DanaPintarApp extends StatelessWidget {
  const DanaPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DanaPintar AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const DashboardPage(),
    );
  }
}
