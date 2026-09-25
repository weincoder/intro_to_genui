---
title: "Paso 2: Definición de Esquemas JSON"
sidebar_label: "2. Esquemas JSON"
sidebar_position: 2
---

# Paso 2: Definición de Esquemas JSON

En A2UI, la interfaz de usuario no se genera con código Flutter generado al vuelo por la IA (lo cual sería peligroso y difícil de renderizar de forma segura). En su lugar, **el desarrollador define un contrato estricto en formato JSON Schema**. 

El paquete `json_schema_builder` permite declarar estos esquemas en Dart con una sintaxis limpia y fuertemente tipada.

---

## 📐 Esquema 1: `MemorySessionDisplay` (Con Acción Interactiva)

Este componente representa la tarjeta donde se muestran las palabras a memorizar y se ejecuta la cuenta regresiva.

Observa cómo se define el esquema:

```dart title="lib/ui/widgets/memory_session_display.dart"
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final memorySessionDisplaySchema = S.object(
  properties: {
    // 1. Identificador de componente fijo
    'component': S.string(enumValues: ['MemorySessionDisplay']),
    
    // 2. Metadatos de la sesión
    'title': S.string(description: 'Titulo del bloque de memorizacion.'),
    'topic': S.string(description: 'Tema elegido por el usuario.'),
    'words': S.list(
      description: 'Lista de palabras que se deben memorizar.',
      items: S.string(),
    ),
    'durationSeconds': S.integer(
      description: 'Duracion total del temporizador en segundos.',
    ),
    'hideWordsOnTimeout': S.boolean(
      description: 'Indica si se deben ocultar las palabras al finalizar.',
    ),

    // 3. Definición de acción/callback (evento interactivo)
    'timeoutAction': A2uiSchemas.action(
      description: 'Accion que se dispara cuando el temporizador termina.',
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

### Elementos clave del esquema:
* **`component`**: Usar `enumValues: ['MemorySessionDisplay']` le indica al modelo que este campo siempre debe contener el nombre exacto de la superficie para facilitar el enrutamiento.
* **`description`**: Las descripciones en cada propiedad guían al modelo de IA para saber qué valor colocar en cada campo.
* **`A2uiSchemas.action(...)`**: Es una función provista por `genui` que genera un esquema estándar para eventos y callbacks. El modelo puede estructurar el evento `timeoutAction` indicando el nombre de la acción (`name`) y su contexto de datos (`context`).

---

## 📊 Esquema 2: `ScoreDisplay` (Con Objetos Anidados)

Este componente visualiza la calificación obtenida por el usuario una vez concluida la ronda de evaluación:

```dart title="lib/ui/widgets/score_display.dart"
import 'package:json_schema_builder/json_schema_builder.dart';

final scoreDisplaySchema = S.object(
  properties: {
    'component': S.string(enumValues: ['ScoreDisplay']),
    'title': S.string(description: 'Titulo de la tarjeta de resultados.'),
    'totalScore': S.number(description: 'Puntuacion total obtenida.'),
    'maxScore': S.number(description: 'Puntuacion maxima posible.'),
    'entries': S.list(
      description: 'Detalle de evaluacion por palabra.',
      items: S.object(
        properties: {
          'expectedWord': S.string(
            description: 'Palabra esperada en la ronda.',
          ),
          'userAnswer': S.string(description: 'Respuesta dada por el usuario.'),
          'score': S.number(description: 'Puntaje otorgado para la respuesta.'),
          'feedback': S.string(
            description: 'Justificacion breve de la calificacion.',
          ),
        },
        required: ['expectedWord', 'userAnswer', 'score', 'feedback'],
      ),
    ),
  },
  required: ['title', 'totalScore', 'maxScore', 'entries'],
);
```

### Características notables:
* **Propiedades numéricas flexibles (`S.number()`)**: Admite tanto números enteros como decimales (por ejemplo, `0.5`, `1.0`), ideal para puntuaciones parciales.
* **Listas de objetos anidados (`S.list(items: S.object(...))`)**: Permite que el modelo devuelva una lista detallada con la evaluación de cada palabra, sin ambigüedad en los tipos.

---

## 💡 ¿Cómo consume el LLM estos esquemas?

Cuando iniciamos la conversación con `genui`, estos esquemas se traducen automáticamente a especificaciones OpenAPI / JSON Schema y se inyectan en el prompt del sistema. De este modo, Gemini **sabe exactamente qué formato producir** y evita inventar nombres de propiedades inexistentes.
