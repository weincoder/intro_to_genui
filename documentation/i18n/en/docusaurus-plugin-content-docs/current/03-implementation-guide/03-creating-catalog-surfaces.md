---
title: "Step 3: Creating CatalogItems & Surfaces"
sidebar_label: "3. CatalogItems & Surfaces"
sidebar_position: 3
---

# Step 3: Creating CatalogItems & Surfaces

With schemas defined, the next step in A2UI is connecting each schema to a concrete Flutter widget builder. This is achieved using `CatalogItem` from `genui`.

---

## 🛠️ Anatomy of a `CatalogItem`

A `CatalogItem` requires three core arguments:
1. **`name`**: The unique component identifier string.
2. **`dataSchema`**: The JSON Schema defined via `json_schema_builder`.
3. **`widgetBuilder`**: A factory function that receives an `itemContext` and returns a native Flutter widget.

---

## 💻 Implementing `buildScoreDisplay`

```dart title="lib/ui/widgets/score_display.dart"
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:intro_to_genui/config/providers/score_payload_provider.dart';
import 'package:intro_to_genui/config/providers/score_provider.dart';
import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';

CatalogItem buildScoreDisplay({
  required ScoreProvider scoreProvider,
  required ScorePayloadProvider scorePayloadProvider,
}) {
  return CatalogItem(
    name: 'ScoreDisplay',
    dataSchema: scoreDisplaySchema,
    widgetBuilder: (itemContext) {
      // 1. Extract raw untyped payload from LLM
      final Map<String, Object?> json =
          itemContext.data as Map<String, Object?>;

      // 2. Map defensively into domain models
      final ScoreDisplayPayloadModel data = scorePayloadProvider.parse(
        json: json,
      );

      // 3. Render widget with validated domain entity
      return _ScoreDisplay(
        data: data,
        scoreProvider: scoreProvider,
      );
    },
  );
}
```

### Why Route Through `scorePayloadProvider.parse`?
Passing incoming JSON through `scorePayloadProvider` protects the UI layer from missing or malformed keys. If Gemini outputs an integer instead of a double, or omits optional feedback, the mapper applies clean fallbacks before the widget builds.

---

## ⏱️ Implementing `buildMemorySessionDisplay` (Interactive Events)

For surfaces that dispatch actions back to the agent:

```dart title="lib/ui/widgets/memory_session_display.dart"
CatalogItem buildMemorySessionDisplay({
  required MemorySessionProvider memorySessionProvider,
}) {
  return CatalogItem(
    name: 'MemorySessionDisplay',
    dataSchema: memorySessionDisplaySchema,
    widgetBuilder: (itemContext) {
      final Map<String, Object?> json =
          itemContext.data as Map<String, Object?>;
          
      final _MemorySessionData data = _MemorySessionData.fromJson(
        json: json,
        memorySessionProvider: memorySessionProvider,
      );

      return _MemorySessionDisplay(
        data: data,
        onTimeout: (timeoutAction) async {
          if (timeoutAction.actionName.isEmpty) return;

          // Resolves contextual expressions if present
          final JsonMap resolvedContext = await resolveContext(
            itemContext.dataContext,
            timeoutAction.actionContext,
          );

          // Dispatches native event to GenUI conversation stream
          itemContext.dispatchEvent(
            UserActionEvent(
              name: timeoutAction.actionName,
              sourceComponentId: itemContext.id,
              context: resolvedContext,
            ),
          );
        },
      );
    },
  );
}
```

---

## 📚 Registering Surfaces in a `Catalog`

Inside [`MemoryTrainerPage`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/pages/memory_trainer_page.dart), all catalog items are bundled into a single `Catalog`:

```dart title="lib/ui/pages/memory_trainer_page.dart"
_catalog = BasicCatalogItems.asCatalog().copyWith(
  newItems: [
    buildMemorySessionDisplay(
      memorySessionProvider: widget.memorySessionProvider,
    ),
    buildScoreDisplay(
      scoreProvider: widget.scoreProvider,
      scorePayloadProvider: widget.scorePayloadProvider,
    ),
  ],
);
```

This catalog is passed to `SurfaceController` (for widget rendering) and to `PromptBuilder` (for model prompt generation).
