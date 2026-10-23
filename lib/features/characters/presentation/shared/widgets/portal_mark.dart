import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';

import 'dart:math' as math;

class PortalMark extends StatelessWidget {
  const PortalMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _PortalPainter()),
  );
}

class _PortalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.46;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.accent.withValues(alpha: 0.1),
    );
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.035;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      -math.pi * 0.15,
      math.pi * 1.65,
      false,
      paint,
    );
    final spiral = Path();
    for (var i = 0; i <= 150; i++) {
      final t = i / 150;
      final angle = t * math.pi * 5;
      final r = radius * (0.08 + 0.65 * t);
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        spiral.moveTo(point.dx, point.dy);
      } else {
        spiral.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(spiral, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
