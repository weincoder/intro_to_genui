---
title: "Buenas Prácticas para Producción con A2UI"
sidebar_label: "Buenas Prácticas"
sidebar_position: 1
---

# Buenas Prácticas para Producción con A2UI

Implementar interfaces generadas por agentes de IA (A2UI) requiere consideraciones de estabilidad y diseño que van más allá del desarrollo tradicional en Flutter. A continuación se presentan las mejores prácticas adoptadas en este proyecto.

---

## 🛡️ 1. Mapeo Defensivo y Valores por Defecto (Fallback Rules)

Nunca asumas que el modelo de lenguaje devolverá exactamente los tipos de datos requeridos en cada circunstancia:

* **Números flotantes vs enteros**: En JavaScript/JSON, no hay distinción formal entre `int` y `double`. Un número `10` puede llegar como `10` o `10.0`. En tus mappers, castea siempre contra `num`:
  ```dart
  final Object? totalRaw = json['totalScore'];
  final double total = totalRaw is num ? totalRaw.toDouble() : 0.0;
  ```
* **Listas nulas o con elementos erróneos**: Filtra siempre por tipo:
  ```dart
  final Object? wordsRaw = json['words'];
  final List<String> words = wordsRaw is List<Object?>
      ? wordsRaw.whereType<String>().toList()
      : <String>[];
  ```
* **Reglas de negocio como respaldo**: Si el LLM omite un campo opcional como la duración en segundos, utiliza un adaptador que calcule el valor predeterminado basándose en la lógica del dominio (`wordCount * 6`).

---

## 🔑 2. Identificación Inmutable de Superficies (`ValueKey`)

Cuando el modelo actualiza una superficie existente o genera una nueva versión, Flutter puede reutilizar incorrectamente el `Element` del árbol de widgets si la clave no cambia:

```dart
// ❌ Incorrecto: Reutiliza el estado previo del widget
Surface(
  key: ValueKey(item.surfaceId),
  surfaceContext: _controller.contextFor(item.surfaceId),
)

// ✅ Correcto: Fuerza la recreación limpia con la versión de instancia
Surface(
  key: ValueKey('${item.surfaceId}_${item.instanceVersion}'),
  surfaceContext: _controller.contextFor(item.surfaceId),
)
```

Al incrementar `_nextSurfaceInstanceVersion` cada vez que se emite una superficie, garantizamos que los timers, animaciones y controladores internos del widget se reinicien de forma predecible.

---

## 🧹 3. Prevención de Fugas de Memoria (Memory Leaks)

Cualquier superficie interactiva que ejecute timers (`Timer.periodic`), oyentes de scroll o controladores de animación **debe** limpiar sus recursos en `dispose()`:

```dart
@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
```

Si el usuario navega hacia atrás o la superficie se remueve de la lista, el temporizador debe detenerse inmediatamente para no seguir despachando eventos al agente en segundo plano.

---

## 🧪 4. Estrategia de Pruebas Automatizadas

En proyectos de A2UI, las pruebas deben dividirse en tres niveles:

1. **Pruebas de Configuración de Agente (`test/widget_test.dart`)**:
   Verifican que los identificadores de superficie y las instrucciones del sistema no hayan sufrido regresiones ni pérdidas de palabras clave esenciales.
   ```dart
   test('mantiene compatibilidad de systemInstruction en main', () {
     expect(systemInstruction, equals(memoryTrainerSystemInstruction));
     expect(systemInstruction, contains('ScoreDisplay'));
     expect(systemInstruction, contains('MemorySessionDisplay'));
   });
   ```
2. **Pruebas Unitarias de Dominio e Infraestructura**:
   Verifican que los casos de uso (`ScorePercentageUseCase`, `ScoreMoodUseCase`) y los mappers (`scorePayloadToModel`) procesen correctamente tanto payloads perfectos como JSONs incompletos.
3. **Pruebas de Widget (`testWidgets`)**:
   Comprueban que el widget de la superficie renderice adecuadamente los chips, textos y progress bars dados los modelos de dominio.
