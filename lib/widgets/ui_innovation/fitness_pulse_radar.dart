import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FitnessPulseRadar extends StatelessWidget {
  final double intensity; // 0.0 a 100.0 (recibido del sensor)
  final int bpm;
  final int steps;

  const FitnessPulseRadar({
    super.key,
    required this.intensity,
    this.bpm = 124,
    this.steps = 6420,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF2A1215),
            Color(0xFF161616),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'TELEMETRÍA EN VIVO (SENSOR)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${intensity.toInt()}% INTENSIDAD',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 180),
                  painter: _PulseRadarPainter(intensity: intensity),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: AppColors.primary, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${bpm + (intensity * 0.4).toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'BPM ESTIMADO',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(Icons.directions_walk, '$steps', 'Pasos Diarios'),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildMetricItem(Icons.local_fire_department, '${(steps * 0.045).toInt()} kcal', 'Calorías'),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildMetricItem(Icons.speed, '${(intensity * 0.12).toStringAsFixed(1)} m/s²', 'Aceleración'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondary, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class _PulseRadarPainter extends CustomPainter {
  final double intensity;

  _PulseRadarPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;

    // 1. Círculo base de radar
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius * 0.7, basePaint);
    canvas.drawCircle(center, radius * 0.4, basePaint);

    // 2. Arco exterior de intensidad
    final sweepAngle = (intensity / 100.0) * (2 * math.pi);
    final intensityPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppColors.secondary,
          AppColors.accent,
          AppColors.primary,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      intensityPaint,
    );

    // 3. Rayas decorativas del radar
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final start = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRadarPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
