class Expense {
  final String id, kind, cat, m, obs;
  final String? acc, to, trip, d;
  final double amt;
  const Expense({required this.id, required this.kind, required this.cat, required this.amt, required this.m, this.d, this.acc, this.to, this.trip, this.obs = ''});
  bool get isTrip => kind == 'trip';
  Map<String, dynamic> toMap() => {'id': id, 'kind': kind, 'cat': cat, 'amt': amt, 'm': m, 'd': d, 'acc': acc, 'to': to, 'trip': trip, 'obs': obs};
  factory Expense.fromMap(Map<String, dynamic> x) => Expense(
      id: x['id'] as String, kind: x['kind'] as String, cat: x['cat'] as String,
      amt: (x['amt'] as num).toDouble(), m: x['m'] as String, d: x['d'] as String?,
      acc: x['acc'] as String?, to: x['to'] as String?, trip: x['trip'] as String?,
      obs: (x['obs'] as String?) ?? '');
}

class Trip {
  final String id, place, iso, country, from, to;
  final double lat, lon;
  const Trip({required this.id, required this.place, required this.iso, required this.country, required this.from, required this.to, this.lat = 0, this.lon = 0});
  Map<String, dynamic> toMap() => {'id': id, 'place': place, 'iso': iso, 'country': country, 'from': from, 'to': to, 'lat': lat, 'lon': lon};
  factory Trip.fromMap(Map<String, dynamic> x) => Trip(
      id: x['id'] as String, place: x['place'] as String, iso: x['iso'] as String,
      country: x['country'] as String, from: x['from'] as String, to: x['to'] as String,
      lat: (x['lat'] as num?)?.toDouble() ?? 0, lon: (x['lon'] as num?)?.toDouble() ?? 0);
}

class Extra {
  final String id, acc, m, obs;
  final double amt;
  const Extra({required this.id, required this.acc, required this.m, required this.amt, this.obs = ''});
  Map<String, dynamic> toMap() => {'id': id, 'acc': acc, 'm': m, 'amt': amt, 'obs': obs};
  factory Extra.fromMap(Map<String, dynamic> x) => Extra(
      id: x['id'] as String, acc: x['acc'] as String, m: x['m'] as String,
      amt: (x['amt'] as num).toDouble(), obs: (x['obs'] as String?) ?? '');
}
