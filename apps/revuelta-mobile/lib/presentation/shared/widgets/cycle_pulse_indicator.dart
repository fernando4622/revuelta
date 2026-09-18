import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Visual indicator for the container lifecycle state.
///
/// Renders a circular icon representing the current state
/// of a container in the ReVuelta lifecycle, following the
/// visual language defined in the design system:
///   - AVAILABLE:  Dotted green circle
///   - IN_USE:     Dashed green circle with motion indicator
///   - RETURNED:   Half-filled green circle (devuelto)
///   - DAMAGED:    Orange filled circle
///   - LOST:       Red outlined circle
///   - RETIRED:    Grey filled circle
class CyclePulseIndicator extends StatelessWidget {
  final String state;
  final double size;

  const CyclePulseIndicator({
    super.key,
    required this.state,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CyclePulsePainter(state: state),
    );
  }
}

class _CyclePulsePainter extends CustomPainter {
  final String state;

  _CyclePulsePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    switch (state.toUpperCase()) {
      case 'AVAILABLE':
        _drawDottedCircle(canvas, center, radius, AppColors.statusAvailable);
        break;
      case 'IN_USE':
      case 'ASSIGNED':
        _drawDashedCircle(canvas, center, radius, AppColors.statusInUse);
        _drawArrow(canvas, center, radius, AppColors.statusInUse);
        break;
      case 'RETURNED':
        _drawHalfFilledCircle(canvas, center, radius, AppColors.statusReturned);
        break;
      case 'DAMAGED':
        _drawFilledCircle(canvas, center, radius, AppColors.statusDamaged);
        _drawExclamation(canvas, center, radius);
        break;
      case 'LOST':
        _drawOutlineCircle(canvas, center, radius, AppColors.statusLost);
        _drawQuestion(canvas, center, radius);
        break;
      case 'RETIRED':
        _drawFilledCircle(canvas, center, radius, AppColors.statusRetired);
        break;
      case 'REGISTERED':
        _drawOutlineCircle(canvas, center, radius, AppColors.textSecondary);
        break;
      default:
        _drawOutlineCircle(canvas, center, radius, AppColors.textSecondary);
    }
  }

  void _drawDottedCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const int dotCount = 16;
    final dotRadius = radius * 0.08;

    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * pi * i) / dotCount;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.round;

    const int segments = 12;
    const double gapRatio = 0.3;
    final segmentAngle = (2 * pi) / segments;
    final drawAngle = segmentAngle * (1 - gapRatio);

    for (int i = 0; i < segments; i++) {
      final startAngle = segmentAngle * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        drawAngle,
        false,
        paint,
      );
    }
  }

  void _drawArrow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1
      ..strokeCap = StrokeCap.round;

    final arrowSize = radius * 0.3;
    final tipX = center.dx + radius * 0.65;
    final tipY = center.dy - radius * 0.15;

    canvas.drawLine(
      Offset(tipX - arrowSize, tipY - arrowSize * 0.5),
      Offset(tipX, tipY),
      paint,
    );
    canvas.drawLine(
      Offset(tipX - arrowSize, tipY + arrowSize * 0.5),
      Offset(tipX, tipY),
      paint,
    );
  }

  void _drawHalfFilledCircle(Canvas canvas, Offset center, double radius, Color color) {
    // Outline
    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1;
    canvas.drawCircle(center, radius, outlinePaint);

    // Half fill (bottom)
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      center.dx - radius,
      center.dy,
      center.dx + radius,
      center.dy + radius,
    ));
    canvas.drawCircle(center, radius, fillPaint);
    canvas.restore();
  }

  void _drawFilledCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawOutlineCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawExclamation(Canvas canvas, Offset center, double radius) {
    final textSpan = TextSpan(
      text: '!',
      style: TextStyle(
        color: Colors.white,
        fontSize: radius * 0.9,
        fontWeight: FontWeight.w800,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawQuestion(Canvas canvas, Offset center, double radius) {
    final textSpan = TextSpan(
      text: '?',
      style: TextStyle(
        color: AppColors.statusLost,
        fontSize: radius * 0.8,
        fontWeight: FontWeight.w700,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CyclePulsePainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
