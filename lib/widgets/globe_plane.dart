import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Globo terráqueo con un avión que orbita sin parar.
class GlobePlane extends StatefulWidget {
  final double size;
  const GlobePlane({super.key, this.size = 150});
  @override
  State<GlobePlane> createState() => _GlobePlaneState();
}

class _GlobePlaneState extends State<GlobePlane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(seconds: 6))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
          size: Size.square(widget.size), painter: _GlobePainter(_c.value)));
}

class _GlobePainter extends CustomPainter {
  final double t;
  _GlobePainter(this.t);
  static const tilt = -0.38;

  Offset _orbit(Offset c, double r, double a) {
    final x = r * 1.38 * math.cos(a), y = r * 0.36 * math.sin(a);
    return c + Offset(x * math.cos(tilt) - y * math.sin(tilt),
        x * math.sin(tilt) + y * math.cos(tilt));
  }

  void _plane(Canvas canvas, Offset c, double r, double a) {
    final p = _orbit(c, r, a), q = _orbit(c, r, a + 0.02);
    final heading = math.atan2(q.dy - p.dy, q.dx - p.dx) + math.pi / 2;
    final tp = TextPainter(
        text: TextSpan(text: String.fromCharCode(Icons.flight.codePoint),
            style: TextStyle(fontSize: r * 0.42, color: CM.ink,
                fontFamily: Icons.flight.fontFamily)),
        textDirection: TextDirection.ltr)..layout();
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(heading);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero), r = s.width * 0.28;
    final a = t * 2 * math.pi;
    final behind = math.sin(a) < 0;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero,
        width: r * 2.76, height: r * 0.72),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4
          ..color = CM.ink.withOpacity(.18));
    canvas.restore();

    if (behind) _plane(canvas, c, r, a);

    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(
        center: Alignment(-.4, -.4),
        colors: [Color(0xFFEAF5FC), CM.skyDeep]).createShader(rect));
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 1
      ..color = Colors.white.withOpacity(.7);
    for (var k = 0; k < 6; k++) {
      final ph = (k / 6 + t) % 1.0;
      canvas.drawOval(Rect.fromCenter(center: c,
          width: (r * 2 * math.cos(math.pi * ph)).abs(), height: r * 2), line);
    }
    for (final f in [-.55, 0.0, .55]) {
      canvas.drawLine(Offset(c.dx - r, c.dy + f * r),
          Offset(c.dx + r, c.dy + f * r), line);
    }
    final land = Paint()..color = CM.butterDeep.withOpacity(.9);
    for (var i = 0; i < 3; i++) {
      final x = ((i / 3 + t) % 1.0) * 2 - 1;
      canvas.drawOval(Rect.fromCenter(
          center: c + Offset(x * r * .9, (i - 1) * r * .42),
          width: r * .55, height: r * .3), land);
    }
    canvas.restore();
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 1.5..color = Colors.white);

    if (!behind) _plane(canvas, c, r, a);
  }

  @override
  bool shouldRepaint(_GlobePainter o) => o.t != t;
}
