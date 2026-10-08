import 'models.dart';
import 'store.dart';
import 'util.dart';

class CatV { final String e, n; final double v; const CatV(this.e, this.n, this.v); }

int elapsed(int y) => y < ny ? 12 : (y == ny ? nm : 1);

/// Meses completos ya pasados (año anterior + este año hasta el mes anterior).
final List<List<int>> past = [for (var y = ny - 1; y <= ny; y++) for (var m = 1; m <= 12; m++) if (y < ny || m < nm) [y, m]];

Trip? tripById(String? id) { for (final t in store.trips) { if (t.id == id) return t; } return null; }

extension Calc on Store {
  bool _in(Expense e, int y, int? m) => m == null ? e.m.startsWith('$y-') : e.m == ymKey(y, m);
  List<Expense> cas(String a, int y, [int? m]) => E.where((e) => e.kind == 'casa' && e.acc == a && _in(e, y, m)).toList();
  List<Expense> trp(String? to, int y, [int? m]) => E.where((e) => e.kind == 'trip' && (to == null || e.to == to) && _in(e, y, m)).toList();
  double sum(Iterable<Expense> l) => l.fold(0.0, (s, e) => s + e.amt);
  double accT(String a, int y, [int? m]) => sum(cas(a, y, m)) + sum(trp(a, y, m));
  double real(int y, [int? m]) => accT('Naranja', y, m) + accT('Revolut', y, m) + sum(trp('Alba', y, m)) + sum(trp('David', y, m));
  double tripTot(String id) => sum(E.where((e) => e.trip == id));
  List<CatV> cats(String a, int y, [int? m]) {
    final l = (a == 'Naranja' ? catsNaranja : catsRevolut).map((c) => CatV(c[0], c[1], sum(cas(a, y, m).where((x) => x.cat == c[1])))).toList();
    l.add(CatV('✈️', 'Viajes', sum(trp(a, y, m))));
    return l;
  }
  double cm(String a, String c, int y, int m) => c == 'Viajes' ? sum(trp(a, y, m)) : sum(cas(a, y, m).where((x) => x.cat == c));
  double hAvg(String a, [String? c]) => past.isEmpty ? 0 : past.fold(0.0, (s, p) => s + (c == null ? accT(a, p[0], p[1]) : cm(a, c, p[0], p[1]))) / past.length;
  double yAvg(String a, String c, int y) {
    final n = y < ny ? 12 : (nm - 1 < 1 ? 1 : nm - 1);
    var s = 0.0;
    for (var m = 1; m <= n; m++) { s += cm(a, c, y, m); }
    return s / n;
  }
  List<Extra> exs(String a, int y, [int? m]) => EX.where((x) => x.acc == a && (m == null ? x.m.startsWith('$y-') : x.m == ymKey(y, m))).toList();
  double sumX(Iterable<Extra> l) => l.fold(0.0, (s, x) => s + x.amt);
  List<Expense> sorted(List<Expense> l) { final r = [...l]; r.sort((a, b) => (b.d ?? '${b.m}-00').compareTo(a.d ?? '${a.m}-00')); return r; }
}
