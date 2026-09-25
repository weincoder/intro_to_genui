---
title: "Step 2: Defining JSON Schemas"
sidebar_label: "2. JSON Schemas"
sidebar_position: 2
---

# Step 2: Defining JSON Schemas

In A2UI, the UI is never created from arbitrary code hallucinated on the fly by the model. Instead, **the developer establishes a rigid contract using JSON Schema**.

The `json_schema_builder` package allows declaring these schemas directly in Dart with strong typing and fluid syntax.

---

## 📐 Schema 1: `MemorySessionDisplay` (Interactive Action Contract)

This component represents the timed memory card containing the topic, word list, and countdown timer.

```dart title="lib/ui/widgets/memory_session_display.dart"
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final memorySessionDisplaySchema = S.object(
  properties: {
    // 1. Fixed component identifier
    'component': S.string(enumValues: ['MemorySessionDisplay']),
    
    // 2. Session metadata
    'title': S.string(description: 'Title of the memorization card.'),
    'topic': S.string(description: 'Topic chosen by the user.'),
    'words': S.list(
      description: 'List of words to memorize.',
      items: S.string(),
    ),
    'durationSeconds': S.integer(
      description: 'Total timer countdown duration in seconds.',
    ),
    'hideWordsOnTimeout': S.boolean(
      description: 'Whether to hide words once time expires.',
    ),

    // 3. Interactive callback action schema
    'timeoutAction': A2uiSchemas.action(
      description: 'Action dispatched when the timer completes.',
    ),
  },
  required: [
    'title',
    'topic',
    'words',
    'durationSeconds',
    'hideWordsOnTimeout',
  ],
);
```

### Highlights:
* **`component`**: `enumValues: ['MemorySessionDisplay']` locks this property to the exact surface name, allowing deterministic routing.
* **`description`**: Semantic descriptions assist Gemini in understanding what each field controls.
* **`A2uiSchemas.action(...)`**: Built-in helper from `genui` that generates a standard action structure (`name`, `context`) for callbacks and events.

---

## 📊 Schema 2: `ScoreDisplay` (Nested Evaluation Lists)

This component visualizes user performance once evaluation ends:

```dart title="lib/ui/widgets/score_display.dart"
import 'package:json_schema_builder/json_schema_builder.dart';

final scoreDisplaySchema = S.object(
  properties: {
    'component': S.string(enumValues: ['ScoreDisplay']),
    'title': S.string(description: 'Title of the score card.'),
    'totalScore': S.number(description: 'Total score achieved.'),
    'maxScore': S.number(description: 'Maximum achievable score.'),
    'entries': S.list(
      description: 'Per-word evaluation breakdown.',
      items: S.object(
        properties: {
          'expectedWord': S.string(
            description: 'Target word in the session.',
          ),
          'userAnswer': S.string(description: 'Answer provided by user.'),
          'score': S.number(description: 'Score awarded for this answer.'),
          'feedback': S.string(
            description: 'Brief justification for the score.',
          ),
        },
        required: ['expectedWord', 'userAnswer', 'score', 'feedback'],
      ),
    ),
  },
  required: ['title', 'totalScore', 'maxScore', 'entries'],
);
```

### Highlights:
* **Flexible Numbers (`S.number()`)**: Supports decimals (`0.5`, `1.0`), essential for partial credit.
* **Nested Object Arrays (`S.list(items: S.object(...))`)**: Enforces typed structures for per-word breakdowns.

---

## 💡 How Gemini Consumes These Schemas

During initialization, `genui` automatically translates these schemas into OpenAPI tool specifications. Gemini is trained to generate structured tool calls adhering strictly to these specifications, eliminating arbitrary key name variations.
