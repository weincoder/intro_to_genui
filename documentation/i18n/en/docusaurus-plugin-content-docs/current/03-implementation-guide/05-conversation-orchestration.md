---
title: "Step 5: Conversation Orchestration & Rendering"
sidebar_label: "5. Orchestration & Rendering"
sidebar_position: 5
---

# Step 5: Conversation Orchestration & Rendering

In this step, we assemble all parts in the main view: the Gemini chat session, the GenUI surface controller, and the Flutter widget tree.

This logic is centralized in [`MemoryTrainerPage`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/pages/memory_trainer_page.dart).

---

## 🗃️ Conversation Item Polymorphism

To render both plain conversational messages and native UI surfaces within the same scrollable list, we declare a sealed hierarchy:

```dart title="lib/ui/pages/memory_trainer_page.dart"
sealed class ConversationItem {}

class TextItem extends ConversationItem {
  final String text;
  final bool isUser;

  TextItem({required this.text, this.isUser = false});
}

class SurfaceItem extends ConversationItem {
  final String surfaceId;
  final int instanceVersion;

  SurfaceItem({required this.surfaceId, required this.instanceVersion});
}
```

* **`instanceVersion`**: When a surface is updated or re-emitted, incrementing this version forces Flutter to rebuild the widget cleanly using a fresh `ValueKey`.

---

## ⚙️ Initializing GenUI in `initState`

In `_MemoryTrainerPageState`, we wire up the communication pipeline:

```dart title="lib/ui/pages/memory_trainer_page.dart"
@override
void initState() {
  super.initState();

  // 1. Initialize Gemini model via Firebase Vertex AI
  final GenerativeModel model = FirebaseAI.vertexAI().generativeModel(
    model: memoryTrainerModelName,
  );
  _chatSession = model.startChat();

  // 2. Build the Catalog registering our custom surfaces
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

  // 3. Create SurfaceController and Transport Adapter
  _controller = SurfaceController(catalogs: [_catalog]);
  _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
  
  // 4. Instantiate Conversation combining controller and transport
  _conversation = Conversation(
    controller: _controller,
    transport: _transport,
  );

  // 5. Listen to GenUI conversation stream events
  _conversation.events.listen((event) {
    setState(() {
      switch (event) {
        case ConversationSurfaceAdded added:
          _items.removeWhere(
            (item) => item is SurfaceItem && item.surfaceId == added.surfaceId,
          );
          _items.add(
            SurfaceItem(
              surfaceId: added.surfaceId,
              instanceVersion: ++_nextSurfaceInstanceVersion,
            ),
          );
          _scrollToBottom();
          
        case ConversationSurfaceRemoved removed:
          _items.removeWhere(
            (item) => item is SurfaceItem && item.surfaceId == removed.surfaceId,
          );
          
        case ConversationContentReceived content:
          _items.add(TextItem(text: content.text, isUser: false));
          _scrollToBottom();
          
        case ConversationError error:
          debugPrint('GenUI Error: ${error.error}');
          
        default:
      }
    });
  });

  // 6. Send initial system prompt with schema definitions
  final PromptBuilder promptBuilder = PromptBuilder.chat(
    catalog: _catalog,
    systemPromptFragments: [memoryTrainerSystemInstruction],
  );

  _conversation.sendRequest(
    ChatMessage.system(promptBuilder.systemPromptJoined()),
  );

  _items.add(TextItem(text: initialAgentGreeting));
}
```

---

## 🎨 Heterogeneous List Rendering

Inside `build`, we iterate over `_items`. Dart 3's pattern matching allows clean widget switching:

```dart title="lib/ui/pages/memory_trainer_page.dart"
ListView(
  controller: _scrollController,
  padding: const EdgeInsets.all(16),
  children: [
    for (final item in _items)
      switch (item) {
        TextItem() => MessageBubble(
          text: item.text,
          isUser: item.isUser,
        ),
        
        SurfaceItem() => Surface(
          key: ValueKey(
            '${item.surfaceId}_${item.instanceVersion}',
          ),
          surfaceContext: _controller.contextFor(
            item.surfaceId,
          ),
        ),
      },
  ],
)
```

### Loading State Feedback
GenUI exposes `_conversation.state` as a `ValueListenable<ConversationState>`. We render a `LinearProgressIndicator` reactively while the agent is processing:

```dart
ValueListenableBuilder<ConversationState>(
  valueListenable: _conversation.state,
  builder: (context, state, child) {
    if (state.isWaiting) {
      return const LinearProgressIndicator();
    }
    return const SizedBox.shrink();
  },
)
```
