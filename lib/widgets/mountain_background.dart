import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen Himalayan background — real photo + painted star/moon overlay.
class MountainBackground extends StatelessWidget {
  final bool showBottomFade;
  const MountainBackground({super.key, this.showBottomFade = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Real Himalayan photo (downloaded from Unsplash, free license)
        Image.asset(
          'assets/images/bg_mountains.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF02071A), Color(0xFF0D1F0E)],
              ),
            ),
          ),
        ),

        // Dark tint so app content is readable over the photo
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xAA020818), // heavy dark at top (sky area)
                Color(0x55091528), // lighter mid
                Color(0xCC0D1F0E), // dark at content area
                Color(0xFF0D1F0E), // solid app bg at bottom
              ],
              stops: [0.0, 0.30, 0.65, 1.0],
            ),
          ),
        ),

        // Stars & moon painted on top for a magical night feel
        CustomPaint(
          painter: _StarsPainter(),
          child: const SizedBox.expand(),
        ),

        // Bottom content fade
        if (showBottomFade)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF0D1F0E)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rng = math.Random(42);

    // Stars — only in upper 40% (sky area)
    for (int i = 0; i < 70; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.40;
      final r = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.55 + 0.2;
      canvas.drawCircle(
        Offset(x, y), r,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }

    // Crescent moon
    final cx = w * 0.84;
    final cy = h * 0.07;
    final r = w * 0.048;

    canvas.drawCircle(Offset(cx, cy), r * 1.8,
        Paint()..color = const Color(0xFFFFF8D6).withOpacity(0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = const Color(0xFFFFF8D6).withOpacity(0.85));
    canvas.drawCircle(Offset(cx + r * 0.38, cy - r * 0.08), r * 0.80,
        Paint()..color = const Color(0xFF020818).withOpacity(0.9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
