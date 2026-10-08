import 'dart:math';

const mesesL = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
const mesesC = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
final ny = DateTime.now().year, nm = DateTime.now().month;

String eur(num n, {int d = 0}) {
  final s = n.abs().toStringAsFixed(d);
  final p = s.split('.');
  final ip = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  return '${n < 0 ? '-' : ''}$ip${d > 0 ? ',${p[1]}' : ''} €';
}

String pad2(int n) => n.toString().padLeft(2, '0');
String ymKey(int y, int m) => '$y-${pad2(m)}';
String isoDate(DateTime d) => '${d.year}-${pad2(d.month)}-${pad2(d.day)}';
String fd(String s) => s.split('-').reversed.join('/');
String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String amtText(double a) => a == a.roundToDouble() ? a.round().toString() : a.toString().replaceAll('.', ',');

String rng(String from, String to) {
  final a = from.split('-'), b = to.split('-');
  final m1 = mesesC[int.parse(a[1]) - 1].toLowerCase(), m2 = mesesC[int.parse(b[1]) - 1].toLowerCase();
  return a[1] == b[1]
      ? '${int.parse(a[2])}–${int.parse(b[2])} $m1'
      : '${int.parse(a[2])} $m1 – ${int.parse(b[2])} $m2';
}

final _r = Random();
String uid() => DateTime.now().millisecondsSinceEpoch.toRadixString(36) + _r.nextInt(1 << 20).toRadixString(36);

const catsNaranja = [['🏠','Alquiler'],['🚿','Agua y Calefacción'],['⚡','Octopus'],['🚗','Garaje'],['🏋️','GoFit'],['🛋️','Ikea Visa'],['📱','DiGi'],['📦','Otros']];
const catsRevolut = [['🛒','Alimentación'],['💪','Grow Nutrition'],['🐾','Sirius y Bruma'],['🍽️','Restaurantes'],['🥂','Vermutinos'],['🎉','Eventos'],['💊','Farmacia'],['🛍️','Otras compras']];
const tripCats = [['🏨','Hotel'],['🚗','Desplazamiento'],['🎟️','Entradas'],['🍽️','Comer'],['☕','Desayunar'],['🍴','Cenar'],['🍹','Tomar algo'],['🛍️','Otros']];
const whoList = [['🟠','Naranja'],['⚫','Revolut'],['👩','Alba'],['👨','David']];
const income = {'Naranja': 1000.0, 'Revolut': 600.0};
