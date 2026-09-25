---
title: "Production Best Practices for A2UI"
sidebar_label: "Best Practices"
sidebar_position: 1
---

# Production Best Practices for A2UI

Implementing interfaces driven by AI agents (A2UI) introduces reliability considerations that go beyond standard Flutter development. Below are key best practices implemented in this project.

---

## 🛡️ 1. Defensive Mapping & Fallback Rules

Never assume the language model will return perfectly typed data in all scenarios:

* **Floating Point vs Integers**: In JSON, numbers lack strict distinction between `int` and `double`. A value of `10` might arrive as `10` or `10.0`. In mappers, always cast against Dart's `num` supertype:
  ```dart
  final Object? totalRaw = json['totalScore'];
  final double total = totalRaw is num ? totalRaw.toDouble() : 0.0;
  ```
* **Null or Dirty Collections**: Always filter list elements by type:
  ```dart
  final Object? wordsRaw = json['words'];
  final List<String> words = wordsRaw is List<Object?>
      ? wordsRaw.whereType<String>().toList()
      : <String>[];
  ```
* **Fallback Domain Defaults**: If Gemini omits an optional property (like duration), rely on an adapter to compute sensible defaults using domain logic (`wordCount * 6`).

---

## 🔑 2. Immutable Surface Keys (`ValueKey`)

When Gemini updates an existing surface or emits a new session, Flutter may incorrectly reuse stateful elements if the key remains identical:

```dart
// ❌ Problematic: Reuses previous widget state
Surface(
  key: ValueKey(item.surfaceId),
  surfaceContext: _controller.contextFor(item.surfaceId),
)

// ✅ Recommended: Forces a clean rebuild using an instance version
Surface(
  key: ValueKey('${item.surfaceId}_${item.instanceVersion}'),
  surfaceContext: _controller.contextFor(item.surfaceId),
)
```

Incrementing `_nextSurfaceInstanceVersion` whenever a surface event arrives guarantees timers, animations, and local controllers are cleanly re-instantiated.

---

## 🧹 3. Memory Leak Prevention

Any interactive surface running timers (`Timer.periodic`), scroll listeners, or animation controllers **must** release resources in `dispose()`:

```dart
@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
```

If the user navigates away or the surface is removed, active timers must halt immediately to avoid firing orphaned events.

---

## 🧪 4. Automated Testing Strategy

A2UI projects benefit from a three-tiered testing approach:

1. **Agent Configuration Contracts (`test/widget_test.dart`)**:
   Verify that surface IDs, model identifiers, and required keywords in the prompt are preserved:
   ```dart
   test('maintains systemInstruction consistency', () {
     expect(systemInstruction, equals(memoryTrainerSystemInstruction));
     expect(systemInstruction, contains('ScoreDisplay'));
     expect(systemInstruction, contains('MemorySessionDisplay'));
   });
   ```
2. **Domain & Infrastructure Unit Tests**:
   Verify that use cases (`ScorePercentageUseCase`, `ScoreMoodUseCase`) and mappers (`scorePayloadToModel`) handle both ideal payloads and incomplete JSON gracefully.
3. **Widget Tests (`testWidgets`)**:
   Ensure native surface widgets render chips, labels, and progress bars as expected given valid domain models.
