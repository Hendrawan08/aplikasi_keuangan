import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';

/// Wizard onboarding untuk pengguna baru.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = <({String ikon, String judul, String desc})>[
    (
      ikon: '📊',
      judul: 'Selamat datang di DanaPintar AI',
      desc:
          'Catat keuangan dengan presisi & dapatkan analisis cerdas — '
          '100% lokal di HP-mu, tanpa cloud.',
    ),
    (
      ikon: '🔒',
      judul: 'Anggaran Terkunci',
      desc:
          'Kunci anggaran di awal bulan sebagai jangkar evaluasi. Health '
          'Score memantau kesehatan finansialmu.',
    ),
    (
      ikon: '💾',
      judul: 'Datamu, Privasimu',
      desc:
          'Semua data tersimpan di perangkat. Jangan lupa Backup berkala '
          'lewat menu Pengaturan agar aman.',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      selesaikanOnboarding(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => selesaikanOnboarding(ref),
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.ikon, style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 24),
                        Text(
                          s.judul,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.text2,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.accent : AppColors.bg3,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(last ? 'Mulai Sekarang' : 'Lanjut'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
