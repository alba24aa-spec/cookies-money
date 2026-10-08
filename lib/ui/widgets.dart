import 'dart:math';
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/util.dart';
import '../theme.dart';

const green = Color(0xFF2E9E5B);
const palette = [Color(0xFFFF8A2B), Color(0xFFF1D777), Color(0xFF8FBEDC), Color(0xFF63B5C6), Color(0xFFE9A0A0), Color(0xFFA9D8B8), Color(0xFFC3B1E1), Color(0xFFF4B183), Color(0xFF9AA5B1)];

Widget h1(String t) => Padding(padding: const EdgeInsets.only(top: 6, bottom: 10), child: Text(t, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)));
Widget h3(String t) => Padding(padding: const EdgeInsets.fromLTRB(2, 22, 0, 10), child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)));
Widget hint(String t) => Padding(padding: const EdgeInsets.fromLTRB(2, 0, 2, 8), child: Text(t, style: TextStyle(fontSize: 13, color: CM.ink.withOpacity(.65))));

class StatBox extends StatelessWidget {
  final String label, value; final String? sub; final VoidCallback? onTap; final Color? color;
  const StatBox(this.label, this.value, {super.key, this.sub, this.onTap, this.color});
  @override
  Widget build(BuildContext context) => Material(
        color: CM.butter, borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18), onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: onTap == null ? null : BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: CM.butterDeep, width: 2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 11, color: CM.ink.withOpacity(.7))),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              if (sub != null) Text(sub!, style: TextStyle(fontSize: 11, color: CM.ink.withOpacity(.7))),
            ]),
          ),
        ),
      );
}

Widget statRow(List<Widget> c) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < c.length; i++) Expanded(child: Padding(padding: EdgeInsets.only(left: i == 0 ? 0 : 8), child: c[i])),
      ])),
    );

Widget whiteCard({required Widget child, EdgeInsets pad = const EdgeInsets.all(14), Color? color}) =>
    Container(width: double.infinity, padding: pad, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: color ?? Colors.white, borderRadius: BorderRadius.circular(20)), child: child);

class YearSel extends StatelessWidget {
  final int y; final ValueChanged<int> on;
  const YearSel(this.y, this.on, {super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton.filledTonal(onPressed: () => on(y - 1), icon: const Icon(Icons.chevron_left)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Text('$y', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
        IconButton.filledTonal(onPressed: () => on(y + 1), icon: const Icon(Icons.chevron_right)),
      ]);
}

// ---------- barras ----------
class Seg { final double v; final Color c; const Seg(this.v, this.c); }

class BarsChart extends StatelessWidget {
  final List<List<Seg>> data; final void Function(int mo)? onTap;
  const BarsChart(this.data, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    final sums = data.map((d) => d.fold(0.0, (s, x) => s + x.v)).toList();
    final mx = max(1.0, sums.reduce(max));
    return Container(
      height: 170, padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < 12; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap!(i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(sums[i] > 0 ? sums[i].round().toString() : '', style: TextStyle(fontSize: 8, color: CM.ink.withOpacity(.7))),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: sums[i] == 0 ? 0 : max(3.0, sums[i] / mx * 108),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      child: Column(verticalDirection: VerticalDirection.up, children: [
                        for (final s in data[i].where((s) => s.v > 0)) Expanded(flex: max(1, (s.v * 100).round()), child: Container(color: s.c)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(mesesC[i], style: TextStyle(fontSize: 9, color: CM.ink.withOpacity(.7))),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

// ---------- aro táctil ----------
class DonutItem {
  final String name, share; final double v; final Color c; final String? badge; final Color? badgeColor; final VoidCallback? onTap;
  const DonutItem(this.name, this.v, this.c, {this.share = '', this.badge, this.badgeColor, this.onTap});
}

class DonutBlock extends StatefulWidget {
  final List<DonutItem> items;
  const DonutBlock(this.items, {super.key});
  @override
  State<DonutBlock> createState() => _DonutBlockState();
}

class _DonutBlockState extends State<DonutBlock> {
  int? sel;
  List<GlobalKey> keys = [];
  double get total => widget.items.fold(0.0, (s, i) => s + i.v);

  void _tap(Offset p) {
    const sz = 170.0; const k = sz / 160;
    final d = p - const Offset(sz / 2, sz / 2);
    if (d.distance < 42 * k || d.distance > 84 * k || total <= 0) return;
    var a = atan2(d.dy, d.dx) + pi / 2;
    if (a < 0) a += 2 * pi;
    var acc = 0.0;
    for (var i = 0; i < widget.items.length; i++) {
      acc += widget.items[i].v / total * 2 * pi;
      if (widget.items[i].v > 0 && a <= acc) {
        setState(() => sel = sel == i ? null : i);
        if (sel != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final c = keys[i].currentContext;
            if (c != null) Scrollable.ensureVisible(c, alignment: .4, duration: const Duration(milliseconds: 300));
          });
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.items;
    if (keys.length != it.length) keys = List.generate(it.length, (_) => GlobalKey());
    final s = sel != null && sel! < it.length ? sel : null;
    return Column(children: [
      Center(
        child: GestureDetector(
          onTapUp: (d) => _tap(d.localPosition),
          child: SizedBox(
            width: 170, height: 170,
            child: CustomPaint(
              painter: _Ring(it, s),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(34),
                  child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (s != null) Text(it[s].name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: CM.ink.withOpacity(.75))),
                    Text(eur(s != null ? it[s].v : total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < it.length; i++)
        Padding(
          key: keys[i],
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: s == i ? CM.butter : Colors.white, borderRadius: BorderRadius.circular(14),
            shape: s == i ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: CM.ink, width: 2.5)) : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: it[i].onTap ?? () => setState(() => sel = sel == i ? null : i),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: it[i].c, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it[i].name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    if (it[i].share.isNotEmpty) Text(it[i].share, style: TextStyle(fontSize: 12, color: CM.ink.withOpacity(.6))),
                  ])),
                  Text(eur(it[i].v, d: 2), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 44,
                    child: Text(it[i].badge ?? '${total > 0 ? (it[i].v / total * 100).round() : 0}%', textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 13, fontWeight: it[i].badge != null ? FontWeight.w800 : FontWeight.w500, color: it[i].badgeColor ?? CM.ink.withOpacity(.6))),
                  ),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _Ring extends CustomPainter {
  final List<DonutItem> it; final int? sel;
  _Ring(this.it, this.sel);
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 160, c = size.center(Offset.zero), r = 62 * k;
    final total = it.fold(0.0, (s, i) => s + i.v);
    final base = Paint()..style = PaintingStyle.stroke..strokeWidth = 26 * k..color = CM.ink.withOpacity(.1);
    canvas.drawCircle(c, r, base);
    if (total <= 0) return;
    var a = -pi / 2;
    for (var i = 0; i < it.length; i++) {
      if (it[i].v <= 0) continue;
      final sw = it[i].v / total * 2 * pi;
      final p = Paint()..style = PaintingStyle.stroke..strokeWidth = (sel == i ? 34 : 26) * k
        ..color = it[i].c.withOpacity(sel == null || sel == i ? 1 : .35);
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, max(0.0, sw - 0.01), false, p);
      a += sw;
    }
  }
  @override
  bool shouldRepaint(_Ring o) => true;
}

// ---------- tendencia ----------
class TrendChart extends StatelessWidget {
  final List<double> v; final double avg; final Color color; final String l0, l1;
  const TrendChart(this.v, this.avg, this.color, this.l0, this.l1, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: AspectRatio(aspectRatio: 340 / 130, child: CustomPaint(painter: _Trend(v, avg, color, l0, l1))),
      );
}

class _Trend extends CustomPainter {
  final List<double> v; final double avg; final Color col; final String l0, l1;
  _Trend(this.v, this.avg, this.col, this.l0, this.l1);
  @override
  void paint(Canvas canvas, Size s) {
    final k = s.width / 340, mx = max(max(v.reduce(max), avg) * 1.12, 1.0);
    final n = v.length;
    double x(int i) => (12 + i * (340 - 24) / max(1, n - 1)) * k;
    double y(double a) => (130 - 22 - a / mx * (130 - 34)) * k;
    final line = Path()..moveTo(x(0), y(v[0]));
    for (var i = 1; i < n; i++) { line.lineTo(x(i), y(v[i])); }
    final area = Path.from(line)..lineTo(x(n - 1), y(0))..lineTo(x(0), y(0))..close();
    canvas.drawPath(area, Paint()..color = col.withOpacity(.18));
    canvas.drawPath(line, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5 * k..color = col..strokeJoin = StrokeJoin.round);
    final ay = y(avg);
    for (double d = 12 * k; d < (340 - 12) * k; d += 8 * k) {
      canvas.drawLine(Offset(d, ay), Offset(d + 4 * k, ay), Paint()..color = CM.ink.withOpacity(.5)..strokeWidth = 1.2);
    }
    void txt(String t, double dx, double dy, {bool right = false, double fs = 9, double op = .7}) {
      final tp = TextPainter(text: TextSpan(text: t, style: TextStyle(fontSize: fs * k, color: CM.ink.withOpacity(op))), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(right ? dx - tp.width : dx, dy));
    }
    txt('Media ${eur(avg)}', (340 - 12) * k, ay - 13 * k, right: true, op: .8);
    txt(l0, 12 * k, 118 * k);
    txt(l1, (340 - 12) * k, 118 * k, right: true);
  }
  @override
  bool shouldRepaint(_Trend o) => true;
}

// ---------- billetes de avión ----------
class _TicketClip extends CustomClipper<Path> {
  final double stubH;
  _TicketClip(this.stubH);
  @override
  Path getClip(Size s) {
    final p = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(20)));
    if (stubH <= 0) return p;
    final y = s.height - stubH;
    final n = Path()..addOval(Rect.fromCircle(center: Offset(0, y), radius: 10))..addOval(Rect.fromCircle(center: Offset(s.width, y), radius: 10));
    return Path.combine(PathOperation.difference, p, n);
  }
  @override
  bool shouldReclip(_TicketClip o) => o.stubH != stubH;
}

class _Dash extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = CM.ink.withOpacity(.25)..strokeWidth = 2;
    for (double x = 14; x < s.width - 14; x += 10) { c.drawLine(Offset(x, 1), Offset(x + 5, 1), p); }
  }
  @override
  bool shouldRepaint(_) => false;
}

class Barcode extends StatelessWidget {
  const Barcode({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(double.infinity, 30), painter: _Bars());
}

class _Bars extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = CM.ink.withOpacity(.8);
    const w = [2.0, 1.0, 3.0, 1.0, 2.0, 1.0, 1.0, 3.0, 2.0, 1.0];
    var x = 0.0, i = 0;
    while (x < s.width) { c.drawRect(Rect.fromLTWH(x, 0, w[i % w.length], s.height), p); x += w[i % w.length] + 2 + (i % 3); i++; }
  }
  @override
  bool shouldRepaint(_) => false;
}

class TicketCard extends StatelessWidget {
  final Widget top; final Widget? stub; final VoidCallback? onTap;
  const TicketCard({super.key, required this.top, this.stub, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: onTap,
          child: ClipPath(
            clipper: _TicketClip(stub == null ? 0 : 60),
            child: Container(
              color: Colors.white,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                top,
                if (stub != null) ...[
                  CustomPaint(size: const Size(double.infinity, 2), painter: _Dash()),
                  SizedBox(height: 58, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: stub)),
                ],
              ]),
            ),
          ),
        ),
      );
}

// ---------- banderas ----------
LinearGradient _g(List<int> cs, List<double> ws, {bool v = false}) {
  final colors = <Color>[], stops = <double>[];
  var a = 0.0;
  for (var i = 0; i < cs.length; i++) { colors..add(Color(cs[i]))..add(Color(cs[i])); stops..add(a)..add(a + ws[i]); a += ws[i]; }
  stops[stops.length - 1] = 1.0;
  return LinearGradient(begin: v ? Alignment.topCenter : Alignment.centerLeft, end: v ? Alignment.bottomCenter : Alignment.centerRight, colors: colors, stops: stops);
}

const _t = 1 / 3;
final Map<String, LinearGradient> flagGradients = {
  'ES': _g([0xFFC60B1E, 0xFFFFC400, 0xFFC60B1E], [.25, .5, .25], v: true),
  'FR': _g([0xFF0055A4, 0xFFFFFFFF, 0xFFEF4135], [_t, _t, _t]),
  'IT': _g([0xFF009246, 0xFFFFFFFF, 0xFFCE2B37], [_t, _t, _t]),
  'PT': _g([0xFF046A38, 0xFFDA291C], [.4, .6]),
  'DE': _g([0xFF000000, 0xFFDD0000, 0xFFFFCE00], [_t, _t, _t], v: true),
  'NL': _g([0xFFAE1C28, 0xFFFFFFFF, 0xFF21468B], [_t, _t, _t], v: true),
  'BE': _g([0xFF000000, 0xFFFAE042, 0xFFED2939], [_t, _t, _t]),
  'AT': _g([0xFFED2939, 0xFFFFFFFF, 0xFFED2939], [_t, _t, _t], v: true),
  'IE': _g([0xFF169B62, 0xFFFFFFFF, 0xFFFF883E], [_t, _t, _t]),
  'PL': _g([0xFFFFFFFF, 0xFFDC143C], [.5, .5], v: true),
  'MX': _g([0xFF006847, 0xFFFFFFFF, 0xFFCE1126], [_t, _t, _t]),
  'AR': _g([0xFF74ACDF, 0xFFFFFFFF, 0xFF74ACDF], [_t, _t, _t], v: true),
  'HU': _g([0xFFCE2939, 0xFFFFFFFF, 0xFF477050], [_t, _t, _t], v: true),
};

String flagEmoji(String iso) => String.fromCharCodes(iso.toUpperCase().codeUnits.map((c) => 127397 + c));

Widget flagBox(String iso, {double w = 30, double h = 20}) {
  final g = flagGradients[iso];
  if (g != null) return Container(width: w, height: h, decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12)));
  if (iso == 'JP') {
    return Container(width: w, height: h, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12)),
        child: Container(width: h * .55, height: h * .55, decoration: const BoxDecoration(color: Color(0xFFBC002D), shape: BoxShape.circle)));
  }
  return Text(flagEmoji(iso), style: TextStyle(fontSize: h));
}

class TripTicket extends StatelessWidget {
  final Trip t; final double total; final VoidCallback? onTap; final bool withTotal;
  const TripTicket(this.t, {super.key, this.total = 0, this.onTap, this.withTotal = true});
  @override
  Widget build(BuildContext context) => TicketCard(
        onTap: onTap,
        top: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('✈ Billete de avión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CM.ink.withOpacity(.6))),
            const SizedBox(height: 6),
            Row(children: [flagBox(t.iso), const SizedBox(width: 10), Expanded(child: Text(t.place, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)))]),
            Text(t.country, style: TextStyle(fontWeight: FontWeight.w600, color: CM.ink.withOpacity(.6))),
            const SizedBox(height: 10),
            Text('Fechas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CM.ink.withOpacity(.6))),
            Text('${rng(t.from, t.to)} ${t.from.substring(0, 4)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
        ),
        stub: Row(children: [
          const Expanded(child: Barcode()),
          if (withTotal) ...[const SizedBox(width: 14), Text(eur(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))],
        ]),
      );
}

class CardIcon extends StatelessWidget {
  final Color color;
  const CardIcon(this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 38, height: 27, alignment: Alignment.topLeft, padding: const EdgeInsets.fromLTRB(5, 6, 0, 0),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5.5), border: Border.all(color: Colors.black12)),
        child: Container(width: 8, height: 6, decoration: BoxDecoration(color: CM.butterDeep, borderRadius: BorderRadius.circular(1.5))),
      );
}
