---
title: "Paso 3: Creación de CatalogItem y Superficies"
sidebar_label: "3. CatalogItem y Superficies"
sidebar_position: 3
---

# Paso 3: Creación de CatalogItem y Superficies

Una vez definidos los esquemas JSON, el siguiente paso en A2UI es vincular cada esquema con un widget de Flutter. Esto se realiza mediante la clase `CatalogItem` provista por `genui`.

---

## 🛠️ Estructura de un `CatalogItem`

Un `CatalogItem` requiere tres componentes fundamentales:
1. **`name`**: El identificador unívoco de la superficie (coincide con el nombre esperado por el modelo).
2. **`dataSchema`**: El esquema JSON creado con `json_schema_builder`.
3. **`widgetBuilder`**: Una función constructora que recibe un `itemContext` y devuelve el árbol de widgets nativos de Flutter.

---

## 💻 Implementación de `buildScoreDisplay`

Veamos cómo se define la función constructora para `ScoreDisplay`:

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
      // 1. Obtener la carga útil en bruto generada por el LLM
      final Map<String, Object?> json =
          itemContext.data as Map<String, Object?>;

      // 2. Mapear de forma segura hacia el modelo de Dominio
      final ScoreDisplayPayloadModel data = scorePayloadProvider.parse(
        json: json,
      );

      // 3. Renderizar el widget de Flutter inyectando la entidad validada
      return _ScoreDisplay(
        data: data,
        scoreProvider: scoreProvider,
      );
    },
  );
}
```

### ¿Por qué pasar por `scorePayloadProvider.parse`?
En lugar de forzar al widget `_ScoreDisplay` a leer directamente claves crudas de JSON (`json['totalScore']`), pasamos la carga a través de la capa de infraestructura/dominio. Si el LLM devolvió un entero en lugar de un doble, o faltó alguna retroalimentación, el mapper normaliza los tipos y asegura que el widget nunca lance una excepción de casteo en tiempo de ejecución.

---

## ⏱️ Implementación de `buildMemorySessionDisplay` (Con Eventos)

Para superficies interactivas que deben despachar eventos de vuelta al agente, `itemContext` provee el método `dispatchEvent`:

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

          // Resuelve variables o expresiones dinámicas del contexto si existieran
          final JsonMap resolvedContext = await resolveContext(
            itemContext.dataContext,
            timeoutAction.actionContext,
          );

          // Dispara un evento nativo hacia el flujo conversacional de GenUI
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

## 📚 Agrupando las superficies en un `Catalog`

En la página principal ([`MemoryTrainerPage`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/pages/memory_trainer_page.dart)), agrupamos todos los `CatalogItem` en una única instancia de `Catalog`:

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

Este `Catalog` se le suministra tanto al `SurfaceController` (para renderizar widgets) como al `PromptBuilder` (para enseñarle al LLM las herramientas que tiene a su alcance).
