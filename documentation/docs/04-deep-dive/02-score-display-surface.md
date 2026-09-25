---
title: "Superficie 2: ScoreDisplay y Búho Emocional"
sidebar_label: "ScoreDisplay y Retro Owl"
sidebar_position: 2
---

# Superficie 2: `ScoreDisplay` y Búho Emocional

La superficie `ScoreDisplay` es el componente visual presentado en la **Fase 4 (Resultado Final)**. Muestra el puntaje global obtenido, una barra de progreso porcentual, el desglose palabra por palabra con feedback semántico y una ilustración vectorial del búho mascota cuyo estado emocional reacciona al puntaje.

---

## 🦉 Estados Emocionales del Búho (`OwlPainter`)

La aplicación incluye un pintor personalizado en Canvas ([`OwlPainter`](file:///Users/danielherrerasanchez/develop/gen_ui_flutter_med_fest/intro_to_genui/lib/ui/painters/owl_painter.dart)) que dibuja un búho retro con ojos pixelados, pico y alas animadas.

El estado del búho se determina mediante una regla de negocio en el caso de uso `ScoreMoodUseCase`:

```dart title="lib/infrastructure/driven_adapters/score/score_rules_adapter.dart"
@override
ScoreMood getScoreMood({required double percentage}) {
  // Si el usuario superó o igualó el 70% de efectividad, el búho celebra
  if (percentage >= 0.70) {
    return ScoreMood.celebrating;
  }
  return ScoreMood.sad;
}
```

```dart title="lib/ui/widgets/score_display.dart"
class _ScoreOwlMood extends StatelessWidget {
  final ScoreMood scoreMood;
  final double size;

  const _ScoreOwlMood({required this.scoreMood, required this.size});

  @override
  Widget build(BuildContext context) {
    final bool isPassing = scoreMood == ScoreMood.celebrating;
    final String label = isPassing
        ? 'El buho esta celebrando 🎉'
        : 'El buho esta triste 😢';

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: OwlPainter(
                    scenario: isPassing
                        ? OwlScenario.success
                        : OwlScenario.empty,
                    animValue: isPassing ? 0.6 : 0.1,
                  ),
                ),
              ),
              if (!isPassing)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Color(0xFFE05A7A),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
```

---

## 📱 Diseño Responsivo con `LayoutBuilder`

La superficie adapta su disposición visual dependiendo del ancho de pantalla disponible (móvil vs escritorio/tablet):

```dart title="lib/ui/widgets/score_display.dart"
LayoutBuilder(
  builder: (context, constraints) {
    final bool isCompact = constraints.maxWidth < 700;
    final double owlSize = isCompact ? 120 : 170;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompact) ...[
          // En móviles: disposición vertical en columna
          Text(data.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _ScoreOwlMood(scoreMood: scoreMood, size: owlSize),
        ] else
          // En pantallas amplias: disposición horizontal en fila
          Row(
            children: [
              Expanded(
                child: Text(data.title, style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(width: 16),
              _ScoreOwlMood(scoreMood: scoreMood, size: owlSize),
            ],
          ),
        // ...
      ],
    );
  },
)
```

---

## 📋 Desglose Detallado por Palabra

El payload devuelto por Gemini incluye un arreglo `entries` que se renderiza directamente en una lista de widgets `ListTile`:

```dart title="lib/ui/widgets/score_display.dart"
...data.entries.map(
  (entry) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text('${entry.expectedWord} -> ${entry.userAnswer}'),
    subtitle: Text(entry.feedback),
    trailing: Text(entry.score.toStringAsFixed(1)),
  ),
),
```

Cada elemento muestra:
* La palabra esperada frente a la respuesta que dio el usuario.
* La justificación o feedback semántico del agente (por ejemplo: *"Respuesta exacta"*, o *"Palabra relacionada pero no idéntica"*).
* El puntaje numérico otorgado (`1.0`, `0.5`, `0.0`).
