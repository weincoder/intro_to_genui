---
title: "Paso 5: Orquestación de la Conversación y Renderizado"
sidebar_label: "5. Orquestación y Renderizado"
sidebar_position: 5
---

# Paso 5: Orquestación de la Conversación y Renderizado

En este paso unimos todas las piezas en la vista principal: la sesión de chat con Gemini, el controlador de superficies de GenUI y la interfaz de usuario de Flutter.

Todo esto reside en [`MemoryTrainerPage`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/pages/memory_trainer_page.dart).

---

## 🗃️ Modelo de Elementos de Conversación

Para renderizar tanto burbujas de texto como widgets de interfaz nativa en la misma lista de scroll, creamos una jerarquía sellada (`sealed class`):

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

* **`instanceVersion`**: Cada vez que el agente actualiza o reemite una superficie, incrementamos la versión para forzar la reconstrucción limpia del widget nativo en Flutter usando una clave única (`ValueKey`).

---

## ⚙️ Inicialización de GenUI en `initState`

En el estado de la página (`_MemoryTrainerPageState`), configuramos el pipeline de comunicación:

```dart title="lib/ui/pages/memory_trainer_page.dart"
@override
void initState() {
  super.initState();

  // 1. Iniciar el modelo generativo de Gemini vía Firebase Vertex AI
  final GenerativeModel model = FirebaseAI.vertexAI().generativeModel(
    model: memoryTrainerModelName,
  );
  _chatSession = model.startChat();

  // 2. Registrar el Catálogo con nuestras superficies
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

  // 3. Crear el controlador de superficies y el adaptador de transporte
  _controller = SurfaceController(catalogs: [_catalog]);
  _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
  
  // 4. Instanciar la Conversación uniendo el controlador y el transporte
  _conversation = Conversation(
    controller: _controller,
    transport: _transport,
  );

  // 5. Escuchar eventos del flujo conversacional de GenUI
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

  // 6. Configurar y enviar el system prompt inicial con los schemas
  final PromptBuilder promptBuilder = PromptBuilder.chat(
    catalog: _catalog,
    systemPromptFragments: [memoryTrainerSystemInstruction],
  );

  _conversation.sendRequest(
    ChatMessage.system(promptBuilder.systemPromptJoined()),
  );

  // Mensaje de bienvenida inicial
  _items.add(TextItem(text: initialAgentGreeting));
}
```

---

## 🎨 Renderizado Heterogéneo en el `build`

En el método `build`, iteramos sobre la lista polimórfica `_items`. El operador `switch` de Dart permite mapear limpiamente cada tipo de elemento:

```dart title="lib/ui/pages/memory_trainer_page.dart"
ListView(
  controller: _scrollController,
  padding: const EdgeInsets.all(16),
  children: [
    for (final item in _items)
      switch (item) {
        // Mensaje de texto ordinario
        TextItem() => MessageBubble(
          text: item.text,
          isUser: item.isUser,
        ),
        
        // Superficie generada por A2UI
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

### Indicador de carga automático
GenUI expone `_conversation.state` como un `ValueListenable<ConversationState>`. Podemos mostrar un indicador de progreso (`LinearProgressIndicator`) de forma reactiva mientras el modelo genera contenido o valida una superficie:

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
