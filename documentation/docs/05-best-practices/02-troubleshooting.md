---
title: "Resolución de Problemas y Preguntas Frecuentes (FAQ)"
sidebar_label: "Preguntas Frecuentes y Errores"
sidebar_position: 2
---

# Resolución de Problemas y Preguntas Frecuentes

A continuación recopilamos los problemas más comunes al desarrollar con A2UI y cómo solucionarlos rápidamente.

---

## ❓ 1. La superficie no se renderiza y solo aparece texto o JSON en el chat

**Causa probable:**
* El `CatalogItem` no fue registrado dentro de `_catalog` en `_MemoryTrainerPageState`.
* O el esquema JSON no fue inyectado en el prompt inicial del sistema con `PromptBuilder.chat(catalog: _catalog, ...)`.

**Solución:**
Asegúrate de que en `initState` se cree el catálogo antes de enviar el primer `ChatMessage.system`:
```dart
_catalog = BasicCatalogItems.asCatalog().copyWith(
  newItems: [
    buildMemorySessionDisplay(...),
    buildScoreDisplay(...),
  ],
);

final PromptBuilder promptBuilder = PromptBuilder.chat(
  catalog: _catalog,
  systemPromptFragments: [memoryTrainerSystemInstruction],
);

_conversation.sendRequest(
  ChatMessage.system(promptBuilder.systemPromptJoined()),
);
```

---

## ❓ 2. El evento `timeoutAction` no avisa al agente y la conversación se detiene

**Causa probable:**
La función `_sendAndReceive` no está extrayendo los fragmentos de tipo interacción de usuario (`isUiInteractionPart`).

**Solución:**
Verifica que el bucle de partes en `_sendAndReceive` maneje explícitamente `isUiInteractionPart`:
```dart
for (final part in msg.parts) {
  if (part.isUiInteractionPart) {
    buffer.write(part.asUiInteractionPart!.interaction);
  } else if (part is genui.TextPart) {
    buffer.write(part.text);
  }
}
```

---

## ❓ 3. Conflicto de nombres: `TextPart` está definido tanto en `firebase_ai` como en `genui`

**Causa probable:**
Tanto `package:firebase_ai/firebase_ai.dart` como `package:genui/genui.dart` exportan una clase llamada `TextPart`.

**Solución:**
Oculta la clase en el import general de `genui` y usa un alias con prefijo para el segundo:
```dart
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
```

---

## ❓ 4. Error de credenciales o Firebase no inicializado en Web

**Síntoma:**
`FirebaseException: No Firebase App '[DEFAULT]' has been created` o errores de autenticación con Vertex AI.

**Solución:**
En Web, los valores deben suministrarse en tiempo de compilación. Asegúrate de haber copiado el archivo de ejemplo y ejecutar con la bandera `--dart-define-from-file`:
```bash
cp firebase_web.env.example.json firebase_web.env.json
# Edita firebase_web.env.json con tus claves reales
flutter run -d chrome --dart-define-from-file=firebase_web.env.json
```

---

## ❓ 5. ¿Cómo añadir una nueva superficie interactiva personalizada?

Para añadir una tercera superficie (por ejemplo, un selector de dificultad `DifficultySelector`):

1. **Definir el esquema**: Usa `json_schema_builder` en un nuevo archivo `lib/ui/widgets/difficulty_selector.dart` definiendo `properties` y `required`.
2. **Crear el modelo y mapper**: Agrega las clases inmutables en `lib/domain/models/` y su mapper defensivo.
3. **Crear la función `buildDifficultySelector(...)`**: Retorna un `CatalogItem(name: 'DifficultySelector', dataSchema: ..., widgetBuilder: ...)`.
4. **Registrarlo en el catálogo**: Añádelo a `newItems` en `_catalog` dentro de `MemoryTrainerPage`.
5. **Instruir al agente**: Actualiza `memoryTrainerSystemInstruction` en `agent_config.dart` para que Gemini sepa en qué fase debe generar la nueva superficie.
