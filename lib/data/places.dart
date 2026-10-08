import 'package:latlong2/latlong.dart';
import 'models.dart';

class Place {
  final String name, iso, country, type;
  final double lat, lon;
  const Place(this.name, this.iso, this.country, this.type, this.lat, this.lon);
}

const _prov = 'Álava:42.85,-2.67;Albacete:39,-1.86;Alicante:38.35,-0.48;Almería:36.84,-2.46;Asturias:43.36,-5.85;Ávila:40.66,-4.7;Badajoz:38.88,-6.97;Baleares:39.57,2.65;Barcelona:41.39,2.17;Burgos:42.34,-3.7;Cáceres:39.47,-6.37;Cádiz:36.53,-6.29;Cantabria:43.46,-3.8;Castellón:39.99,-0.05;Ciudad Real:38.99,-3.93;Córdoba:37.89,-4.78;A Coruña:43.37,-8.4;Cuenca:40.07,-2.13;Girona:41.98,2.82;Granada:37.18,-3.6;Guadalajara:40.63,-3.17;Gipuzkoa:43.32,-1.98;Huelva:37.26,-6.95;Huesca:42.14,-0.41;Jaén:37.78,-3.79;León:42.6,-5.57;Lleida:41.62,0.62;Lugo:43.01,-7.56;Madrid:40.42,-3.7;Málaga:36.72,-4.42;Murcia:37.99,-1.13;Navarra:42.82,-1.64;Ourense:42.34,-7.86;Palencia:42.01,-4.53;Las Palmas:28.12,-15.43;Pontevedra:42.43,-8.64;La Rioja:42.47,-2.45;Salamanca:40.97,-5.66;Santa Cruz de Tenerife:28.47,-16.25;Segovia:40.95,-4.12;Sevilla:37.39,-5.98;Soria:41.76,-2.47;Tarragona:41.12,1.25;Teruel:40.34,-1.11;Toledo:39.86,-4.02;Valencia:39.47,-0.38;Valladolid:41.65,-4.72;Bizkaia:43.26,-2.93;Zamora:41.5,-5.75;Zaragoza:41.65,-0.89';
const _muni = 'Oviedo:43.36,-5.85;Gijón:43.53,-5.66;Avilés:43.55,-5.92;Santander:43.46,-3.8;Bilbao:43.26,-2.93;San Sebastián:43.32,-1.98;Santiago de Compostela:42.88,-8.54;Marbella:36.51,-4.88;Benidorm:38.54,-0.13;Sitges:41.24,1.81;Ronda:36.74,-5.17;Ibiza:38.91,1.43;Palma de Mallorca:39.57,2.65;Vigo:42.24,-8.72';
const _cities = 'París:FR:Francia:48.86,2.35;Niza:FR:Francia:43.7,7.26;Roma:IT:Italia:41.9,12.5;Florencia:IT:Italia:43.77,11.25;Venecia:IT:Italia:45.44,12.32;Milán:IT:Italia:45.46,9.19;Lisboa:PT:Portugal:38.72,-9.14;Oporto:PT:Portugal:41.15,-8.61;Berlín:DE:Alemania:52.52,13.4;Múnich:DE:Alemania:48.14,11.58;Ámsterdam:NL:Países Bajos:52.37,4.9;Bruselas:BE:Bélgica:50.85,4.35;Brujas:BE:Bélgica:51.21,3.22;Londres:GB:Reino Unido:51.51,-0.13;Edimburgo:GB:Reino Unido:55.95,-3.19;Dublín:IE:Irlanda:53.35,-6.26;Viena:AT:Austria:48.21,16.37;Praga:CZ:Chequia:50.08,14.44;Budapest:HU:Hungría:47.5,19.04;Cracovia:PL:Polonia:50.06,19.94;Atenas:GR:Grecia:37.98,23.73;Estambul:TR:Turquía:41.01,28.98;Marrakech:MA:Marruecos:31.63,-8;Tokio:JP:Japón:35.68,139.69;Kioto:JP:Japón:35.01,135.77;Nueva York:US:Estados Unidos:40.71,-74;Miami:US:Estados Unidos:25.76,-80.19;Ciudad de México:MX:México:19.43,-99.13;Buenos Aires:AR:Argentina:-34.6,-58.38;Reikiavik:IS:Islandia:64.15,-21.94;Copenhague:DK:Dinamarca:55.68,12.57';
const _countries = 'España:ES:40,-3.7;Francia:FR:46.6,2.4;Italia:IT:42.8,12.5;Portugal:PT:39.6,-8;Alemania:DE:51,10;Países Bajos:NL:52.2,5.3;Bélgica:BE:50.6,4.6;Reino Unido:GB:54,-2;Irlanda:IE:53,-8;Austria:AT:47.5,14.5;Polonia:PL:52,19;Grecia:GR:39,22;Hungría:HU:47,19.5;Chequia:CZ:49.8,15.5;Marruecos:MA:31.8,-7;Japón:JP:36,138;Estados Unidos:US:39,-98;México:MX:23,-102;Argentina:AR:-34,-64;Brasil:BR:-10,-52;Tailandia:TH:15,101;Islandia:IS:65,-18;Noruega:NO:61,9;Suecia:SE:62,15;Dinamarca:DK:56,10;Suiza:CH:46.8,8.2;Croacia:HR:45.1,15.2;Turquía:TR:39,35';

List<double> _ll(String s) { final p = s.split(','); return [double.parse(p[0]), double.parse(p[1])]; }

final List<Place> places = () {
  final l = <Place>[];
  for (final s in _prov.split(';')) { final i = s.lastIndexOf(':'); final c = _ll(s.substring(i + 1)); l.add(Place(s.substring(0, i), 'ES', 'España', 'Provincia', c[0], c[1])); }
  for (final s in _muni.split(';')) { final i = s.lastIndexOf(':'); final c = _ll(s.substring(i + 1)); l.add(Place(s.substring(0, i), 'ES', 'España', 'Municipio', c[0], c[1])); }
  for (final s in _cities.split(';')) { final p = s.split(':'); final c = _ll(p[3]); l.add(Place(p[0], p[1], p[2], 'Ciudad', c[0], c[1])); }
  for (final s in _countries.split(';')) { final p = s.split(':'); final c = _ll(p[2]); l.add(Place(p[0], p[1], p[0], 'País', c[0], c[1])); }
  return l;
}();

String _norm(String s) {
  const a = 'áàäâéèëêíìïîóòöôúùüûñÁÉÍÓÚÑ', b = 'aaaaeeeeiiiioooouuuunAEIOUN';
  var r = s.toLowerCase();
  for (var i = 0; i < a.length; i++) { r = r.replaceAll(a[i].toLowerCase(), b[i].toLowerCase()); }
  return r;
}

List<Place> searchPlaces(String q) {
  final n = _norm(q.trim());
  if (n.isEmpty) return const [];
  final m = places.where((p) => _norm(p.name).contains(n)).toList();
  m.sort((a, b) => (_norm(b.name).startsWith(n) ? 1 : 0) - (_norm(a.name).startsWith(n) ? 1 : 0));
  return m.take(6).toList();
}

LatLng tripLatLng(Trip t) {
  if (t.lat != 0 || t.lon != 0) return LatLng(t.lat, t.lon);
  for (final p in places) { if (p.name == t.place) return LatLng(p.lat, p.lon); }
  return const LatLng(0, 0);
}
