import 'package:flutter/material.dart';
import '../../core/theme/aerion_theme.dart';
import 'circular_gauge.dart';
import 'glass_card.dart';

class SensorMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final double min;
  final double max;
  final double? recordedMin;
  final double? recordedMax;
  final List<Color> gradientColors;
  final IconData icon;
  final String status;
  final Color statusColor;

  const SensorMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    this.recordedMin,
    this.recordedMax,
    required this.gradientColors,
    required this.icon,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: gradientColors.first),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AerionColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: CircularGauge(
              value: value,
              min: min,
              max: max,
              unit: unit,
              label: title,
              gradientColors: gradientColors,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AerionColors.darkCardBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    "MIN",
                    style: TextStyle(fontSize: 10, color: AerionColors.textMutedDark, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recordedMin != null ? "${recordedMin!.toStringAsFixed(1)}$unit" : "--",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(width: 1, height: 20, color: AerionColors.darkCardBorder),
              Column(
                children: [
                  const Text(
                    "MAX",
                    style: TextStyle(fontSize: 10, color: AerionColors.textMutedDark, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recordedMax != null ? "${recordedMax!.toStringAsFixed(1)}$unit" : "--",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

