import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Tarjeta que al pulsarla se pasa por un datáfono y luego navega.
class PosCardTile extends StatefulWidget {
  final String label, total;
  final Color color, tint;
  final VoidCallback onDone;
  const PosCardTile({super.key, required this.label, required this.total,
      required this.color, required this.tint, required this.onDone});
  @override
  State<PosCardTile> createState() => _PosCardTileState();
}

class _PosCardTileState extends State<PosCardTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  late final Animation<double> _dy = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)), weight: 35),
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 35),
  ]).animate(_c);
  bool _beeped = false;

  void _beep() {
    if (_c.value > 0.65 && !_beeped) {
      _beeped = true;
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _tap() async {
    if (_c.isAnimating) return;
    HapticFeedback.mediumImpact();
    _beeped = false;
    _c.addListener(_beep);
    await _c.forward(from: 0);
    _c.removeListener(_beep);
    widget.onDone();
    _c.reset();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = widget.color.computeLuminance() < 0.2;
    return GestureDetector(
      onTap: _tap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final ok = _c.value > 0.65;
          return Container(
            height: 176,
            decoration: BoxDecoration(
                color: widget.tint, borderRadius: BorderRadius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(
                top: 10 + _dy.value * 56, left: 18, right: 18, height: 88,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(colors: [
                      widget.color,
                      Color.lerp(widget.color, Colors.white, dark ? .18 : .25)!
                    ]),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 24, height: 18, decoration: BoxDecoration(
                        color: CM.butterDeep, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(widget.label,
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 16))),
                    const Icon(Icons.contactless, color: Colors.white70),
                  ]),
                ),
              ),
              Positioned(
                bottom: 0, left: 10, right: 10, height: 98,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A3F47),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18), bottom: Radius.circular(24)),
                  ),
                  child: Column(children: [
                    Container(height: 6, margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                        decoration: BoxDecoration(color: Colors.black87,
                            borderRadius: BorderRadius.circular(3))),
                    Container(
                      height: 30, margin: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: ok ? const Color(0xFFBDEBC8) : CM.sky,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(ok ? '✓ Aceptado' : widget.total,
                          style: const TextStyle(fontWeight: FontWeight.w700,
                              color: CM.ink)),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (_) => Container(
                            width: 14, height: 14, margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(color: Colors.white24,
                                borderRadius: BorderRadius.circular(4))))),
                  ]),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
