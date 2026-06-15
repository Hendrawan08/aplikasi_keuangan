import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/notifications/notification_service.dart';
import 'presentation/features/home/app_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await NotificationService.instance.init();
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
      home: const AppGate(),
    );
  }
}
