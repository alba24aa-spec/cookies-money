import 'package:flutter/material.dart';
import 'data/store.dart';
import 'screens/flows.dart';
import 'screens/login.dart';
import 'screens/screens.dart';
import 'theme.dart';
import 'ui/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  store.init(); // arranca la sincronización sin bloquear la interfaz
  runApp(const CookiesMilkApp());
}

class CookiesMilkApp extends StatelessWidget {
  const CookiesMilkApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Cookies & Milk', debugShowCheckedModeBanner: false, theme: CM.theme(), home: ListenableBuilder(listenable: store, builder: (_, __) => store.sync == 'signedout' ? const LoginPage() : const Shell()));
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0; // 0 inicio · 1 naranja · 3 revolut · 4 viajes · 5 resumen
  static const order = [0, 1, 3, 4, 5];

  Future<void> _logout() async {
    if (store.sync != 'ok') return;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('¿Cerrar sesión?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión'))]));
    if (ok == true) store.signOut();
  }

  Widget _nav(int t, String l, Widget icon) => Expanded(
        child: InkWell(
          onTap: () => setState(() => tab = t),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(height: 34, constraints: const BoxConstraints(minWidth: 50), alignment: Alignment.center, decoration: BoxDecoration(color: tab == t ? CM.butter : Colors.transparent, borderRadius: BorderRadius.circular(17)), child: icon),
            Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: GestureDetector(
            onTap: () => setState(() => tab = 0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/icon/icon.png', width: 38, height: 38)),
              const SizedBox(width: 10),
              const Text('Cookies & Milk 💰', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
            ]),
          ),
          actions: [
            ListenableBuilder(listenable: store, builder: (_, __) {
              final c = {'ok': green, 'err': CM.alert}[store.sync] ?? const Color(0xFF9AA5B1);
              return GestureDetector(onTap: _logout, child: Padding(padding: const EdgeInsets.all(16), child: Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle))));
            }),
          ],
        ),
        body: IndexedStack(index: order.indexOf(tab), children: const [
          HomeScreen(), AccountScreen('Naranja'), AccountScreen('Revolut'), ViajesScreen(), ResumenScreen(),
        ]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: CM.butterDeep, foregroundColor: const Color(0xFF3E86B5), shape: const CircleBorder(),
          onPressed: () => openAddSheet(context), child: const Icon(Icons.add, size: 34),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.white, shape: const CircularNotchedRectangle(), notchMargin: 8, padding: EdgeInsets.zero, height: 74,
          child: Row(children: [
            _nav(5, 'Resumen', const Text('💰', style: TextStyle(fontSize: 26))),
            _nav(1, 'Naranja', const CardIcon(CM.orange)),
            const SizedBox(width: 84),
            _nav(3, 'Revolut', const CardIcon(Color(0xFF15171A))),
            _nav(4, 'Viajes', const Icon(Icons.flight, color: Color(0xFF2FA3BA), size: 30)),
          ]),
        ),
      );
}
