import 'package:flutter/material.dart';
import '../data/store.dart';
import '../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(), pw = TextEditingController();
  String? err; bool busy = false;

  Future<void> _go() async {
    setState(() { busy = true; err = null; });
    final e = await store.signIn(email.text, pw.text);
    if (mounted) setState(() { busy = false; err = e; });
  }

  InputDecoration _d(String h) => InputDecoration(hintText: h, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none));

  @override
  void dispose() { email.dispose(); pw.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/icon/icon.png', width: 110, height: 110)),
                const SizedBox(height: 16),
                const Text('Cookies & Milk 💰', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                TextField(controller: email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: _d('Correo electrónico')),
                const SizedBox(height: 12),
                TextField(controller: pw, obscureText: true, autofillHints: const [AutofillHints.password], onSubmitted: (_) => _go(), decoration: _d('Contraseña')),
                if (err != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(err!, style: const TextStyle(color: CM.alert, fontWeight: FontWeight.w600))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 54, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: CM.butterDeep, foregroundColor: CM.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: busy ? null : _go, child: Text(busy ? 'Entrando…' : 'ENTRAR', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))),
              ]),
            ),
          ),
        ),
      );
}
