---
title: "Superficie 1: MemorySessionDisplay"
sidebar_label: "MemorySessionDisplay"
sidebar_position: 1
---

# Superficie 1: `MemorySessionDisplay`

La superficie `MemorySessionDisplay` encapsula la lógica visual y temporal de la fase de memorización. Es un widget interactivo con estado (`StatefulWidget`) que controla un temporizador regresivo y oculta el contenido cuando el tiempo expira.

---

## 🏗️ Modelo de Datos y Validación Defensiva

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
    // 1. Extracción segura de la lista de palabras
    final Object? wordsRaw = json['words'];
    final List<String> words = wordsRaw is List<Object?>
        ? wordsRaw.whereType<String>().toList()
        : <String>[];

    // 2. Normalización de números int / num
    final Object? durationRaw = json['durationSeconds'];
    final int? requestedDurationSeconds = durationRaw is int
        ? durationRaw
        : durationRaw is num
            ? durationRaw.toInt()
            : null;

    return _MemorySessionData(
      title: (json['title'] as String?) ?? 'Sesion de memoria',
      topic: (json['topic'] as String?) ?? 'General',
      words: words,
      // 3. Resolución con el proveedor de dominio
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

:::tip Por qué normalizar con `MemorySessionProvider`
Si el modelo olvida enviar `durationSeconds` o envía un valor irrazonable, `MemorySessionProvider` (a través de `MemorySessionDefaultsAdapter`) aplica la regla de negocio oficial de 6 segundos por palabra:
```dart
int resolveDurationSeconds({required int wordCount, int? requestedDurationSeconds}) {
  return requestedDurationSeconds ?? (wordCount * 6);
}
```
Esto garantiza robustez total ante inconsistencias del LLM.
:::

---

## ⏱️ Ciclo de Vida del Temporizador

Para evitar fugas de memoria y responder si el modelo actualiza la sesión mientras está activa, el widget implementa un manejo riguroso del ciclo de vida:

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

  // Si la sesión cambió de palabras o duración, reiniciar el timer
  if (isDifferentSession || (durationChanged && !_isMemorizationFinished)) {
    _restartTimer();
  }
}

@override
void dispose() {
  _timer?.cancel(); // Cancelar el timer para evitar memory leaks
  super.dispose();
}
```

---

## 👁️ Ocultación de Palabras y Renderizado

Cuando `_remainingSeconds` llega a 0, el widget reemplaza el `Wrap` de palabras por un mensaje de notificación:

```dart title="lib/ui/widgets/memory_session_display.dart"
final bool shouldHideWords =
    _isMemorizationFinished || _remainingSeconds == 0;

// ...
if (shouldHideWords)
  Text(
    'Tiempo terminado. Las palabras se han ocultado.',
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
Esto impide que el usuario haga trampa leyendo las palabras durante la fase de evaluación.
