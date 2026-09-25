---
title: "Troubleshooting & Frequently Asked Questions (FAQ)"
sidebar_label: "FAQ & Troubleshooting"
sidebar_position: 2
---

# Troubleshooting & Frequently Asked Questions

A compilation of common challenges encountered when developing with A2UI and how to address them quickly.

---

## ❓ 1. Surface is not rendering and only raw JSON appears in chat

**Probable Cause:**
* The `CatalogItem` was not registered in `_catalog` inside `_MemoryTrainerPageState`.
* Or the JSON schema was not injected into the initial system prompt using `PromptBuilder.chat(catalog: _catalog, ...)`.

**Solution:**
Ensure that `_catalog` is assembled and passed to `PromptBuilder` before dispatching the initial `ChatMessage.system`:
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

## ❓ 2. The `timeoutAction` event fires, but the agent never replies

**Probable Cause:**
The `_sendAndReceive` loop is ignoring interaction parts (`isUiInteractionPart`).

**Solution:**
Ensure that parts iteration in `_sendAndReceive` extracts both text and UI interaction payloads:
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

## ❓ 3. Name collision: `TextPart` exists in both `firebase_ai` and `genui`

**Probable Cause:**
Both `package:firebase_ai/firebase_ai.dart` and `package:genui/genui.dart` export a class named `TextPart`.

**Solution:**
Hide `TextPart` from the general `genui` import and use a prefixed alias:
```dart
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
```

---

## ❓ 4. Firebase credentials or initialization error on Web

**Symptom:**
`FirebaseException: No Firebase App '[DEFAULT]' has been created` or permission errors during Vertex AI calls.

**Solution:**
On Flutter Web, values must be supplied at compile time. Ensure you copied the example file and pass `--dart-define-from-file`:
```bash
cp firebase_web.env.example.json firebase_web.env.json
# Edit firebase_web.env.json with your actual project keys
flutter run -d chrome --dart-define-from-file=firebase_web.env.json
```

---

## ❓ 5. How do I add a brand-new custom interactive surface?

To implement an additional surface (such as a `DifficultySelector`):

1. **Define Schema**: Use `json_schema_builder` in `lib/ui/widgets/difficulty_selector.dart` declaring `properties` and `required` fields.
2. **Model & Mapper**: Add immutable entities in `lib/domain/models/` and an infrastructure mapper.
3. **Declare `buildDifficultySelector(...)`**: Return a `CatalogItem(name: 'DifficultySelector', dataSchema: ..., widgetBuilder: ...)`.
4. **Register in Catalog**: Append it to `newItems` in `_catalog` inside `MemoryTrainerPage`.
5. **Instruct the Agent**: Update `memoryTrainerSystemInstruction` in `agent_config.dart` specifying which phase should trigger the surface.
