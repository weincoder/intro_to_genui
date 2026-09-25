---
title: "Quickstart"
sidebar_label: "Quickstart"
sidebar_position: 2
---

# Quickstart: Running the Project

Follow these steps to clone, configure, and run the **Intro to GenUI - Memory Trainer** project on your local machine.

---

## 📋 System Requirements

- **Flutter SDK**: 3.12+ (Dart 3.12+).
- **Firebase / Google Cloud Account**: With the **Vertex AI in Firebase** service enabled.
- Web Browser (Chrome) or Android / iOS emulator / physical device.

---

## 1. Clone the Repository & Install Dependencies

Clone the repository and fetch the Flutter packages:

```bash
git clone https://github.com/weincoder/intro_to_genui.git
cd intro_to_genui
flutter pub get
```

---

## 2. Firebase Credentials Setup

For security reasons, Firebase credential files are not checked into the repository. Configure your local files depending on your target platform:

### Option A: Web Execution (Recommended for quick testing)

1. Copy the example web environment template:

```bash
cp firebase_web.env.example.json firebase_web.env.json
```

2. Open `firebase_web.env.json` and fill in your Firebase Web values:

```json
{
  "FIREBASE_WEB_API_KEY": "AIzaSy...",
  "FIREBASE_WEB_APP_ID": "1:...:web:...",
  "FIREBASE_WEB_MESSAGING_SENDER_ID": "...",
  "FIREBASE_WEB_PROJECT_ID": "your-firebase-project",
  "FIREBASE_WEB_AUTH_DOMAIN": "your-firebase-project.firebaseapp.com",
  "FIREBASE_WEB_STORAGE_BUCKET": "your-firebase-project.appspot.com"
}
```

3. Run the application in Chrome pointing to your environment file:

```bash
flutter run -d chrome --dart-define-from-file=firebase_web.env.json
```

### Option B: Android / iOS Execution

1. For Android, copy the configuration example:
   ```bash
   cp android/app/google-services.json.example android/app/google-services.json
   ```
2. For iOS, copy the configuration examples:
   ```bash
   cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
   cp firebase_ios.env.example.json firebase_ios.env.json
   ```
3. Run the application on your simulator or connected device:
   ```bash
   flutter run
   ```

---

## 3. Verification & Testing

To verify that the development environment and agent configuration contracts are intact, run the static analyzer and the test suite:

```bash
# Run strict static analysis
flutter analyze lib test/widget_test.dart

# Run automated tests
flutter test test/widget_test.dart
```

These tests ensure that:
* Core A2UI constants (`memorySessionSurfaceId`, `scoreDisplaySurfaceId`, `memoryTrainerModelName`) are defined and non-empty.
* The system instruction prompt (`memoryTrainerSystemInstruction`) contains mandatory surface generation specifications.
