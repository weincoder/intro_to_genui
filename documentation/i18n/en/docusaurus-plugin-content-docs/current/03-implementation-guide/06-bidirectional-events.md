---
title: "Step 6: Bidirectional Events & Interactivity"
sidebar_label: "6. Bidirectional Events"
sidebar_position: 6
---

# Step 6: Bidirectional Events & Interactivity

The standout feature of **A2UI** compared to static generative UI is **bidirectional interactivity**: Flutter widgets are not merely passive render targets; they can **dispatch native events back to the AI model**, driving autonomous multi-step workflows.

---

## 🔁 The Transport Bridge: `_sendAndReceive`

When a user submits text or a widget dispatches an action event, `Conversation` invokes `onSend` on the `A2uiTransportAdapter`:

```dart title="lib/ui/pages/memory_trainer_page.dart"
Future<void> _sendAndReceive(ChatMessage msg) async {
  final StringBuffer buffer = StringBuffer();

  for (final part in msg.parts) {
    // 1. Detect UI interaction event parts
    if (part.isUiInteractionPart) {
      buffer.write(part.asUiInteractionPart!.interaction);
    } 
    // 2. Detect standard text parts
    else if (part is genui.TextPart) {
      buffer.write(part.text);
    }
  }

  if (buffer.isEmpty) return;

  final String text = buffer.toString();
  
  // 3. Send to Gemini through the chat session
  final GenerateContentResponse response = await _chatSession.sendMessage(
    Content.text(text),
  );

  // 4. Feed response chunk back into GenUI transport
  if (response.text?.isNotEmpty ?? false) {
    _transport.addChunk(response.text!);
  }
}
```

:::important Import Namespace Aliasing
Notice that in the page file we import `genui` hiding `TextPart`:
```dart
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
```
This avoids naming collisions with `firebase_ai`'s `TextPart` class.
:::

---

## ⏱️ Emitting Events from the Widget

Inside [`MemorySessionDisplay`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/widgets/memory_session_display.dart), an internal countdown timer (`Timer.periodic`) ticks down.

When `_remainingSeconds <= 1`, `_triggerTimeoutIfNeeded()` is called:

```dart title="lib/ui/widgets/memory_session_display.dart"
Future<void> _triggerTimeoutIfNeeded() async {
  if (_hasTriggeredTimeout) return;
  _hasTriggeredTimeout = true;
  await widget.onTimeout(widget.data.timeoutAction);
}
```

Inside the builder `buildMemorySessionDisplay`, the `onTimeout` callback dispatches the action to GenUI's context:

```dart title="lib/ui/widgets/memory_session_display.dart"
onTimeout: (timeoutAction) async {
  if (timeoutAction.actionName.isEmpty) return;

  // 1. Resolve contextual data expressions
  final JsonMap resolvedContext = await resolveContext(
    itemContext.dataContext,
    timeoutAction.actionContext,
  );

  // 2. Dispatch UserActionEvent into the GenUI pipeline
  itemContext.dispatchEvent(
    UserActionEvent(
      name: timeoutAction.actionName,
      sourceComponentId: itemContext.id,
      context: resolvedContext,
    ),
  );
}
```

---

## 🎯 Step-by-Step Execution Sequence

1. **Countdown ends:** The user was viewing the word chips.
2. **Widget conceals words:** Local state updates `_isMemorizationFinished = true` and the card displays: *"Time is up. Words have been concealed."*
3. **Widget dispatches `timeoutAction`:** Fired automatically without user intervention.
4. **GenUI serializes event:** Encapsulates it as `part.isUiInteractionPart`.
5. **Gemini receives signal:** The system instruction dictates:
   > *"When you receive the timeoutAction event from MemorySessionDisplay, start the evaluation."*
6. **Gemini asks first question:** Emits a conversational prompt: *"Time's up! Let's begin. What was the first word you memorized?"*.
7. **UI unlocks:** The coach's message bubble appears and the text field is enabled for user input.

The A2UI closed loop is fully executed!
