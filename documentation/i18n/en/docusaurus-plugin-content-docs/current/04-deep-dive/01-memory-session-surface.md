---
title: "Surface 1: MemorySessionDisplay"
sidebar_label: "MemorySessionDisplay"
sidebar_position: 1
---

# Surface 1: `MemorySessionDisplay`

The `MemorySessionDisplay` surface encapsulates the visual and temporal logic of the memorization phase. It is an interactive `StatefulWidget` managing a countdown timer and concealing its contents when time runs out.

---

## 🏗️ Data Model & Defensive Parsing

```dart title="lib/ui/widgets/memory_session_display.dart"
class _MemorySessionData {
  final String title;
  final String topic;
  final List<String> words;
  final int durationSeconds;
  final bool hideWordsOnTimeout;
  final _TimeoutActionData timeoutAction;

  const _MemorySessionData({
    required this.title,
    required this.topic,
    required this.words,
    required this.durationSeconds,
    required this.hideWordsOnTimeout,
    required this.timeoutAction,
  });

  factory _MemorySessionData.fromJson({
    required Map<String, Object?> json,
    required MemorySessionProvider memorySessionProvider,
  }) {
    // 1. Safe extraction of string word list
    final Object? wordsRaw = json['words'];
    final List<String> words = wordsRaw is List<Object?>
        ? wordsRaw.whereType<String>().toList()
        : <String>[];

    // 2. Normalization of int/num types
    final Object? durationRaw = json['durationSeconds'];
    final int? requestedDurationSeconds = durationRaw is int
        ? durationRaw
        : durationRaw is num
            ? durationRaw.toInt()
            : null;

    return _MemorySessionData(
      title: (json['title'] as String?) ?? 'Memory Session',
      topic: (json['topic'] as String?) ?? 'General',
      words: words,
      // 3. Domain provider fallback calculation
      durationSeconds: memorySessionProvider.resolveDurationSeconds(
        wordCount: words.length,
        requestedDurationSeconds: requestedDurationSeconds,
      ),
      hideWordsOnTimeout: memorySessionProvider.resolveHideWordsOnTimeout(
        requestedValue: json['hideWordsOnTimeout'] as bool?,
      ),
      timeoutAction: _TimeoutActionData.fromJson(
        json['timeoutAction'] as JsonMap?,
      ),
    );
  }
}
```

:::tip Normalizing with `MemorySessionProvider`
If the AI agent forgets to supply `durationSeconds` or sends an irregular value, `MemorySessionProvider` (via `MemorySessionDefaultsAdapter`) enforces the domain rule of 6 seconds per word:
```dart
int resolveDurationSeconds({required int wordCount, int? requestedDurationSeconds}) {
  return requestedDurationSeconds ?? (wordCount * 6);
}
```
This guarantees UI resilience regardless of LLM inconsistencies.
:::

---

## ⏱️ Timer Lifecycle Management

To prevent memory leaks and handle cases where Gemini updates the surface mid-stream, the widget implements strict lifecycle handling:

```dart title="lib/ui/widgets/memory_session_display.dart"
@override
void initState() {
  super.initState();
  _restartTimer();
}

@override
void didUpdateWidget(covariant _MemorySessionDisplay oldWidget) {
  super.didUpdateWidget(oldWidget);
  final bool isDifferentSession =
      oldWidget.data.title != widget.data.title ||
      oldWidget.data.topic != widget.data.topic ||
      !listEquals(oldWidget.data.words, widget.data.words);

  final bool durationChanged =
      oldWidget.data.durationSeconds != widget.data.durationSeconds;

  if (isDifferentSession || (durationChanged && !_isMemorizationFinished)) {
    _restartTimer();
  }
}

@override
void dispose() {
  _timer?.cancel(); // Cancel timer to prevent memory leaks
  super.dispose();
}
```

---

## 👁️ Word Concealment & Layout

When `_remainingSeconds` reaches 0, the word chips are swapped for a status notification:

```dart title="lib/ui/widgets/memory_session_display.dart"
final bool shouldHideWords =
    _isMemorizationFinished || _remainingSeconds == 0;

// ...
if (shouldHideWords)
  Text(
    'Time is up. Words have been concealed.',
    style: Theme.of(context).textTheme.bodyLarge,
  )
else
  Wrap(
    spacing: 8,
    runSpacing: 8,
    children: widget.data.words
        .map((word) => Chip(label: Text(word)))
        .toList(),
  ),
```
This prevents the user from peeking at the words during the quiz round.
