import 'package:flutter/material.dart';
import '../data/calc.dart';
import '../data/models.dart';
import '../data/places.dart';
import '../data/store.dart';
import '../data/util.dart';
import '../theme.dart';
import '../ui/widgets.dart';
import 'screens.dart';

void openAddSheet(BuildContext context) {
  Widget big(String t, Color c, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(color: c, borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: f,
            child: SizedBox(height: 72, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))))))),
      );
  showModalBottomSheet(
    context: context, backgroundColor: CM.bg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      big('🟠 Naranja', CM.orange, () { Navigator.pop(ctx); go(context, const CategoryPickPage('Naranja')); }),
      big('⚫ Revolut', CM.charcoal, () { Navigator.pop(ctx); go(context, const CategoryPickPage('Revolut')); }),
      big('✈️ Viajes', CM.teal, () { Navigator.pop(ctx); go(context, const TripPickPage()); }),
    ])),
  );
}

void _done(BuildContext c, String msg) {
  final sm = ScaffoldMessenger.of(c);
  Navigator.of(c).popUntil((r) => r.isFirst);
  sm.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
}

Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 6), child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: CM.ink.withOpacity(.75))));
InputDecoration _dec({String? hint, String? suffix}) => InputDecoration(hintText: hint, suffixText: suffix, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none));
Widget saveBtn(VoidCallback f) => Padding(padding: const EdgeInsets.only(top: 22), child: SizedBox(height: 56, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: CM.butterDeep, foregroundColor: CM.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: f, child: const Text('GUARDAR', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))));

// ---------- Naranja / Revolut: categoría ----------
class CategoryPickPage extends StatelessWidget {
  final String acc;
  const CategoryPickPage(this.acc, {super.key});
  @override
  Widget build(BuildContext context) {
    final cats = acc == 'Naranja' ? catsNaranja : catsRevolut;
    return PageShell('${acc == 'Naranja' ? '🟠' : '⚫'} $acc', ListView(padding: const EdgeInsets.all(18), children: [
      _label('Categoría'),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.45, children: [
        for (final c in cats)
          Material(color: CM.sky, borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => go(context, ExpenseFormPage(acc, c[1])),
              child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(c[0], style: const TextStyle(fontSize: 24)), const SizedBox(height: 6), Text(c[1], style: const TextStyle(fontWeight: FontWeight.w700))])))),
      ]),
      const SizedBox(height: 12),
      Material(color: const Color(0xFFCDEBEF), borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => go(context, TripPickPage(pre: acc)),
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Text('✈️', style: TextStyle(fontSize: 24)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Viajes', style: TextStyle(fontWeight: FontWeight.w700)), Text('Resumen de viajes pagados con $acc', style: const TextStyle(fontSize: 12))]))])))),
    ]));
  }
}

// ---------- Naranja / Revolut: nuevo gasto ----------
class ExpenseFormPage extends StatefulWidget {
  final String acc, cat; final Expense? edit;
  const ExpenseFormPage(this.acc, this.cat, {super.key, this.edit});
  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  String mode = 'dia'; DateTime date = DateTime.now(); String? err;
  final imp = TextEditingController(), obs = TextEditingController();
  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      imp.text = amtText(e.amt); obs.text = e.obs;
      if (e.d != null) { date = DateTime.parse(e.d!); } else { mode = 'mes'; date = DateTime(int.parse(e.m.substring(0, 4)), int.parse(e.m.substring(5)), 1); }
    }
  }
  @override
  void dispose() { imp.dispose(); obs.dispose(); super.dispose(); }

  void _save() {
    final a = double.tryParse(imp.text.replaceAll(',', '.'));
    if (a == null || a <= 0) { setState(() => err = 'Introduce un importe mayor que 0'); return; }
    String? d; String m;
    if (mode == 'dia') { d = isoDate(date); m = d.substring(0, 7); } else if (mode == 'mes') { m = ymKey(date.year, date.month); } else { m = ymKey(ny, nm); }
    store.putExpense(Expense(id: widget.edit?.id ?? uid(), kind: 'casa', acc: widget.acc, cat: widget.cat, amt: a, d: d, m: m, obs: obs.text));
    _done(context, widget.edit != null ? 'Cambios guardados ✓' : 'Gasto guardado ✓');
  }

  @override
  Widget build(BuildContext context) => PageShell(widget.cat, ListView(padding: const EdgeInsets.all(18), children: [
        Text('${widget.edit != null ? 'Editar gasto' : 'Nuevo gasto'} · ${widget.acc == 'Naranja' ? '🟠' : '⚫'} ${widget.acc}', style: const TextStyle(fontWeight: FontWeight.w700)),
        _label('Fecha'),
        SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'dia', label: Text('Día')), ButtonSegment(value: 'mes', label: Text('Solo mes')), ButtonSegment(value: 'sin', label: Text('Sin fecha'))],
          selected: {mode}, onSelectionChanged: (s) => setState(() => mode = s.first),
        ),
        const SizedBox(height: 8),
        if (mode == 'dia') OutlinedButton.icon(icon: const Icon(Icons.calendar_today, size: 18), label: Text(fd(isoDate(date))), onPressed: () async {
          final r = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
          if (r != null) setState(() => date = r);
        }),
        if (mode == 'mes') Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton.filledTonal(onPressed: () => setState(() => date = DateTime(date.year, date.month - 1, 1)), icon: const Icon(Icons.chevron_left)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${cap(mesesL[date.month - 1])} ${date.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          IconButton.filledTonal(onPressed: () => setState(() => date = DateTime(date.year, date.month + 1, 1)), icon: const Icon(Icons.chevron_right)),
        ]),
        if (mode == 'sin') hint('Sin fecha concreta: contará en el mes actual.'),
        _label('Importe *'),
        TextField(controller: imp, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec(hint: '0,00', suffix: '€')),
        if (err != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(err!, style: const TextStyle(color: CM.alert, fontWeight: FontWeight.w600))),
        _label('Observaciones (opcional)'),
        TextField(controller: obs, decoration: _dec(hint: 'Añade una nota')),
        saveBtn(_save),
      ]));
}

// ---------- Viajes: paso 1 (billetes) ----------
class TripPickPage extends StatelessWidget {
  final String? pre;
  const TripPickPage({super.key, this.pre});
  @override
  Widget build(BuildContext context) => PageShell('✈️ Viajes', ListenableBuilder(listenable: store, builder: (_, __) => ListView(padding: const EdgeInsets.all(18), children: [
        _label('¿A dónde viajas?'),
        for (final t in store.trips) TripTicket(t, withTotal: false, onTap: () => go(context, TripExpensePage(t, pre: pre))),
        GestureDetector(
          onTap: () => go(context, NewTripPage(pre: pre)),
          child: Container(
            padding: const EdgeInsets.all(24), alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8FBEDC), width: 2.5)),
            child: const Column(children: [Text('🎫✈️', style: TextStyle(fontSize: 34)), SizedBox(height: 6), Text('Añadir nuevo viaje', style: TextStyle(fontWeight: FontWeight.w800))]),
          ),
        ),
      ])));
}

class NewTripPage extends StatefulWidget {
  final String? pre;
  const NewTripPage({super.key, this.pre});
  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  Place? place; DateTime? d1, d2; String? err;

  Widget _bg() {
    final g = place == null ? null : flagGradients[place!.iso];
    return Stack(children: [
      Positioned.fill(child: Container(decoration: g == null ? const BoxDecoration(color: CM.bg) : BoxDecoration(gradient: g))),
      if (place != null && g == null) Positioned.fill(child: Center(child: Opacity(opacity: .35, child: Text(flagEmoji(place!.iso), style: const TextStyle(fontSize: 380))))),
      if (g != null) Positioned.fill(child: Container(color: CM.bg.withOpacity(.72))),
    ]);
  }

  Widget _dateBtn(String l, DateTime? d, ValueChanged<DateTime> on) => Expanded(
        child: OutlinedButton(onPressed: () async {
          final r = await showDatePicker(context: context, initialDate: d ?? d1 ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
          if (r != null) on(r);
        }, child: Text(d == null ? l : fd(isoDate(d)))),
      );

  void _next() {
    if (place == null) { setState(() => err = 'Elige un lugar de la lista'); return; }
    if (d1 == null || d2 == null) { setState(() => err = 'Indica las dos fechas'); return; }
    if (d2!.isBefore(d1!)) { setState(() => err = 'La vuelta no puede ser antes de la ida'); return; }
    final t = Trip(id: uid(), place: place!.name, iso: place!.iso, country: place!.country, from: isoDate(d1!), to: isoDate(d2!), lat: place!.lat, lon: place!.lon);
    store.putTrip(t);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TripExpensePage(t, pre: widget.pre)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Nuevo viaje', style: TextStyle(fontWeight: FontWeight.w800))),
        body: Stack(children: [
          _bg(),
          SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
            TicketCard(
              top: Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('✈ Billete de avión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CM.ink.withOpacity(.6))),
                _label('Lugar'),
                Autocomplete<Place>(
                  optionsBuilder: (v) => searchPlaces(v.text),
                  displayStringForOption: (p) => p.name,
                  onSelected: (p) => setState(() { place = p; err = null; }),
                  fieldViewBuilder: (ctx, ctl, focus, _) => TextField(controller: ctl, focusNode: focus, decoration: _dec(hint: 'Madrid, Oviedo, Japón…'), onChanged: (_) { if (place != null && place!.name != ctl.text) setState(() => place = null); }),
                  optionsViewBuilder: (ctx, onSel, opts) => Align(alignment: Alignment.topLeft, child: Material(elevation: 4, borderRadius: BorderRadius.circular(14), child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width - 76, maxHeight: 260),
                    child: ListView(padding: EdgeInsets.zero, shrinkWrap: true, children: [for (final p in opts) ListTile(dense: true, leading: flagBox(p.iso), title: Text(p.name), subtitle: Text('${p.type} · ${p.country}'), onTap: () => onSel(p))]),
                  ))),
                ),
                _label('Fechas'),
                Row(children: [_dateBtn('Ida', d1, (v) => setState(() => d1 = v)), const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('—')), _dateBtn('Vuelta', d2, (v) => setState(() => d2 = v))]),
              ])),
              stub: const Barcode(),
            ),
            if (err != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(err!, style: const TextStyle(color: CM.alert, fontWeight: FontWeight.w600))),
            SizedBox(height: 56, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: CM.butterDeep, foregroundColor: CM.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: _next, child: const Text('SIGUIENTE →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))),
          ])),
        ]),
      );
}

// ---------- Viajes: paso 2 (gasto) ----------
class TripExpensePage extends StatefulWidget {
  final Trip trip; final String? pre; final Expense? edit;
  const TripExpensePage(this.trip, {super.key, this.pre, this.edit});
  @override
  State<TripExpensePage> createState() => _TripExpensePageState();
}

class _TripExpensePageState extends State<TripExpensePage> {
  late String cat = '${tripCats[0][0]} ${tripCats[0][1]}';
  String? who; DateTime date = DateTime.now(); String? err;
  final imp = TextEditingController(), obs = TextEditingController();
  @override
  void initState() {
    super.initState();
    who = widget.pre;
    final e = widget.edit;
    if (e != null) { cat = e.cat; who = e.to; imp.text = amtText(e.amt); obs.text = e.obs; if (e.d != null) date = DateTime.parse(e.d!); }
  }
  @override
  void dispose() { imp.dispose(); obs.dispose(); super.dispose(); }

  void _save() {
    final a = double.tryParse(imp.text.replaceAll(',', '.'));
    if (a == null || a <= 0) { setState(() => err = 'Introduce un importe mayor que 0'); return; }
    if (who == null) { setState(() => err = 'Elige a quién corresponde'); return; }
    final d = isoDate(date);
    store.putExpense(Expense(id: widget.edit?.id ?? uid(), kind: 'trip', trip: widget.trip.id, cat: cat, to: who, amt: a, d: d, m: d.substring(0, 7), obs: obs.text));
    _done(context, widget.edit != null ? 'Cambios guardados ✓' : 'Gasto de viaje guardado ✓');
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    return PageShell('Gasto del viaje', ListView(padding: const EdgeInsets.all(18), children: [
      TicketCard(top: Padding(padding: const EdgeInsets.all(16), child: Row(children: [flagBox(t.iso), const SizedBox(width: 10), Expanded(child: Text(t.place, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), Text(rng(t.from, t.to), style: TextStyle(color: CM.ink.withOpacity(.6)))]))),
      _label('Categoría'),
      DropdownButtonFormField<String>(value: cat, decoration: _dec(), items: [for (final c in tripCats) DropdownMenuItem(value: '${c[0]} ${c[1]}', child: Text('${c[0]} ${c[1]}'))], onChanged: (v) => setState(() => cat = v ?? cat)),
      _label('Importe *'),
      TextField(controller: imp, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec(hint: '0,00', suffix: '€')),
      _label('Corresponde a'),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final w in whoList) ChoiceChip(label: Text('${w[0]} ${w[1]}', style: const TextStyle(fontWeight: FontWeight.w700)), selected: who == w[1], selectedColor: CM.butter, onSelected: (_) => setState(() => who = w[1]))]),
      _label('Fecha'),
      OutlinedButton.icon(icon: const Icon(Icons.calendar_today, size: 18), label: Text(fd(isoDate(date))), onPressed: () async {
        final r = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (r != null) setState(() => date = r);
      }),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: CM.alert, fontWeight: FontWeight.w600))),
      _label('Observaciones (opcional)'),
      TextField(controller: obs, decoration: _dec(hint: 'Añade una nota')),
      saveBtn(_save),
    ]));
  }
}

// ---------- ingreso extra ----------
void showExtraSheet(BuildContext context, String acc, int y, int m) {
  showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: CM.bg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => _ExtraForm(acc, y, m),
  );
}

class _ExtraForm extends StatefulWidget {
  final String acc; final int y, m;
  const _ExtraForm(this.acc, this.y, this.m);
  @override
  State<_ExtraForm> createState() => _ExtraFormState();
}

class _ExtraFormState extends State<_ExtraForm> {
  final imp = TextEditingController(), obs = TextEditingController(); String? err;
  @override
  void dispose() { imp.dispose(); obs.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ingreso extra · ${widget.acc}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text('${cap(mesesL[widget.m - 1])} ${widget.y}', style: TextStyle(color: CM.ink.withOpacity(.7))),
          _label('Importe *'),
          TextField(controller: imp, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec(hint: '0,00', suffix: '€')),
          if (err != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(err!, style: const TextStyle(color: CM.alert, fontWeight: FontWeight.w600))),
          _label('Observaciones (opcional)'),
          TextField(controller: obs, decoration: _dec(hint: 'Ej. reintegro, regalo…')),
          saveBtn(() {
            final a = double.tryParse(imp.text.replaceAll(',', '.'));
            if (a == null || a <= 0) { setState(() => err = 'Introduce un importe mayor que 0'); return; }
            store.putExtra(Extra(id: uid(), acc: widget.acc, m: ymKey(widget.y, widget.m), amt: a, obs: obs.text));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingreso extra añadido ✓')));
          }),
        ]),
      );
}

// ---------- detalle de gasto ----------
class ExpenseDetailPage extends StatelessWidget {
  final String id;
  const ExpenseDetailPage(this.id, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) {
        Expense? e;
        for (final x in store.E) { if (x.id == id) e = x; }
        if (e == null) return const Scaffold(body: Center(child: Text('Gasto no encontrado')));
        final x = e, t = tripById(x.trip);
        final rows = <(String, String)>[
          ('Fecha', x.d != null ? fd(x.d!) : 'Solo mes · ${mesesL[int.parse(x.m.substring(5)) - 1]}'),
          ('Importe', eur(x.amt, d: 2)), ('Categoría', x.cat),
          (x.isTrip ? 'Corresponde a' : 'Cuenta', (x.isTrip ? x.to : x.acc) ?? ''),
          ('Observaciones', x.obs.isEmpty ? '—' : x.obs),
          if (t != null) ('Viaje', '${t.place} · ${rng(t.from, t.to)}'),
        ];
        return PageShell('Detalle del gasto', ListView(padding: const EdgeInsets.all(18), children: [
          whiteCard(pad: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Column(children: [
            for (final r in rows) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.$1, style: TextStyle(fontSize: 12, color: CM.ink.withOpacity(.6))), Text(r.$2, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]))),
          ])),
          const SizedBox(height: 12),
          SizedBox(height: 54, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: CM.butterDeep, foregroundColor: CM.ink), onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => x.isTrip && t != null ? TripExpensePage(t, edit: x) : ExpenseFormPage(x.acc ?? 'Naranja', x.cat, edit: x)));
          }, child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.w800)))),
          const SizedBox(height: 10),
          SizedBox(height: 54, child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: CM.alert, side: const BorderSide(color: CM.alert, width: 2)), onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('¿Eliminar gasto?'), content: const Text('Esta acción no se puede deshacer.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar'))]));
            if (ok == true) { store.delExpense(x.id); if (context.mounted) Navigator.pop(context); }
          }, child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w800)))),
        ]));
      });
}
