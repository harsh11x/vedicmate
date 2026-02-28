// File generated manually based on GoogleService-Info.plist and google-services.json
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        // Assuming macOS uses same as iOS for now, or throw if not supported
        return ios; 
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfrhBl-XkAG6gZQvF3GEH5tI3b6dYgNKc',
    appId: '1:848781830717:android:ecbab60e46c7e3c887d854',
    messagingSenderId: '848781830717',
    projectId: 'vedic-mate',
    storageBucket: 'vedic-mate.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsH72iY7ua6DmGe467PQbQZxfyye2ynJk',
    appId: '1:848781830717:ios:a83373938723cfa487d854',
    messagingSenderId: '848781830717',
    projectId: 'vedic-mate',
    storageBucket: 'vedic-mate.firebasestorage.app',
    iosBundleId: 'com.vedicmate.app',
  );
}
