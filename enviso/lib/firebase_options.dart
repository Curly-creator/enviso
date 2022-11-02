// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCy7oQXD88PCHJoZRii0mLNjeZI0C6JIVw',
    appId: '1:281535895651:web:4793b5b8a1dc2043bec056',
    messagingSenderId: '281535895651',
    projectId: 'enviso',
    authDomain: 'enviso.firebaseapp.com',
    storageBucket: 'enviso.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgZGMLnlf98v4H9p2mTTqKMsvf1a6wsRc',
    appId: '1:281535895651:android:57383f5c11618981bec056',
    messagingSenderId: '281535895651',
    projectId: 'enviso',
    storageBucket: 'enviso.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDl5ed0fbW91q9PSMpu-QN-jSG4aBvQ36A',
    appId: '1:281535895651:ios:21ac249187ce1927bec056',
    messagingSenderId: '281535895651',
    projectId: 'enviso',
    storageBucket: 'enviso.appspot.com',
    iosClientId: '281535895651-cdoo71jeqgpm6ih5416d5i2elkm41h3q.apps.googleusercontent.com',
    iosBundleId: 'com.example.enviso',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDl5ed0fbW91q9PSMpu-QN-jSG4aBvQ36A',
    appId: '1:281535895651:ios:21ac249187ce1927bec056',
    messagingSenderId: '281535895651',
    projectId: 'enviso',
    storageBucket: 'enviso.appspot.com',
    iosClientId: '281535895651-cdoo71jeqgpm6ih5416d5i2elkm41h3q.apps.googleusercontent.com',
    iosBundleId: 'com.example.enviso',
  );
}
