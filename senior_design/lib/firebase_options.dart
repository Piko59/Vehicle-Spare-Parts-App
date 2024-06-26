// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDKbsv5TpsCGfJp8rH4yPsTK9UXcoe899I',
    appId: '1:28298063071:web:5a13bbdb83ca747d578d6a',
    messagingSenderId: '28298063071',
    projectId: 'vehicle-spare-parts-app',
    authDomain: 'vehicle-spare-parts-app.firebaseapp.com',
    databaseURL: 'https://vehicle-spare-parts-app-default-rtdb.firebaseio.com',
    storageBucket: 'vehicle-spare-parts-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7T5LtBJMwU84xPR-E6aHYNVhOGm7EL1k',
    appId: '1:28298063071:android:b3a2be3e0e629a44578d6a',
    messagingSenderId: '28298063071',
    projectId: 'vehicle-spare-parts-app',
    databaseURL: 'https://vehicle-spare-parts-app-default-rtdb.firebaseio.com',
    storageBucket: 'vehicle-spare-parts-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeI-iBXs4JQ0CrCDi-4_fZAe-yoTl1rqY',
    appId: '1:28298063071:ios:961fb06d075b1e82578d6a',
    messagingSenderId: '28298063071',
    projectId: 'vehicle-spare-parts-app',
    databaseURL: 'https://vehicle-spare-parts-app-default-rtdb.firebaseio.com',
    storageBucket: 'vehicle-spare-parts-app.appspot.com',
    iosClientId: '28298063071-u88lmdtgd9td4pb6q18vbo4jskbs11m0.apps.googleusercontent.com',
    iosBundleId: 'com.example.seniorDesign',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeI-iBXs4JQ0CrCDi-4_fZAe-yoTl1rqY',
    appId: '1:28298063071:ios:961fb06d075b1e82578d6a',
    messagingSenderId: '28298063071',
    projectId: 'vehicle-spare-parts-app',
    databaseURL: 'https://vehicle-spare-parts-app-default-rtdb.firebaseio.com',
    storageBucket: 'vehicle-spare-parts-app.appspot.com',
    iosClientId: '28298063071-u88lmdtgd9td4pb6q18vbo4jskbs11m0.apps.googleusercontent.com',
    iosBundleId: 'com.example.seniorDesign',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDKbsv5TpsCGfJp8rH4yPsTK9UXcoe899I',
    appId: '1:28298063071:web:211e27d56870578b578d6a',
    messagingSenderId: '28298063071',
    projectId: 'vehicle-spare-parts-app',
    authDomain: 'vehicle-spare-parts-app.firebaseapp.com',
    databaseURL: 'https://vehicle-spare-parts-app-default-rtdb.firebaseio.com',
    storageBucket: 'vehicle-spare-parts-app.appspot.com',
  );

}