import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final double strokeWidth;
  final Color? color;

  const ProgressRing({
    super.key,
    required this.progress,
    this.strokeWidth = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 10% opacity roughly
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Padding to prevent stroke cutoff
        child: CustomPaint(
          painter: _ProgressRingPainter(
            progress: progress,
            strokeWidth: strokeWidth,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color? color;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    // Draw track
    final trackPaint = Paint()
      ..color = const Color(0xFFF3F4F6) // Light grey background track
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress gradient
    final gradient = const SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: [
        Color(0xFFFF6B9E), // Light pink
        Color(0xFFFF146E), // Deep pink
      ],
      stops: [0.0, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (color != null) {
      progressPaint.color = color!;
    } else {
      progressPaint.shader = gradient.createShader(rect);
    }

    final sweepAngle = 2 * pi * progress;
    
    // Rotate canvas by -90 degrees so SweepGradient starts at top
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 2);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawArc(
      rect,
      0, // Start at 0 relative to canvas rotation
      sweepAngle,
      false,
      progressPaint,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
