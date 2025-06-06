// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyAd45W_jGOUiuUBZAag8AFgZ6r2OUBgEio', // Ganti dengan API key yang sebenarnya
    appId:
        '1:370180813728:android:3347480006ceadbd746ac5', // Ganti dengan App ID yang sebenarnya
    messagingSenderId: '370180813728', // Ganti dengan Sender ID yang sebenarnya
    projectId: 'glozy-salon',
    storageBucket: 'glozy-salon.appspot.com',
  );
}
