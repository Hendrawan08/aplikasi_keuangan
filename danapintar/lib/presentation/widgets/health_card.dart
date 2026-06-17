import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/health_score.dart';

/// Kartu Financial Health Score + rincian 4 komponen.
class HealthCard extends StatelessWidget {
  const HealthCard({super.key, required this.health, required this.label});

  final HealthResult health;
  final HealthLabel label;

  Color get _scoreColor => switch (label) {
    HealthLabel.excellent => AppColors.accent,
    HealthLabel.sehat => const Color(0xFFEAB308),
    HealthLabel.perluPerhatian => const Color(0xFFF97316),
    HealthLabel.kritis => AppColors.expense,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏅 Financial Health Score',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '${health.total}',
                    style: TextStyle(
                      color: _scoreColor,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(color: AppColors.text2, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      label.display,
                      style: TextStyle(
                        color: _scoreColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...health.breakdown.entries.map(
                      (e) => _Bar(
                        label: e.key,
                        value: e.value,
                        max: HealthResult.breakdownMaks[e.key]!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, required this.max});
  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final pct = max == 0 ? 0.0 : value / max;
    final color = pct >= 0.7
        ? AppColors.accent
        : (pct >= 0.4 ? const Color(0xFFF59E0B) : AppColors.expense);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.text2, fontSize: 11),
              ),
              Text(
                '$value/$max',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
