import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/aerion_theme.dart';

class CircularGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final String label;
  final List<Color> gradientColors;
  final double size;

  const CircularGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.label,
    required this.gradientColors,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    final clampedVal = value.clamp(min, max);
    final progress = (clampedVal - min) / (max - min);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: progress,
              gradientColors: gradientColors,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 13,
                  color: AerionColors.textSecondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AerionColors.textMutedDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;

  _GaugePainter({
    required this.progress,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.085;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active Progress Arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: gradientColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gradientColors != gradientColors;
  }
}

