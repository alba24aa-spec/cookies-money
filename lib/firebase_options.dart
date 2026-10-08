// Rellena estos valores con los de tu app web de Firebase
// (Configuración del proyecto -> Tus apps -> Web -> firebaseConfig).
// Mientras digan PEGA_AQUI la app funciona en modo local, sin sincronizar.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    const o = FirebaseOptions(
      apiKey: 'PEGA_AQUI',
      appId: 'PEGA_AQUI',
      messagingSenderId: 'PEGA_AQUI',
      projectId: 'PEGA_AQUI',
      authDomain: 'PEGA_AQUI',
      storageBucket: 'PEGA_AQUI',
    );
    if (o.apiKey.startsWith('PEGA')) throw UnsupportedError('Firebase sin configurar');
    return o;
  }
}
