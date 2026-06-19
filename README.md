<div align="center">
	<a href="README.es.md">
		<img src="https://img.shields.io/badge/Lang-Espanol-red" alt="Leer en Espanol" />
	</a>
</div>

# Intro to GenUI - Memory Trainer

<div align="center">
	<p>
		<a href="https://flutter.dev/" target="_blank">
			<img src="https://img.shields.io/badge/Flutter-3.12%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
		</a>
		<a href="https://firebase.google.com/" target="_blank">
			<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
		</a>
		<a href="https://cloud.google.com/vertex-ai" target="_blank">
			<img src="https://img.shields.io/badge/Vertex%20AI-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Vertex AI" />
		</a>
	</p>
</div>

**AI-powered memory training built with Flutter + GenUI.**
Run timed word sessions, evaluate recall quality, and visualize final results with scoring feedback.

---

## Features

| Module | Description |
|---|---|
| AI Coach | Runs a guided memory workflow in Spanish and orchestrates each phase |
| Memory Session | Renders timed word lists through GenUI surfaces |
| Timeout Behavior | Hides words automatically when time ends |
| Recall Evaluation | Scores each answer with partial credit (1.0, 0.5, 0.0) |
| Score Dashboard | Displays final score, progress bar, and per-word feedback |
| Configurable Agent | Keeps prompts, model name, and surface IDs in config layer |

---

## PHASE 2: Process Agent (Today)

```text
-----------------------------------------------------------
|                    PHASE 2 (TODAY)                      |
|                   Process Agent                         |
-----------------------------------------------------------
| - Runs autonomous multi-step workflows.                 |
| - Connects to external systems (CRM, ERP, email).       |
| - Makes rule-based decisions and reports results.       |
-----------------------------------------------------------
```

---

## Architecture

The project follows a layered design:

```text
UI  ->  Config  ->  Infrastructure  ->  Domain
```

- Domain: pure Dart models, gateways, and use cases.
- Infrastructure: adapters and mappers for parsing and default rules.
- Config: providers, routes, Firebase options, and agent configuration.
- UI: pages, widgets, and painters.

### Folder layout

```text
lib/
|- config/
|  |- agent/
|  |- firebase/
|  |- providers/
|  |- routes/
|  '- theme/
|- domain/
|  |- models/
|  '- usecase/
|- infrastructure/
|  |- driven_adapters/
|  '- helpers/
'- ui/
	|- pages/
	|- widgets/
	'- painters/
```

---

## Setup

Requirements: Flutter SDK (with Dart 3.12+).

Security note:
- Do not commit Firebase credential files.
- Use local files and compile-time variables only.

Create local platform files:

```bash
cp android/app/google-services.json.example android/app/google-services.json
cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
```

Run on Chrome using a local dart-define file:

```bash
cp firebase_web.env.example.json firebase_web.env.json
```

Fill firebase_web.env.json with your Firebase Web values.

Then run:

```bash
flutter run -d chrome --dart-define-from-file=firebase_web.env.json
```

You can also run with inline --dart-define values (example):

```bash
flutter run \
	--dart-define=FIREBASE_WEB_API_KEY=YOUR_VALUE \
	--dart-define=FIREBASE_WEB_APP_ID=YOUR_VALUE \
	--dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=YOUR_VALUE \
	--dart-define=FIREBASE_WEB_PROJECT_ID=YOUR_VALUE \
	--dart-define=FIREBASE_WEB_AUTH_DOMAIN=YOUR_VALUE \
	--dart-define=FIREBASE_WEB_STORAGE_BUCKET=YOUR_VALUE \
	--dart-define=FIREBASE_ANDROID_API_KEY=YOUR_VALUE \
	--dart-define=FIREBASE_ANDROID_APP_ID=YOUR_VALUE \
	--dart-define=FIREBASE_ANDROID_MESSAGING_SENDER_ID=YOUR_VALUE \
	--dart-define=FIREBASE_ANDROID_PROJECT_ID=YOUR_VALUE \
	--dart-define=FIREBASE_ANDROID_STORAGE_BUCKET=YOUR_VALUE \
	--dart-define=FIREBASE_IOS_API_KEY=YOUR_VALUE \
	--dart-define=FIREBASE_IOS_APP_ID=YOUR_VALUE \
	--dart-define=FIREBASE_IOS_MESSAGING_SENDER_ID=YOUR_VALUE \
	--dart-define=FIREBASE_IOS_PROJECT_ID=YOUR_VALUE \
	--dart-define=FIREBASE_IOS_STORAGE_BUCKET=YOUR_VALUE \
	--dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.intro_to_genui
```

```bash
flutter pub get
flutter run
```

---

## Validation

Use focused checks for this repository:

```bash
flutter analyze lib test/widget_test.dart
flutter test test/widget_test.dart
```

---

## Main dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_ai` | Gemini model access |
| `genui` | Surface-based UI protocol |
| `json_schema_builder` | Declarative schema for surface payloads |

---

## Design notes

- Spanish-first conversational experience.
- Retro-inspired visual layer (grid/orb) with owl feedback states.
- Cross-platform Flutter target (Android, iOS, macOS, Linux, Web, Windows).
