import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUNnhDRGGKH-UhgAdanTd5_5KQkmu-p70',
    appId: '1:13266334210:android:8dc01c937d4d9f7153ed1b',
    messagingSenderId: '13266334210',
    projectId: 'ethicfin-task-manager-4ca74',
    storageBucket: 'ethicfin-task-manager-4ca74.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUNnhDRGGKH-UhgAdanTd5_5KQkmu-p70',
    appId: '1:13266334210:android:8dc01c937d4d9f7153ed1b',
    messagingSenderId: '13266334210',
    projectId: 'ethicfin-task-manager-4ca74',
    storageBucket: 'ethicfin-task-manager-4ca74.firebasestorage.app',
  );
}
