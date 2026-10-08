import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/calc.dart';
import '../data/models.dart';
import '../data/places.dart';
import '../data/store.dart';
import '../data/util.dart';
import '../theme.dart';
import '../ui/widgets.dart';
import '../widgets/globe_plane.dart';
import '../widgets/pos_card.dart';
import 'flows.dart';

void go(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

class PageShell extends StatelessWidget {
  final String title; final Widget body;
  const PageShell(this.title, this.body, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))), body: body);
}

Widget _pad(List<Widget> c, {double bottom = 40}) => ListView(padding: EdgeInsets.fromLTRB(18, 8, 18, bottom), children: c);
(String, Color?) _badge(double cur, double base) {
  if (base <= 0) return ('—', null);
  final d = ((cur / base - 1) * 100).round();
  return ('${d > 0 ? '+' : ''}$d%', d > 0 ? CM.alert : green);
}
Widget _bal(double b) => Text('${b >= 0 ? '+' : ''}${eur(b)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: b >= 0 ? green : CM.alert));
Widget _balCard(List<(String, Widget)> rows) => whiteCard(pad: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
      for (final r in rows) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [Expanded(child: Text(r.$1, style: TextStyle(color: CM.ink.withOpacity(.65)))), r.$2])),
    ]));

Widget expenseList(BuildContext c, List<Expense> l, {int? limit}) {
  if (l.isEmpty) return hint('Sin gastos todavía');
  final s = store.sorted(l);
  return Column(children: [
    for (final e in (limit == null ? s : s.take(limit)))
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14), onTap: () => go(c, ExpenseDetailPage(e.id)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                SizedBox(width: 48, child: Text(e.d != null ? fd(e.d!).substring(0, 5) : mesesC[int.parse(e.m.substring(5)) - 1].toLowerCase(), style: TextStyle(fontSize: 13, color: CM.ink.withOpacity(.6)))),
                Expanded(child: Text(e.isTrip ? '✈️ ${tripById(e.trip)?.place ?? ''} · ${e.cat.replaceFirst(RegExp(r'^\S+\s'), '')} · ${e.to}' : e.cat, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                Text(eur(e.amt, d: 2), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ]),
            ),
          ),
        ),
      ),
  ]);
}

// ======================= INICIO =======================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int y = ny, m = nm;
  void _shift(int d) => setState(() { m += d; if (m < 1) { m = 12; y--; } if (m > 12) { m = 1; y++; } });

  Future<void> _pick() async {
    var py = y;
    final r = await showModalBottomSheet<List<int>>(
      context: context, backgroundColor: CM.bg,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          YearSel(py, (v) => set(() => py = v)),
          const SizedBox(height: 12),
          GridView.count(shrinkWrap: true, crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2, physics: const NeverScrollableScrollPhysics(), children: [
            for (var i = 0; i < 12; i++)
              FilledButton.tonal(
                style: FilledButton.styleFrom(backgroundColor: py == y && i + 1 == m ? CM.butterDeep : CM.sky, foregroundColor: CM.ink),
                onPressed: () => Navigator.pop(ctx, [py, i + 1]), child: Text(mesesC[i])),
          ]),
        ]),
      )),
    );
    if (r != null) setState(() { y = r[0]; m = r[1]; });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) {
        final n = store.accT('Naranja', y, m), r = store.accT('Revolut', y, m), v = store.sum(store.trp(null, y, m));
        return ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 120), children: [
          const SyncBanner(),
          Row(children: [
            IconButton.filledTonal(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
            Expanded(child: TextButton(onPressed: _pick, child: Text('${cap(mesesL[m - 1])} $y ▾', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: CM.ink)))),
            IconButton.filledTonal(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
          ]),
          if (!(y == ny && m == nm)) Center(child: TextButton(onPressed: () => setState(() { y = ny; m = nm; }), child: const Text('Volver al mes actual'))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: CM.butter, borderRadius: BorderRadius.circular(28)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Casa', style: TextStyle(fontSize: 16)), Text(eur(n + r, d: 2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))]),
          ),
          PosCardTile(label: 'Naranja', total: eur(n, d: 2), color: CM.orange, tint: const Color(0xFFFFE6CC), onDone: () => go(context, AccountMonthPage('Naranja', y, m))),
          const SizedBox(height: 14),
          PosCardTile(label: 'Revolut', total: eur(r, d: 2), color: CM.charcoal, tint: CM.sky, onDone: () => go(context, AccountMonthPage('Revolut', y, m))),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => go(context, ViaMonthPage(y, m)),
            child: Container(
              height: 176, padding: const EdgeInsets.only(left: 22),
              decoration: BoxDecoration(color: const Color(0xFFCDEBEF), borderRadius: BorderRadius.circular(28)),
              child: Row(children: [
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Viajes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(eur(v, d: 2), style: const TextStyle(fontSize: 16)),
                ])),
                const GlobePlane(size: 170),
              ]),
            ),
          ),
        ]);
      });
}

class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});
  @override
  Widget build(BuildContext context) {
    String? t; String? btn; VoidCallback? f;
    if (store.demo) { t = 'Modo ejemplo · no se guarda ni se sincroniza'; btn = 'Salir'; f = () => store.setDemo(false); }
    else if (store.sync == 'ok' && store.empty) { t = 'Aún no hay datos compartidos. Añade tu primer gasto con ＋ o mira cómo se ve con datos de ejemplo.'; btn = 'Ver ejemplo'; f = () => store.setDemo(true); }
    else if (store.sync == 'local') { t = 'Sin sincronización: los datos solo viven en este dispositivo hasta que configures Firebase.'; }
    else if (store.sync == 'err') { t = 'No se pudo sincronizar. Revisa tu conexión.'; }
    if (t == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: CM.sky, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Expanded(child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        if (btn != null) FilledButton(style: FilledButton.styleFrom(backgroundColor: CM.butterDeep, foregroundColor: CM.ink), onPressed: f, child: Text(btn)),
      ]),
    );
  }
}

// ======================= RESUMEN =======================
class ResumenScreen extends StatefulWidget {
  const ResumenScreen({super.key});
  @override
  State<ResumenScreen> createState() => _ResumenScreenState();
}

class _ResumenScreenState extends State<ResumenScreen> {
  int y = ny;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) {
        final e = elapsed(y); var t = 0.0, p = 0.0;
        for (var i = 1; i <= e; i++) { t += store.real(y, i); p += store.real(y - 1, i); }
        return _pad([
          h1('💰 Resumen'), YearSel(y, (v) => setState(() => y = v)), const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: CM.butter, borderRadius: BorderRadius.circular(28)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Gasto total $y', style: const TextStyle(fontSize: 16)),
                if (p > 0) Text('${t >= p ? '▲' : '▼'} ${((t - p) / p * 100).abs().round()}% frente al mismo periodo de ${y - 1}', style: TextStyle(fontSize: 12, color: CM.ink.withOpacity(.7))),
              ])),
              Text(eur(t), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            ]),
          ),
          h3('Evolución mensual'),
          BarsChart([for (var i = 1; i <= 12; i++) [Seg(store.sum(store.cas('Naranja', y, i)), CM.orange), Seg(store.sum(store.cas('Revolut', y, i)), CM.charcoal), Seg(store.sum(store.trp(null, y, i)), CM.teal)]], onTap: (mo) => go(context, ResMonthPage(y, mo))),
          const Padding(padding: EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_Lg('Naranja', CM.orange), _Lg('Revolut', CM.charcoal), _Lg('Viajes', CM.teal)])),
          h3('Detalle anual'),
          _bigBtn('🟠 Naranja', eur(store.accT('Naranja', y)), const Color(0xFFFFE6CC), () => go(context, PageShell('Gastos Naranja $y', AccountScreen('Naranja', year: y, embedded: true)))),
          _bigBtn('⚫ Revolut', eur(store.accT('Revolut', y)), CM.sky, () => go(context, PageShell('Gastos Revolut $y', AccountScreen('Revolut', year: y, embedded: true)))),
          _bigBtn('✈️ Viajes', eur(store.sum(store.trp(null, y))), const Color(0xFFCDEBEF), () => go(context, PageShell('Viajes $y', ViajesScreen(year: y, embedded: true)))),
        ], bottom: 120);
      });
}

class _Lg extends StatelessWidget {
  final String t; final Color c;
  const _Lg(this.t, this.c);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 4), Text(t, style: const TextStyle(fontSize: 12))]));
}

Widget _bigBtn(String l, String v, Color bg, VoidCallback f) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(color: bg, borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: f, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Text(l, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))), Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))])))),
    );

class ResMonthPage extends StatelessWidget {
  final int y, m;
  const ResMonthPage(this.y, this.m, {super.key});
  @override
  Widget build(BuildContext context) => PageShell('${cap(mesesL[m - 1])} $y', ListenableBuilder(listenable: store, builder: (_, __) => _pad([
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: CM.butter, borderRadius: BorderRadius.circular(28)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total del mes', style: TextStyle(fontSize: 16)), Text(eur(store.real(y, m)), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))])),
        const SizedBox(height: 12),
        _bigBtn('🟠 Naranja', eur(store.accT('Naranja', y, m)), const Color(0xFFFFE6CC), () => go(context, AccountMonthPage('Naranja', y, m))),
        _bigBtn('⚫ Revolut', eur(store.accT('Revolut', y, m)), CM.sky, () => go(context, AccountMonthPage('Revolut', y, m))),
        _bigBtn('✈️ Viajes', eur(store.sum(store.trp(null, y, m))), const Color(0xFFCDEBEF), () => go(context, ViaMonthPage(y, m))),
        hint('Naranja y Revolut incluyen los viajes pagados con cada cuenta.'),
        h3('Distribución del gasto'),
        DonutBlock([DonutItem('🟠 Naranja (casa)', store.sum(store.cas('Naranja', y, m)), CM.orange), DonutItem('⚫ Revolut (casa)', store.sum(store.cas('Revolut', y, m)), CM.charcoal), DonutItem('✈️ Viajes', store.sum(store.trp(null, y, m)), CM.teal)]),
      ])));
}

// ======================= NARANJA / REVOLUT =======================
class AccountScreen extends StatefulWidget {
  final String acc; final int? year; final bool embedded;
  const AccountScreen(this.acc, {super.key, this.year, this.embedded = false});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late int y = widget.year ?? ny;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) {
        final a = widget.acc, col = a == 'Naranja' ? CM.orange : CM.charcoal, tot = store.accT(a, y), n = elapsed(y);
        final ms = [for (var i = 1; i <= 12; i++) store.accT(a, y, i)], mx = ms.reduce((p, q) => p > q ? p : q);
        final cs = store.cats(a, y), ct = cs.fold(0.0, (s, c) => s + c.v);
        final inc = income[a]! * n + store.sumX(store.exs(a, y));
        final all = [...past, [ny, nm]], vals = [for (final p in all) store.accT(a, p[0], p[1])];
        final hv = [for (final p in past) store.accT(a, p[0], p[1])], av = store.hAvg(a);
        final imx = hv.indexOf(hv.reduce((p, q) => p > q ? p : q)), imn = hv.indexOf(hv.reduce((p, q) => p < q ? p : q));
        String lb(List<int> p) => '${mesesC[p[1] - 1].toLowerCase()} ${p[0] % 100}';
        return _pad([
          h1('${a == 'Naranja' ? '🟠' : '⚫'} Gastos $a'),
          if (widget.embedded) Center(child: Text('$y', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))) else YearSel(y, (v) => setState(() => y = v)),
          const SizedBox(height: 10),
          statRow([StatBox('Total anual', eur(tot)), StatBox('Media mensual', eur(tot / n)), StatBox('Mes con más gasto', mx > 0 ? mesesC[ms.indexOf(mx)] : '—')]),
          statRow([StatBox('Ingresos anuales', eur(income[a]! * 12)), StatBox('Ingresos mensuales', eur(income[a]!)), StatBox('Ingresos extra', eur(store.sumX(store.exs(a, y))))]),
          h3('Evolución mensual'),
          BarsChart([for (final v in ms) [Seg(v, col)]], onTap: (mo) => go(context, AccountMonthPage(a, y, mo))),
          h3('Categorías'), hint('% = media mensual de $y frente a la media histórica de cada categoría'),
          DonutBlock([
            for (var i = 0; i < cs.length; i++)
              () {
                final c = cs[i];
                final b = c.n == 'Viajes' ? ('—', null) : _badge(store.yAvg(a, c.n, y), store.hAvg(a, c.n));
                return DonutItem('${c.e} ${c.n}', c.v, palette[i], share: ct > 0 ? '${(c.v / ct * 100).round()}% del total' : '', badge: b.$1, badgeColor: b.$2, onTap: () => go(context, CategoryPage(a, y, c.n)));
              }(),
          ]),
          h3('Media histórica'),
          statRow([StatBox('Media mensual', eur(av)), StatBox('Mes más caro', eur(hv[imx]), sub: lb(past[imx])), StatBox('Mes más barato', eur(hv[imn]), sub: lb(past[imn]))]),
          h3('Tendencia'), TrendChart(vals, av, col, lb(all.first), lb(all.last)),
          h3('Balance de $y'),
          _balCard([('Ingresos (fijos + extra)', Text(eur(inc), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), ('Gastos', Text(eur(tot), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), ('Balance', _bal(inc - tot))]),
          h3('Últimos gastos'), expenseList(context, [...store.cas(a, y), ...store.trp(a, y)], limit: 10),
        ], bottom: widget.embedded ? 40 : 120);
      });
}

class AccountMonthPage extends StatelessWidget {
  final String acc; final int y, m;
  const AccountMonthPage(this.acc, this.y, this.m, {super.key});
  @override
  Widget build(BuildContext context) => PageShell('${acc == 'Naranja' ? '🟠' : '⚫'} $acc · ${mesesL[m - 1]} $y', ListenableBuilder(listenable: store, builder: (_, __) {
        final g = store.accT(acc, y, m), ex = store.exs(acc, y, m), xt = store.sumX(ex), inc = income[acc]! + xt, cs = store.cats(acc, y, m);
        return _pad([
          statRow([StatBox('Gastos del mes', eur(g)), StatBox('Ingresos mensuales', eur(income[acc]!)), StatBox('Ingresos extra ＋', eur(xt), onTap: () => showExtraSheet(context, acc, y, m))]),
          _balCard([('Balance del mes', _bal(inc - g))]),
          if (ex.isNotEmpty) ...[h3('Ingresos extra'), for (final x in ex) whiteCard(child: Row(children: [Expanded(child: Text(x.obs.isEmpty ? 'Ingreso extra' : x.obs, style: const TextStyle(fontWeight: FontWeight.w600))), Text(eur(x.amt, d: 2), style: const TextStyle(fontWeight: FontWeight.w800))]))],
          h3('Categorías'), hint('% frente a ${mesesL[m - 1]} de ${y - 1}'),
          DonutBlock([
            for (var i = 0; i < cs.length; i++)
              () {
                final c = cs[i];
                final b = c.n == 'Viajes' ? ('—', null) : _badge(c.v, store.cm(acc, c.n, y - 1, m));
                return DonutItem('${c.e} ${c.n}', c.v, palette[i], badge: b.$1, badgeColor: b.$2, onTap: () => go(context, CategoryPage(acc, y, c.n)));
              }(),
          ]),
          h3('Gastos del mes'), expenseList(context, [...store.cas(acc, y, m), ...store.trp(acc, y, m)]),
        ]);
      }));
}

class CategoryPage extends StatelessWidget {
  final String acc, cat; final int y;
  const CategoryPage(this.acc, this.y, this.cat, {super.key});
  @override
  Widget build(BuildContext context) => PageShell('$cat · $acc $y', ListenableBuilder(listenable: store, builder: (_, __) {
        final x = cat == 'Viajes' ? store.trp(acc, y) : store.cas(acc, y).where((e) => e.cat == cat).toList();
        final col = acc == 'Naranja' ? CM.orange : CM.charcoal;
        return _pad([
          statRow([StatBox('Total $y', eur(store.sum(x)))]),
          h3('Evolución mensual'),
          BarsChart([for (var i = 1; i <= 12; i++) [Seg(store.sum(x.where((e) => e.m == ymKey(y, i))), col)]]),
          h3('Gastos'), expenseList(context, x),
        ]);
      }));
}

// ======================= VIAJES =======================
class ViajesScreen extends StatefulWidget {
  final int? year; final bool embedded;
  const ViajesScreen({super.key, this.year, this.embedded = false});
  @override
  State<ViajesScreen> createState() => _ViajesScreenState();
}

class _ViajesScreenState extends State<ViajesScreen> {
  late int y = widget.year ?? ny;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) {
        final ty = store.trips.where((t) => t.from.startsWith('$y-')).toList(), tot = store.sum(store.trp(null, y));
        return _pad([
          h1('✈️ Viajes $y'),
          if (!widget.embedded) YearSel(y, (v) => setState(() => y = v)),
          const SizedBox(height: 10),
          statRow([StatBox('Total gastado', eur(tot)), StatBox('Nº de viajes', '${ty.length}'), StatBox('Media por viaje', ty.isEmpty ? '—' : eur(tot / ty.length))]),
          h3('Mapa de viajes'), const TripMapBlock(),
          h3('Gasto por mes'),
          BarsChart([for (var i = 1; i <= 12; i++) [Seg(store.sum(store.trp(null, y, i)), CM.teal)]], onTap: (mo) => go(context, ViaMonthPage(y, mo))),
          h3('Viajes realizados'),
          if (ty.isEmpty) hint('Aún no hay viajes este año'),
          for (final t in ty) TripTicket(t, total: store.tripTot(t.id), onTap: () => go(context, TripPage(t.id))),
        ], bottom: widget.embedded ? 40 : 120);
      });
}

class TripMapBlock extends StatefulWidget {
  const TripMapBlock({super.key});
  @override
  State<TripMapBlock> createState() => _TripMapBlockState();
}

class _TripMapBlockState extends State<TripMapBlock> {
  final _c = MapController();
  bool pan = true;
  String? sel;
  LatLng _center = const LatLng(30, 10);
  double _zoom = 1.3;

  void _zoomBy(double d) { final cam = _c.camera; _c.move(cam.center, (cam.zoom + d).clamp(1.0, 18.0)); }

  Widget _mb(IconData i, VoidCallback f, {bool on = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(color: on ? CM.butterDeep : Colors.white, elevation: 2, borderRadius: BorderRadius.circular(12), child: InkWell(borderRadius: BorderRadius.circular(12), onTap: f, child: SizedBox(width: 38, height: 38, child: Icon(i, size: 20, color: CM.ink)))),
      );

  @override
  Widget build(BuildContext context) {
    final byPlace = <String, List<Trip>>{};
    for (final t in store.trips) { byPlace.putIfAbsent(t.place, () => []).add(t); }
    final flags = pan ? InteractiveFlag.all : (InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 280,
          child: Stack(children: [
            FlutterMap(
              key: ValueKey(pan), mapController: _c,
              options: MapOptions(
                initialCenter: _center, initialZoom: _zoom, minZoom: 1, maxZoom: 18,
                interactionOptions: InteractionOptions(flags: flags),
                onPositionChanged: (cam, _) { _center = cam.center; _zoom = cam.zoom; },
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.cookiesmilk.app'),
                MarkerLayer(markers: [
                  for (final e in byPlace.entries)
                    Marker(
                      point: tripLatLng(e.value.first), width: 44, height: 44, alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () { setState(() => sel = e.key); _c.move(tripLatLng(e.value.first), 6); },
                        child: Icon(Icons.location_on, size: 44, color: sel == e.key ? CM.orange : const Color(0xFF2FA3BA), shadows: const [Shadow(blurRadius: 4, color: Colors.black38)]),
                      ),
                    ),
                ]),
                const RichAttributionWidget(attributions: [TextSourceAttribution('© OpenStreetMap contributors')]),
              ],
            ),
            Positioned(top: 8, right: 8, child: Column(children: [
              _mb(Icons.add, () => _zoomBy(1)), _mb(Icons.remove, () => _zoomBy(-1)),
              _mb(Icons.pan_tool_alt_outlined, () => setState(() => pan = true), on: pan),
              _mb(Icons.touch_app_outlined, () => setState(() => pan = false), on: !pan),
              _mb(Icons.my_location, () { setState(() => sel = null); _c.move(const LatLng(30, 10), 1.3); }),
            ])),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      if (sel == null) hint('Pellizca para acercar o alejar y pulsa un 📍 para ver sus viajes.')
      else ...[
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('📍 $sel', style: const TextStyle(fontWeight: FontWeight.w800))),
        for (final t in byPlace[sel] ?? <Trip>[]) TripTicket(t, total: store.tripTot(t.id), onTap: () => go(context, TripPage(t.id))),
      ],
    ]);
  }
}

class ViaMonthPage extends StatelessWidget {
  final int y, m;
  const ViaMonthPage(this.y, this.m, {super.key});
  @override
  Widget build(BuildContext context) => PageShell('✈️ Viajes · ${mesesL[m - 1]} $y', ListenableBuilder(listenable: store, builder: (_, __) {
        final x = store.trp(null, y, m); final ids = x.map((e) => e.trip).toSet();
        return _pad([
          statRow([StatBox('Total del mes', eur(store.sum(x)))]),
          h3('Viajes'), if (ids.isEmpty) hint('Sin viajes este mes'),
          for (final id in ids) if (tripById(id) != null) TripTicket(tripById(id)!, total: store.tripTot(id!), onTap: () => go(context, TripPage(id!))),
          h3('Categorías'),
          DonutBlock([for (var i = 0; i < tripCats.length; i++) DonutItem('${tripCats[i][0]} ${tripCats[i][1]}', store.sum(x.where((e) => e.cat == '${tripCats[i][0]} ${tripCats[i][1]}')), palette[i])]),
        ]);
      }));
}

class TripPage extends StatelessWidget {
  final String id;
  const TripPage(this.id, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) {
        final t = tripById(id);
        if (t == null) return const Scaffold(body: Center(child: Text('Viaje no encontrado')));
        final x = store.E.where((e) => e.trip == id).toList();
        return PageShell(t.place, _pad([
          Row(children: [flagBox(t.iso, w: 38, h: 26), const SizedBox(width: 10), Text(t.place, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800))]),
          Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: Text('${rng(t.from, t.to)} ${t.from.substring(0, 4)} · ${t.country}', style: TextStyle(color: CM.ink.withOpacity(.65)))),
          statRow([StatBox('Total del viaje', eur(store.sum(x))), StatBox('Repercute en Casa', eur(store.sum(x.where((e) => e.to == 'Naranja' || e.to == 'Revolut'))))]),
          h3('Por categoría'),
          DonutBlock([for (var i = 0; i < tripCats.length; i++) DonutItem('${tripCats[i][0]} ${tripCats[i][1]}', store.sum(x.where((e) => e.cat == '${tripCats[i][0]} ${tripCats[i][1]}')), palette[i])]),
          h3('¿De dónde salió el dinero?'),
          DonutBlock([for (var i = 0; i < whoList.length; i++) DonutItem('${whoList[i][0]} ${whoList[i][1]}', store.sum(x.where((e) => e.to == whoList[i][1])), [CM.orange, CM.charcoal, const Color(0xFFE9A0A0), const Color(0xFF8FBEDC)][i])]),
          h3('Gastos del viaje'), expenseList(context, x),
        ]));
      });
}
