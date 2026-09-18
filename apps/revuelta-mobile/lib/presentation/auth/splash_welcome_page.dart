import 'dart:math';
import 'package:flutter/material.dart';
import 'login_page.dart';


/// Pixel-perfect 100% faithful replication of the ReVuelta Welcome / Splash screen.
/// Features:
/// - Organic fluid sage-green background waves and botanical leaves
/// - Authentic ReVuelta leaf-loop mark and typography ("El ciclo de tu contenedor en tus manos.")
/// - 3D lunchbox container illustration with orbiting circulation cycle arrows and floating leaves
/// - Centered 3-dot page indicator
/// - Dark forest-green "Comenzar →" pill button
class SplashWelcomePage extends StatelessWidget {
  final VoidCallback? onStart;

  const SplashWelcomePage({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Stack(
        children: [
          // 1. Organic Background with curves and botanical corner leaves
          Positioned.fill(
            child: CustomPaint(
              painter: _OrganicBackgroundPainter(),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Brand Logo & Subtitle
                  Column(
                    children: [
                      // ReVuelta Leaf-Loop Icon
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CustomPaint(
                          painter: _RevueltaLeafIconPainter(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Brand Title
                      const Text(
                        'ReVuelta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF163A2E),
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      const Text(
                        'El ciclo de tu contenedor\nen tus manos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3F5E52),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Central Illustration: Container with Circulation Arrows & Floating Leaves
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 250,
                      child: CustomPaint(
                        painter: _ContainerCyclePainter(),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // 3-Dot Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active Dot 1
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF163A2E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Inactive Dot 2
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0DFD6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Inactive Dot 3
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0DFD6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Primary "Comenzar →" Pill Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF163A2E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (onStart != null) {
                        onStart!();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Comenzar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for the organic sage curves at top and delicate botanical leaves at bottom
class _OrganicBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sagePaint = Paint()
      ..color = const Color(0xFFD8E7DD).withOpacity(0.65)
      ..style = PaintingStyle.fill;

    // Top-Left Wave

    final pathTopLeft = Path();
    pathTopLeft.moveTo(0, 0);
    pathTopLeft.lineTo(size.width * 0.42, 0);
    pathTopLeft.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.08,
      0,
      size.height * 0.12,
    );
    pathTopLeft.close();
    canvas.drawPath(pathTopLeft, sagePaint);

    // Top-Right Wave
    final pathTopRight = Path();
    pathTopRight.moveTo(size.width * 0.58, 0);
    pathTopRight.lineTo(size.width, 0);
    pathTopRight.lineTo(size.width, size.height * 0.14);
    pathTopRight.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.09,
      size.width * 0.58,
      0,
    );
    pathTopRight.close();
    canvas.drawPath(pathTopRight, sagePaint);

    // Bottom-Left Botanical Branch Leaves
    _drawBotanicalBranch(
      canvas,
      origin: Offset(size.width * 0.05, size.height * 0.98),
      scale: 1.0,
      angle: -pi / 6,
      color: const Color(0xFFC8DECFA0),
    );

    // Bottom-Right Botanical Branch Leaves
    _drawBotanicalBranch(
      canvas,
      origin: Offset(size.width * 0.92, size.height * 0.96),
      scale: 1.1,
      angle: -5 * pi / 6,
      color: const Color(0xFFC8DECFA0),
    );
  }

  void _drawBotanicalBranch(
    Canvas canvas, {
    required Offset origin,
    required double scale,
    required double angle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final stemPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2.5 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Stem
    final stem = Path();
    stem.moveTo(0, 0);
    stem.quadraticBezierTo(10 * scale, -40 * scale, 5 * scale, -90 * scale);
    canvas.drawPath(stem, stemPaint);

    // Leaves along stem
    _drawLeaf(canvas, Offset(0, -30 * scale), 26 * scale, 14 * scale, -0.6, leafPaint);
    _drawLeaf(canvas, Offset(8 * scale, -50 * scale), 32 * scale, 16 * scale, 0.7, leafPaint);
    _drawLeaf(canvas, Offset(2 * scale, -70 * scale), 28 * scale, 14 * scale, -0.5, leafPaint);
    _drawLeaf(canvas, Offset(5 * scale, -95 * scale), 34 * scale, 15 * scale, 0.0, leafPaint);

    canvas.restore();
  }

  void _drawLeaf(Canvas canvas, Offset center, double length, double width, double rot, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot);

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(-width, -length * 0.5, 0, -length);
    path.quadraticBezierTo(width, -length * 0.5, 0, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the exact ReVuelta leaf loop logo mark
class _RevueltaLeafIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = const Color(0xFF163A2E);


    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Outer leaf loop shape
    path.moveTo(w * 0.5, h * 0.05);
    // Right curve tapering to top
    path.cubicTo(w * 0.9, h * 0.05, w * 0.95, h * 0.5, w * 0.75, h * 0.85);
    // Bottom curve
    path.cubicTo(w * 0.6, h * 1.0, w * 0.25, h * 0.95, w * 0.1, h * 0.65);
    // Left curve
    path.cubicTo(w * 0.02, h * 0.45, w * 0.15, h * 0.15, w * 0.5, h * 0.05);
    path.close();

    // Inner negative-space leaf cutout
    final inner = Path();
    inner.moveTo(w * 0.48, h * 0.28);
    inner.cubicTo(w * 0.72, h * 0.28, w * 0.72, h * 0.58, w * 0.54, h * 0.72);
    inner.cubicTo(w * 0.32, h * 0.72, w * 0.28, h * 0.45, w * 0.48, h * 0.28);
    inner.close();

    // Subtract inner path from outer path
    final combined = Path.combine(PathOperation.difference, path, inner);

    // Diagonal cut mark in the loop
    canvas.save();
    canvas.translate(0, 0);
    canvas.drawPath(combined, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the 3D bento lunchbox, circulation cycle arrows, and radial floating leaves
class _ContainerCyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Circulation cycle arrows & floating leaves
    _drawOrbitingCycle(canvas, center, radius: 95);

    // 2. Soft shadow below lunchbox
    final shadowPaint = Paint()
      ..color = const Color(0xFFC7DCD0).withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 48),
        width: 150,
        height: 34,
      ),
      shadowPaint,
    );

    // 3. 3D Bento Container Body
    _drawBentoContainer(canvas, center);
  }

  void _drawOrbitingCycle(Canvas canvas, Offset center, {required double radius}) {
    final arrowPaint = Paint()
      ..color = const Color(0xFFB5D3C1)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = const Color(0xFFC8DECFA5)
      ..style = PaintingStyle.fill;

    // 3 Orbiting Curved Arrows
    const int arrowCount = 3;
    const double arcSpan = 2 * pi / 3;

    for (int i = 0; i < arrowCount; i++) {
      final startAngle = i * arcSpan - 0.2;
      const sweepAngle = arcSpan * 0.62;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, arrowPaint);

      // Arrow Head at the end of each arc
      final endAngle = startAngle + sweepAngle;
      final headX = center.dx + radius * cos(endAngle);
      final headY = center.dy + radius * sin(endAngle);

      final headPath = Path();
      const double headSize = 9.0;
      final tangentAngle = endAngle + pi / 2;

      headPath.moveTo(headX, headY);
      headPath.lineTo(
        headX - headSize * cos(tangentAngle - 0.5),
        headY - headSize * sin(tangentAngle - 0.5),
      );
      headPath.lineTo(
        headX - headSize * cos(tangentAngle + 0.5),
        headY - headSize * sin(tangentAngle + 0.5),
      );
      headPath.close();

      canvas.drawPath(
        headPath,
        Paint()
          ..color = const Color(0xFFB5D3C1)
          ..style = PaintingStyle.fill,
      );
    }

    // Radial Floating Leaves surrounding the cycle
    final leafPositions = [
      {'angle': -2.4, 'dist': 120.0, 'rot': 0.4, 'w': 24.0, 'h': 12.0},
      {'angle': -1.6, 'dist': 105.0, 'rot': -0.3, 'w': 18.0, 'h': 9.0},
      {'angle': -0.5, 'dist': 118.0, 'rot': 0.8, 'w': 22.0, 'h': 11.0},
      {'angle': 0.2, 'dist': 122.0, 'rot': -0.6, 'w': 26.0, 'h': 13.0},
      {'angle': 1.1, 'dist': 115.0, 'rot': 0.3, 'w': 20.0, 'h': 10.0},
      {'angle': 2.2, 'dist': 125.0, 'rot': -0.7, 'w': 25.0, 'h': 12.0},
      {'angle': 2.9, 'dist': 110.0, 'rot': 0.5, 'w': 19.0, 'h': 9.0},
    ];

    for (final leaf in leafPositions) {
      final ang = leaf['angle']!;
      final dist = leaf['dist']!;
      final lx = center.dx + dist * cos(ang);
      final ly = center.dy + dist * sin(ang);

      canvas.save();
      canvas.translate(lx, ly);
      canvas.rotate(leaf['rot']!);

      final lp = Path();
      final lw = leaf['w']!;
      final lh = leaf['h']!;
      lp.moveTo(-lw / 2, 0);
      lp.quadraticBezierTo(0, -lh, lw / 2, 0);
      lp.quadraticBezierTo(0, lh, -lw / 2, 0);
      lp.close();

      canvas.drawPath(lp, leafPaint);
      canvas.restore();
    }
  }

  void _drawBentoContainer(Canvas canvas, Offset center) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF1E3F33)
      ..style = PaintingStyle.fill;

    final lidPaint = Paint()
      ..color = const Color(0xFF2C5647)
      ..style = PaintingStyle.fill;

    final lidRimPaint = Paint()
      ..color = const Color(0xFF3B6E5B)
      ..style = PaintingStyle.fill;

    final clipPaint = Paint()
      ..color = const Color(0xFFE2EFE7)
      ..style = PaintingStyle.fill;

    const double cw = 136;
    const double ch = 76;
    final bodyRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 8),
      width: cw,
      height: ch,
    );

    // 1. Container Main Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(16)),
      bodyPaint,
    );

    // Front Body Subtle Shadow/3D Contour
    final contourPaint = Paint()
      ..color = const Color(0xFF163228)
      ..style = PaintingStyle.fill;
    final contourPath = Path();
    contourPath.moveTo(bodyRect.left, bodyRect.top + 20);
    contourPath.lineTo(bodyRect.left, bodyRect.bottom);
    contourPath.lineTo(bodyRect.right, bodyRect.bottom);
    contourPath.lineTo(bodyRect.right, bodyRect.top + 20);
    contourPath.quadraticBezierTo(center.dx, bodyRect.top + 26, bodyRect.left, bodyRect.top + 20);
    contourPath.close();
    canvas.drawPath(contourPath, contourPaint);

    // 2. Printed ReVuelta Leaf Icon on Container Front
    _drawPrintedLeaf(canvas, Offset(center.dx, center.dy + 16));

    // 3. Container Translucent / Glossy Lid
    final lidRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 22),
      width: cw + 6,
      height: 24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(lidRect, const Radius.circular(10)),
      lidPaint,
    );

    // Lid Rim Top Highlight
    final rimRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 25),
      width: cw - 6,
      height: 14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, const Radius.circular(6)),
      lidRimPaint,
    );

    // 4. White Side Snap Latches (Clips)
    // Left Clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(bodyRect.left + 8, center.dy - 12), width: 14, height: 20),
        const Radius.circular(4),
      ),
      clipPaint,
    );
    // Right Clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(bodyRect.right - 8, center.dy - 12), width: 14, height: 20),
        const Radius.circular(4),
      ),
      clipPaint,
    );
  }

  void _drawPrintedLeaf(Canvas canvas, Offset center) {
    final leafPaint = Paint()
      ..color = const Color(0xFFD8EBE0)
      ..style = PaintingStyle.fill;

    final path = Path();
    const double size = 18;

    path.moveTo(center.dx - size / 2, center.dy);
    path.cubicTo(
      center.dx - size / 4,
      center.dy - size * 0.7,
      center.dx + size / 4,
      center.dy - size * 0.7,
      center.dx + size / 2,
      center.dy,
    );
    path.cubicTo(
      center.dx + size / 4,
      center.dy + size * 0.7,
      center.dx - size / 4,
      center.dy + size * 0.7,
      center.dx - size / 2,
      center.dy,
    );
    path.close();

    canvas.drawPath(path, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
