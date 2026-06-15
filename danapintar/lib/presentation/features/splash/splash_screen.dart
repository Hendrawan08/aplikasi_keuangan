import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../home/app_gate.dart';
import 'logo_mark.dart';

/// Layar pembuka dengan animasi 3D logo (perspektif berputar + kilau + glow),
/// lalu transisi halus ke aplikasi. Navigasi dijamin terjadi (fail-safe timer)
/// sehingga tak pernah macet di splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Easing sinematik (Expo-out) — rekomendasi gaya "Modern Dark / Cinema".
  static const _expo = Cubic(0.16, 1.0, 0.3, 1.0);

  late final AnimationController _intro;
  late final AnimationController _ambient;

  late final Animation<double> _fade;
  late final Animation<double> _spin;
  late final Animation<double> _scale;
  late final Animation<double> _word;
  late final Animation<double> _tagline;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );
    _spin = Tween<double>(begin: -math.pi * 0.85, end: 0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.0, 0.64, curve: _expo)),
    );
    _scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.0, 0.7, curve: _expo)),
    );
    _word = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.46, 0.78, curve: _expo),
    );
    _tagline = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.66, 0.95, curve: Curves.easeOut),
    );

    _intro.forward();
    _intro.addStatusListener((s) {
      if (s == AnimationStatus.completed) _goNext();
    });

    // Fail-safe: apa pun yang terjadi, masuk aplikasi maksimal 3,2 detik.
    Timer(const Duration(milliseconds: 3200), _goNext);
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const AppGate(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF13203A), Color(0xFF0A1426), Color(0xFF050B16)],
          ),
        ),
        child: Stack(
          children: [
            // Blob cahaya ambient yang bergerak perlahan.
            AnimatedBuilder(
              animation: _ambient,
              builder: (_, _) {
                final t = _ambient.value * 2 * math.pi;
                return Stack(
                  children: [
                    _blob(
                      const Alignment(-0.8, -0.7),
                      300,
                      AppColors.accent,
                      0.10,
                      Offset(math.sin(t) * 18, math.cos(t) * 14),
                    ),
                    _blob(
                      const Alignment(0.9, -0.4),
                      260,
                      const Color(0xFF0F3460),
                      0.20,
                      Offset(math.cos(t) * 16, math.sin(t) * 20),
                    ),
                    _blob(
                      const Alignment(0.2, 0.9),
                      340,
                      AppColors.accent2,
                      0.10,
                      Offset(math.sin(t + 1) * 22, math.cos(t + 1) * 12),
                    ),
                  ],
                );
              },
            ),

            // Konten tengah.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logo(),
                  const SizedBox(height: 28),
                  _wordmark(),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _tagline,
                    child: const Text(
                      'Kelola uang, lebih cerdas.',
                      style: TextStyle(
                        color: AppColors.text2,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indikator memuat di bawah.
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: FadeTransition(
                  opacity: _tagline,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return AnimatedBuilder(
      animation: _intro,
      builder: (_, _) {
        final glow = 0.25 + 0.20 * (0.5 + 0.5 * math.sin(_ambient.value * 2 * math.pi));
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo glow di belakang logo.
              Opacity(
                opacity: _fade.value * glow,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.accent, Color(0x004ADE80)],
                      stops: [0.0, 0.75],
                    ),
                  ),
                ),
              ),
              // Logo dengan rotasi 3D (perspektif).
              Opacity(
                opacity: _fade.value,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0014)
                    ..rotateY(_spin.value)
                    ..scaleByDouble(_scale.value, _scale.value, 1.0, 1.0),
                  child: const LogoMark(size: 150),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _wordmark() {
    return AnimatedBuilder(
      animation: _word,
      builder: (_, child) => Opacity(
        opacity: _word.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _word.value) * 16),
          child: child,
        ),
      ),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Dana',
              style: TextStyle(color: AppColors.text),
            ),
            TextSpan(
              text: 'Pintar',
              style: TextStyle(color: AppColors.accent),
            ),
            TextSpan(
              text: ' AI',
              style: TextStyle(color: AppColors.text2, fontSize: 18),
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _blob(
    Alignment align,
    double size,
    Color color,
    double opacity,
    Offset drift,
  ) {
    return Align(
      alignment: align,
      child: Transform.translate(
        offset: drift,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
