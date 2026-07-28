import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../onboarding/onboarding_page.dart';
import 'home_shell.dart';

/// Gerbang aplikasi: tampilkan onboarding untuk pengguna baru,
/// selebihnya langsung ke beranda.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(onboardingDoneProvider);
    return done.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const HomeShell(),
      data: (selesai) => selesai ? const HomeShell() : const OnboardingPage(),
    );
  }
}
