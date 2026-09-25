---
title: "Step 1: Dependencies & Base Setup"
sidebar_label: "1. Dependencies & Setup"
sidebar_position: 1
---

# Step 1: Dependencies & Base Setup

To implement **A2UI** in a Flutter application, we require four core dependencies in `pubspec.yaml`:

```yaml title="pubspec.yaml"
dependencies:
  flutter:
    sdk: flutter

  # Firebase core initialization
  firebase_core: ^4.11.0

  # Access to Gemini models via Vertex AI in Firebase
  firebase_ai: ^3.13.0

  # Agent-to-User Interface (A2UI) protocol and surface widgets
  genui: ^0.9.2

  # Declarative JSON Schema builder for surface contracts
  json_schema_builder: ^0.1.5
```

---

## 📦 Package Responsibilities

| Dependency | Purpose |
|---|---|
| **`genui`** | Core engine for the A2UI protocol. Provides `Catalog`, `CatalogItem`, `SurfaceController`, `A2uiTransportAdapter`, `Conversation`, and the `Surface` widget. |
| **`json_schema_builder`** | Enables declarative JSON Schema declarations in Dart (`S.object(...)`, `S.string(...)`, etc.). Produces OpenAPI-compliant schemas matching Gemini function specifications. |
| **`firebase_ai`** | Official SDK to communicate with Google Gemini multimodal models (`gemini-2.5-flash`) through **Firebase Vertex AI**, managing conversation sessions (`ChatSession`). |
| **`firebase_core`** | Platform-level Firebase app initialization and credential coordination. |

---

## ⚙️ Application Entry Point: `main.dart`

Before launching AI conversations or building surfaces, Flutter bindings and Firebase must be initialized:

```dart title="lib/main.dart"
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intro_to_genui/config/firebase/firebase_options.dart';
import 'package:intro_to_genui/config/providers/memory_session_provider.dart';
import 'package:intro_to_genui/config/providers/score_payload_provider.dart';
import 'package:intro_to_genui/config/providers/score_provider.dart';
import 'package:intro_to_genui/infrastructure/driven_adapters/memory_session/memory_session_defaults_adapter.dart';
import 'package:intro_to_genui/infrastructure/driven_adapters/score/score_payload_adapter.dart';
import 'package:intro_to_genui/infrastructure/driven_adapters/score/score_rules_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Instantiate providers injecting infrastructure adapters
  final MemorySessionProvider memorySessionProvider = MemorySessionProvider(
    gateway: MemorySessionDefaultsAdapter(),
  );
  final ScoreProvider scoreProvider = ScoreProvider(
    gateway: ScoreRulesAdapter(),
  );
  final ScorePayloadProvider scorePayloadProvider = ScorePayloadProvider(
    gateway: ScorePayloadAdapter(),
  );

  // 3. Launch application
  runApp(
    MyApp(
      memorySessionProvider: memorySessionProvider,
      scoreProvider: scoreProvider,
      scorePayloadProvider: scorePayloadProvider,
    ),
  );
}
```

:::tip Architecture Tip
Injecting infrastructure adapters (`MemorySessionDefaultsAdapter`, `ScorePayloadAdapter`) at this root level makes it trivial to replace them with mock adapters during automated testing without modifying UI code.
:::
