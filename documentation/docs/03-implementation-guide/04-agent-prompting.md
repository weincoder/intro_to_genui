---
title: "Paso 4: Configuración del Agente y Prompt Engineering"
sidebar_label: "4. Prompt del Agente"
sidebar_position: 4
---

# Paso 4: Configuración del Agente y Prompt Engineering

En una aplicación con A2UI, el prompt del sistema no se limita a definir el tono de voz; **funciona como la máquina de estados del flujo de la aplicación**. El modelo de IA debe saber exactamente en qué momento emitir una superficie visual y cómo responder cuando dicha superficie emita un evento.

Todo el comportamiento del agente se centraliza en `lib/config/agent/agent_config.dart`.

---

## 🗂️ Constantes de Configuración

```dart title="lib/config/agent/agent_config.dart"
const String memorySessionSurfaceId = 'memory_session';
const String scoreDisplaySurfaceId = 'memory_score';
const String memoryTrainerModelName = 'gemini-2.5-flash';

const String initialAgentGreeting =
    'Vamos a entrenar tu memoria. Dime un tema y cuantas palabras quieres memorizar.';
```

* **`memoryTrainerModelName`**: Selecciona `gemini-2.5-flash`, un modelo con baja latencia ideal para streaming de UI interactivo.
* **`memorySessionSurfaceId` y `scoreDisplaySurfaceId`**: Identificadores constantes para que tanto Flutter como el prompt hagan referencia al mismo identificador de superficie.

---

## 📝 Estructura del System Prompt (`memoryTrainerSystemInstruction`)

El prompt está dividido en 4 secciones estratégicas:

```markdown title="lib/config/agent/agent_config.dart"
## PERSONA
Eres un entrenador experto en memoria.

## OBJETIVO
Guiame en una sesion para memorizar palabras y evaluar mi recuerdo al final.

## REGLAS
Habla conmigo solo sobre entrenamiento de memoria.
Primero pregunta por el tema y por la cantidad de palabras.
La cantidad de palabras debe ser definida por el usuario.
Responde siempre en espanol neutro.
Debes ser breve en tus mensajes de texto.

## PROCESO
### FASE 1: PREPARACION
* Pregunta el tema y la cantidad de palabras.
* Genera palabras individuales del tema solicitado.
* Crea una surface MemorySessionDisplay con las palabras y un temporizador.
* Usa "memory_session" como surface ID.
* Configura durationSeconds segun la cantidad de palabras: 6 segundos por palabra.
* Ejemplo obligatorio: para 10 palabras durationSeconds debe ser 60.
* Configura hideWordsOnTimeout=true.

### FASE 2: MEMORIZACION
* Mientras el temporizador corre, no hagas preguntas de evaluacion.
* Cuando recibas el evento timeoutAction de MemorySessionDisplay, comienza la evaluacion.

### FASE 3: EVALUACION
* Pregunta palabra por palabra para validar recuerdo.
* Asigna 1.0 si la respuesta es correcta.
* Asigna 0.5 si la respuesta es parecida o relacionada semanticamente.
* Asigna 0.0 si no es correcta ni relacionada.
* Despues de cada respuesta, da una retroalimentacion breve.

### FASE 4: RESULTADO FINAL
* Al terminar todas las palabras, crea una surface ScoreDisplay.
* Usa "memory_score" como surface ID.
* ScoreDisplay debe incluir title, totalScore, maxScore y entries.
* Cada entrada en entries debe incluir expectedWord, userAnswer, score y feedback.
* No repitas informacion innecesaria.
```

---

## 🔑 Claves de Prompt Engineering para A2UI

1. **Instrucciones de cálculo explícitas**: Si un componente requiere lógica temporal dependiente de las entradas (por ejemplo, `6 segundos por palabra`), proporciónele al modelo ejemplos numéricos claros (`10 palabras = 60 segundos`).
2. **Coordinación de silencio durante la interacción**: La regla en la **Fase 2** (`Mientras el temporizador corre, no hagas preguntas`) previene que el modelo hable mientras el usuario intenta concentrarse y memorizar.
3. **Mapeo explícito de eventos**: Indicarle textualmente: `Cuando recibas el evento timeoutAction de MemorySessionDisplay, comienza la evaluacion` le permite al modelo saber que ese evento es el disparador para cambiar de estado en la conversación.

---

## 🛠️ Inyección con `PromptBuilder`

Para enviar este prompt al modelo junto con las definiciones de los esquemas del catálogo:

```dart
final PromptBuilder promptBuilder = PromptBuilder.chat(
  catalog: _catalog,
  systemPromptFragments: [memoryTrainerSystemInstruction],
);

// Se envía como el primer mensaje del sistema al iniciar la conversación
_conversation.sendRequest(
  ChatMessage.system(promptBuilder.systemPromptJoined()),
);
```

`PromptBuilder` se encarga de serializar los esquemas de `_catalog` en una descripción entendible por Gemini y adjuntar los fragmentos del sistema.
