import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';

const List<String> _kBackgrounds = [
  'assets/images/backgrounds/bg1.jpg',
  'assets/images/backgrounds/bg2.jpg',
  'assets/images/backgrounds/bg3.jpg',
  'assets/images/backgrounds/bg4.jpg',
  'assets/images/backgrounds/bg5.jpg',
  'assets/images/backgrounds/bg6.jpg',
  'assets/images/backgrounds/bg7.jpg',
  'assets/images/backgrounds/bg8.jpg',
  'assets/images/backgrounds/bg9.jpg',
  'assets/images/backgrounds/bg10.jpg',
];

/// Full-screen Himalayan background — rotates through 10 HD photos with crossfade.
class MountainBackground extends StatefulWidget {
  final bool showBottomFade;
  const MountainBackground({super.key, this.showBottomFade = true});

  @override
  State<MountainBackground> createState() => _MountainBackgroundState();
}

class _MountainBackgroundState extends State<MountainBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late List<String> _shuffled;
  int _current = 0;
  int _next = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_kBackgrounds)..shuffle(math.Random());

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Change background every 6 seconds
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _advance());
  }

  void _advance() {
    if (!mounted) return;
    setState(() => _next = (_current + 1) % _shuffled.length);
    _ctrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _current = _next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Current photo
        Image.asset(
          _shuffled[_current],
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF02071A)),
        ),

        // Next photo crossfades in on top
        FadeTransition(
          opacity: _fade,
          child: Image.asset(
            _shuffled[_next],
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),

        // Dark overlay for readability
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xAA020818),
                Color(0x55091528),
                Color(0xCC0D1F0E),
                Color(0xFF0D1F0E),
              ],
              stops: [0.0, 0.30, 0.65, 1.0],
            ),
          ),
        ),

        // Stars & crescent moon overlay
        CustomPaint(
          painter: _StarsPainter(),
          child: const SizedBox.expand(),
        ),

        // Bottom fade into app background
        if (widget.showBottomFade)
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

    final cx = w * 0.84;
    final cy = h * 0.07;
    final r = w * 0.048;

    canvas.drawCircle(Offset(cx, cy), r * 1.8,
        Paint()
          ..color = const Color(0xFFFFF8D6).withOpacity(0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = const Color(0xFFFFF8D6).withOpacity(0.85));
    canvas.drawCircle(Offset(cx + r * 0.38, cy - r * 0.08), r * 0.80,
        Paint()..color = const Color(0xFF020818).withOpacity(0.9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
