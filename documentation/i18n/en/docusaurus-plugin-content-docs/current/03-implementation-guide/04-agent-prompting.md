---
title: "Step 4: Agent Configuration & Prompt Engineering"
sidebar_label: "4. Agent Prompting"
sidebar_position: 4
---

# Step 4: Agent Configuration & Prompt Engineering

In an A2UI application, the system prompt does not merely set tone or personality; **it functions as the application's state machine**. The LLM must know exactly when to render a surface and how to react when that surface fires an event.

All agent configurations are maintained in `lib/config/agent/agent_config.dart`.

---

## 🗂️ Configuration Constants

```dart title="lib/config/agent/agent_config.dart"
const String memorySessionSurfaceId = 'memory_session';
const String scoreDisplaySurfaceId = 'memory_score';
const String memoryTrainerModelName = 'gemini-2.5-flash';

const String initialAgentGreeting =
    'Vamos a entrenar tu memoria. Dime un tema y cuantas palabras quieres memorizar.';
```

* **`memoryTrainerModelName`**: Uses `gemini-2.5-flash` for low-latency streaming and snappy UI response times.
* **`memorySessionSurfaceId` and `scoreDisplaySurfaceId`**: Shared constants referenced both in Dart code and the prompt.

---

## 📝 System Prompt Structure (`memoryTrainerSystemInstruction`)

The instruction prompt is divided into 4 strategic phases:

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

## 🔑 A2UI Prompting Guidelines

1. **Concrete Calculation Rules**: When components depend on computed timing (e.g. `6 seconds per word`), provide clear arithmetic examples (`10 words = 60 seconds`) to avoid ambiguous outputs.
2. **Intentional Silence**: The rule in **Phase 2** (*"While the timer is running, do not ask evaluation questions"*) keeps the agent quiet while the user focuses on memorization.
3. **Event Mapping**: Explicitly stating *"When you receive the timeoutAction event from MemorySessionDisplay, start the evaluation"* teaches Gemini to treat native UI events as state transition triggers.

---

## 🛠️ Prompt Injection via `PromptBuilder`

To send this instruction along with catalog schemas:

```dart
final PromptBuilder promptBuilder = PromptBuilder.chat(
  catalog: _catalog,
  systemPromptFragments: [memoryTrainerSystemInstruction],
);

_conversation.sendRequest(
  ChatMessage.system(promptBuilder.systemPromptJoined()),
);
```
