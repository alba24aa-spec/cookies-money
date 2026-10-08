import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    const o = FirebaseOptions(
      apiKey: 'AIzaSyBNhkWccqkiGwX65rHodkX3FRrQA7zamdg',
      appId: '1:396177581568:web:d02ca6c0d461e4f5135ae5',
      messagingSenderId: '396177581568',
      projectId: 'cookies-money',
      authDomain: 'cookies-money.firebaseapp.com',
      storageBucket: 'cookies-money.firebasestorage.app',
    );
    if (o.apiKey.startsWith('PEGA')) throw UnsupportedError('Firebase sin configurar');
    return o;
  }
}
