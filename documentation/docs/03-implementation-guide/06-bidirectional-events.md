---
title: "Paso 6: Eventos Bidireccionales e Interactividad"
sidebar_label: "6. Eventos Bidireccionales"
sidebar_position: 6
---

# Paso 6: Eventos Bidireccionales e Interactividad

El aspecto más potente de **A2UI** frente a otros enfoques generativos es la **interactividad bidireccional**: el widget de Flutter no es solo una vista estática, sino que puede **despachar eventos nativos de vuelta al modelo de lenguaje**, permitiendo que la aplicación continúe flujos autónomos.

---

## 🔁 El puente de transporte: `_sendAndReceive`

Cuando un usuario envía un mensaje de texto o un widget despacha una interacción, la clase `Conversation` invoca la función `onSend` registrada en el `A2uiTransportAdapter`:

```dart title="lib/ui/pages/memory_trainer_page.dart"
Future<void> _sendAndReceive(ChatMessage msg) async {
  final StringBuffer buffer = StringBuffer();

  for (final part in msg.parts) {
    // 1. Detección de interacción originada en la UI
    if (part.isUiInteractionPart) {
      buffer.write(part.asUiInteractionPart!.interaction);
    } 
    // 2. Detección de texto de usuario convencional
    else if (part is genui.TextPart) {
      buffer.write(part.text);
    }
  }

  if (buffer.isEmpty) return;

  final String text = buffer.toString();
  
  // 3. Envío al modelo Gemini a través de la sesión de chat
  final GenerateContentResponse response = await _chatSession.sendMessage(
    Content.text(text),
  );

  // 4. Inyección de la respuesta de vuelta al adaptador de GenUI
  if (response.text?.isNotEmpty ?? false) {
    _transport.addChunk(response.text!);
  }
}
```

:::important Nota sobre namespaces en imports
Nota que en el archivo de la página importamos `genui` ocultando `TextPart`:
```dart
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
```
Esto evita colisiones de nombres con la clase `TextPart` de `firebase_ai`.
:::

---

## ⏱️ Emisión del Evento desde el Widget

En [`MemorySessionDisplay`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/widgets/memory_session_display.dart), un temporizador local (`Timer.periodic`) cuenta los segundos hacia atrás.

Cuando el tiempo se agota (`_remainingSeconds <= 1`), se invoca `_triggerTimeoutIfNeeded()`:

```dart title="lib/ui/widgets/memory_session_display.dart"
Future<void> _triggerTimeoutIfNeeded() async {
  if (_hasTriggeredTimeout) return;
  _hasTriggeredTimeout = true;
  await widget.onTimeout(widget.data.timeoutAction);
}
```

En el constructor `buildMemorySessionDisplay`, el callback `onTimeout` despacha el evento al contexto de GenUI:

```dart title="lib/ui/widgets/memory_session_display.dart"
onTimeout: (timeoutAction) async {
  if (timeoutAction.actionName.isEmpty) return;

  // 1. Resuelve el contexto de datos vinculado a la acción
  final JsonMap resolvedContext = await resolveContext(
    itemContext.dataContext,
    timeoutAction.actionContext,
  );

  // 2. Despacha el UserActionEvent hacia la conversación
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

## 🎯 ¿Qué ocurre paso a paso en el flujo?

1. **La cuenta regresiva termina:** El usuario estaba viendo las palabras en la pantalla.
2. **El widget oculta las palabras:** `setState` marca `_isMemorizationFinished = true` y el widget muestra: *"Tiempo terminado. Las palabras se han ocultado."*
3. **El widget emite `timeoutAction`:** Se despacha el evento sin intervención del usuario.
4. **GenUI lo serializa:** Lo empaqueta como un `part.isUiInteractionPart`.
5. **Gemini recibe la señal:** En el prompt del sistema le ordenamos:
   > *"Cuando recibas el evento timeoutAction de MemorySessionDisplay, comienza la evaluacion."*
6. **Gemini genera la pregunta:** Emite un mensaje de texto preguntando: *"¡Tiempo agotado! Empecemos. ¿Cuál fue la primera palabra que memorizaste?"*.
7. **La UI recibe el turno:** Aparece la burbuja del agente y el campo de texto se habilita para que el usuario responda.

¡El ciclo A2UI se ha completado de manera completamente autónoma y guiada!
