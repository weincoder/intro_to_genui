import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase options loaded from --dart-define values.
///
/// Required keys:
/// - FIREBASE_WEB_API_KEY
/// - FIREBASE_WEB_APP_ID
/// - FIREBASE_WEB_MESSAGING_SENDER_ID
/// - FIREBASE_WEB_PROJECT_ID
/// - FIREBASE_WEB_AUTH_DOMAIN
/// - FIREBASE_WEB_STORAGE_BUCKET
/// - FIREBASE_ANDROID_API_KEY
/// - FIREBASE_ANDROID_APP_ID
/// - FIREBASE_ANDROID_MESSAGING_SENDER_ID
/// - FIREBASE_ANDROID_PROJECT_ID
/// - FIREBASE_ANDROID_STORAGE_BUCKET
/// - FIREBASE_IOS_API_KEY
/// - FIREBASE_IOS_APP_ID
/// - FIREBASE_IOS_MESSAGING_SENDER_ID
/// - FIREBASE_IOS_PROJECT_ID
/// - FIREBASE_IOS_STORAGE_BUCKET
/// - FIREBASE_IOS_BUNDLE_ID
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return _validated(platformName: 'web', options: web);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android.apiKey.isNotEmpty ? android : null;
      case TargetPlatform.iOS:
        return ios.apiKey.isNotEmpty ? ios : null;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions no se ha configurado para macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions no se ha configurado para Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no se ha configurado para Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no es compatible con esta plataforma.',
        );
    }
  }

  static FirebaseOptions _validated({
    required String platformName,
    required FirebaseOptions options,
  }) {
    if (options.apiKey.isEmpty ||
        options.appId.isEmpty ||
        options.messagingSenderId.isEmpty ||
        options.projectId.isEmpty) {
      throw StateError(
        'Firebase no configurado para $platformName. '
        'Pasa valores por --dart-define o genera tus archivos locales.',
      );
    }
    return options;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_WEB_PROJECT_ID',
      defaultValue: '',
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_WEB_AUTH_DOMAIN',
      defaultValue: '',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_WEB_STORAGE_BUCKET',
      defaultValue: '',
    ),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: '',
    ),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_ANDROID_PROJECT_ID',
      defaultValue: '',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_ANDROID_STORAGE_BUCKET',
      defaultValue: '',
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_IOS_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_IOS_PROJECT_ID',
      defaultValue: '',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_IOS_STORAGE_BUCKET',
      defaultValue: '',
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: '',
    ),
  );
}
