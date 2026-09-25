---
title: "Paso 1: Dependencias y Configuración Base"
sidebar_label: "1. Dependencias y Setup"
sidebar_position: 1
---

# Paso 1: Dependencias y Configuración Base

Para implementar **A2UI** en una aplicación Flutter necesitamos cuatro dependencias clave en nuestro archivo `pubspec.yaml`:

```yaml title="pubspec.yaml"
dependencies:
  flutter:
    sdk: flutter

  # Inicialización y backend
  firebase_core: ^4.11.0

  # Acceso a modelos Gemini mediante Vertex AI en Firebase
  firebase_ai: ^3.13.0

  # Protocolo y widgets de Agent-to-User Interface (A2UI)
  genui: ^0.9.2

  # Definición declarativa de esquemas JSON para las superficies
  json_schema_builder: ^0.1.5
```

---

## 📦 Rol de cada dependencia

| Dependencia | Rol en la solución |
|---|---|
| **`genui`** | Es la pieza central del protocolo A2UI. Provee las clases `Catalog`, `CatalogItem`, `SurfaceController`, `A2uiTransportAdapter`, `Conversation` y el widget `Surface` que encapsula la renderización dinámica. |
| **`json_schema_builder`** | Permite definir los esquemas de validación de cada superficie en Dart con una sintaxis fluida (`S.object(...)`, `S.string(...)`, etc.). Estos esquemas se convierten en especificaciones JSON Schema compatibles con el estándar OpenAPI / Gemini Function Calling. |
| **`firebase_ai`** | SDK oficial para comunicarse con los modelos multimodales de Google Gemini (en este proyecto, `gemini-2.5-flash`) a través de **Firebase Vertex AI**, permitiendo gestionar sesiones conversacionales de chat (`ChatSession`). |
| **`firebase_core`** | Maneja la autenticación y vinculación de la app con el proyecto de Firebase. |

---

## ⚙️ Inicialización en `main.dart`

Antes de invocar cualquier llamada a Vertex AI o instanciar superficies, debemos asegurar que los enlaces de Flutter y Firebase estén inicializados:

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
  
  // 1. Inicializar Firebase con las opciones de la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Instanciar providers inyectando sus adaptadores de infraestructura
  final MemorySessionProvider memorySessionProvider = MemorySessionProvider(
    gateway: MemorySessionDefaultsAdapter(),
  );
  final ScoreProvider scoreProvider = ScoreProvider(
    gateway: ScoreRulesAdapter(),
  );
  final ScorePayloadProvider scorePayloadProvider = ScorePayloadProvider(
    gateway: ScorePayloadAdapter(),
  );

  // 3. Ejecutar la aplicación pasando los providers
  runApp(
    MyApp(
      memorySessionProvider: memorySessionProvider,
      scoreProvider: scoreProvider,
      scorePayloadProvider: scorePayloadProvider,
    ),
  );
}
```

:::tip Consejo de Arquitectura
Nota cómo los adaptadores de infraestructura (`MemorySessionDefaultsAdapter`, `ScorePayloadAdapter`) se inyectan en este punto de entrada. Esto permite sustituirlos fácilmente en entornos de test por adaptadores simulados (mocks) sin tocar la UI.
:::
