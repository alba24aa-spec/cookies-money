import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'models.dart';
import 'util.dart';

final store = Store();

/// Datos compartidos: Firestore (tiempo real + caché sin conexión) o modo local.
class Store extends ChangeNotifier {
  List<Expense> E = [], _rE = [];
  List<Trip> trips = [], _rT = [];
  List<Extra> EX = [], _rX = [];
  bool demo = false;
  String sync = 'loading'; // loading | ok | local | err | signedout
  FirebaseFirestore? _db;
  late final (List<Expense>, List<Trip>, List<Extra>) _d = demoData();

  bool get empty => E.isEmpty && trips.isEmpty;

  final List<StreamSubscription<dynamic>> _subs = [];

  Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _db = FirebaseFirestore.instance;
      FirebaseAuth.instance.authStateChanges().listen((u) {
        for (final s in _subs) { s.cancel(); }
        _subs.clear();
        if (u == null) { _rE = []; _rT = []; _rX = []; sync = 'signedout'; } else { _attach(); sync = 'ok'; }
        _apply();
      });
    } catch (e) {
      sync = 'local';
      _apply();
    }
  }

  void _attach() {
    _subs.addAll([
      _db!.collection('expenses').snapshots().listen((s) { _rE = s.docs.map((d) => Expense.fromMap(d.data())).toList(); _apply(); }, onError: (_) => _err()),
      _db!.collection('trips').snapshots().listen((s) { _rT = s.docs.map((d) => Trip.fromMap(d.data())).toList(); _apply(); }, onError: (_) => _err()),
      _db!.collection('extras').snapshots().listen((s) { _rX = s.docs.map((d) => Extra.fromMap(d.data())).toList(); _apply(); }, onError: (_) => _err()),
    ]);
  }

  Future<String?> signIn(String email, String pw) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: pw);
      return null;
    } on FirebaseAuthException {
      return 'Correo o contraseña incorrectos';
    } catch (_) {
      return 'No se pudo entrar. Revisa la conexión.';
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  void _err() { sync = 'err'; notifyListeners(); }

  void _apply() {
    if (demo) { E = _d.$1; trips = _d.$2; EX = _d.$3; } else { E = _rE; trips = _rT; EX = _rX; }
    notifyListeners();
  }

  void setDemo(bool v) { demo = v; _apply(); }

  bool get _remote => _db != null && !demo;

  void _set(String col, String id, Map<String, dynamic> m) {
    _db!.collection(col).doc(id).set(m).catchError((Object _) { _err(); });
  }

  void putExpense(Expense e) {
    if (_remote) { _set('expenses', e.id, e.toMap()); return; }
    final l = demo ? _d.$1 : _rE; final i = l.indexWhere((x) => x.id == e.id);
    i < 0 ? l.add(e) : l[i] = e; _apply();
  }

  void delExpense(String id) {
    if (_remote) { _db!.collection('expenses').doc(id).delete(); return; }
    (demo ? _d.$1 : _rE).removeWhere((x) => x.id == id); _apply();
  }

  void putTrip(Trip t) {
    if (_remote) { _set('trips', t.id, t.toMap()); return; }
    (demo ? _d.$2 : _rT).add(t); _apply();
  }

  void putExtra(Extra x) {
    if (_remote) { _set('extras', x.id, x.toMap()); return; }
    (demo ? _d.$3 : _rX).add(x); _apply();
  }
}

double _rnd(num a, num b) { final x = sin(a * 12.9898 + b * 78.233) * 43758.5453; return x - x.floorToDouble(); }

(List<Expense>, List<Trip>, List<Extra>) demoData() {
  final e = <Expense>[]; var n = 0; final nd = DateTime.now().day;
  final trips = [
    Trip(id: 't1', place: 'Lisboa', iso: 'PT', country: 'Portugal', from: '$ny-05-14', to: '$ny-05-17', lat: 38.72, lon: -9.14),
    Trip(id: 't2', place: 'Roma', iso: 'IT', country: 'Italia', from: '$ny-03-12', to: '$ny-03-15', lat: 41.9, lon: 12.5),
    Trip(id: 't3', place: 'Madrid', iso: 'ES', country: 'España', from: '${ny - 1}-11-27', to: '${ny - 1}-11-29', lat: 40.42, lon: -3.7),
  ];
  final ex = [
    Extra(id: 'x1', acc: 'Naranja', m: '$ny-03', amt: 200, obs: 'Reintegro'),
    Extra(id: 'x2', acc: 'Revolut', m: '$ny-02', amt: 100, obs: 'Ingreso puntual'),
  ];
  final base = <String, List<(String, double, double)>>{
    'Naranja': [('Alquiler', 650, 0), ('Agua y Calefacción', 85, 40), ('Octopus', 48, 14), ('Garaje', 70, 0), ('GoFit', 39, 0), ('Ikea Visa', 60, 45), ('DiGi', 25, 0), ('Otros', 30, 40)],
    'Revolut': [('Alimentación', 290, 70), ('Grow Nutrition', 45, 10), ('Sirius y Bruma', 55, 25), ('Restaurantes', 95, 45), ('Vermutinos', 32, 18), ('Eventos', 40, 60), ('Farmacia', 22, 15), ('Otras compras', 60, 60)],
  };
  for (final y in [ny - 1, ny]) {
    for (var mo = 1; mo <= (y < ny ? 12 : nm); mo++) {
      base.forEach((acc, l) {
        for (var i = 0; i < l.length; i++) {
          final (cat, b, v) = l[i];
          final day = 2 + i * 3 + (acc == 'Revolut' ? 1 : 0);
          if (y == ny && mo == nm && day > nd) continue;
          final f = y < ny ? (v > 0 ? .8 + _rnd(i + 3, mo) * .32 : .92) : 1.0;
          final amt = max(8.0, ((b + (_rnd(mo + y, i + acc.length) - .5) * 2 * v) * f).roundToDouble());
          e.add(Expense(id: 'd${++n}', kind: 'casa', acc: acc, cat: cat, amt: amt, d: '$y-${pad2(mo)}-${pad2(day)}', m: ymKey(y, mo)));
        }
      });
    }
  }
  const tx = [
    ('t1', '🏨 Hotel', 'Naranja', 340.0, '05-14'), ('t1', '🚗 Desplazamiento', 'Revolut', 180.0, '05-14'), ('t1', '🍽️ Comer', 'Alba', 120.0, '05-15'), ('t1', '🍴 Cenar', 'David', 80.0, '05-16'),
    ('t2', '🏨 Hotel', 'Naranja', 200.0, '03-12'), ('t2', '🍽️ Comer', 'Revolut', 70.0, '03-13'), ('t2', '🎟️ Entradas', 'Alba', 50.0, '03-14'),
    ('t3', '🏨 Hotel', 'Naranja', 300.0, '11-27'), ('t3', '🎟️ Entradas', 'Revolut', 80.0, '11-27'), ('t3', '🍽️ Comer', 'Alba', 70.0, '11-28'), ('t3', '🍹 Tomar algo', 'David', 15.0, '11-28'),
  ];
  for (final (t, cat, to, amt, md) in tx) {
    final y = t == 't3' ? ny - 1 : ny;
    e.add(Expense(id: 'd${++n}', kind: 'trip', trip: t, cat: cat, to: to, amt: amt, d: '$y-$md', m: '$y-${md.substring(0, 2)}'));
  }
  return (e, trips, ex);
}
