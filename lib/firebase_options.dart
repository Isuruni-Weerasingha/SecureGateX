import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBM5b7iappAfrCVhbGxo3OzQVFasA_jmiQ',
    appId: '1:214591992332:web:ae7cbca421795701b1b429',
    messagingSenderId: '214591992332',
    projectId: 'gatex-9d1bd',
    authDomain: 'gatex-9d1bd.firebaseapp.com',
    storageBucket: 'gatex-9d1bd.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBM5b7iappAfrCVhbGxo3OzQVFasA_jmiQ',
    appId: '1:214591992332:android:ae7cbca421795701b1b429',
    messagingSenderId: '214591992332',
    projectId: 'gatex-9d1bd',
    storageBucket: 'gatex-9d1bd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBM5b7iappAfrCVhbGxo3OzQVFasA_jmiQ',
    appId: '1:214591992332:ios:your-ios-app-id',
    messagingSenderId: '214591992332',
    projectId: 'gatex-9d1bd',
    storageBucket: 'gatex-9d1bd.firebasestorage.app',
    iosBundleId: 'com.example.secureGatex',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBM5b7iappAfrCVhbGxo3OzQVFasA_jmiQ',
    appId: '1:214591992332:macos:your-macos-app-id',
    messagingSenderId: '214591992332',
    projectId: 'gatex-9d1bd',
    storageBucket: 'gatex-9d1bd.firebasestorage.app',
    iosBundleId: 'com.example.secureGatex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBM5b7iappAfrCVhbGxo3OzQVFasA_jmiQ',
    appId: '1:214591992332:windows:your-windows-app-id',
    messagingSenderId: '214591992332',
    projectId: 'gatex-9d1bd',
    storageBucket: 'gatex-9d1bd.firebasestorage.app',
  );
}

