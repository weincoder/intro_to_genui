import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:intro_to_genui/config/providers/score_payload_provider.dart';
import 'package:intro_to_genui/config/providers/score_provider.dart';
import 'package:intro_to_genui/domain/models/score/gateway/score_gateway.dart';
import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';
import 'package:intro_to_genui/ui/painters/owl_painter.dart';
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

class _ScoreDisplay extends StatelessWidget {
  final ScoreDisplayPayloadModel data;
  final ScoreProvider scoreProvider;

  const _ScoreDisplay({required this.data, required this.scoreProvider});

  @override
  Widget build(BuildContext context) {
    final double percentage = scoreProvider.resolveScorePercentage(
      totalScore: data.totalScore,
      maxScore: data.maxScore,
    );
    final ScoreMood scoreMood = scoreProvider.resolveScoreMood(
      percentage: percentage,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 700;
            final double owlSize = isCompact ? 120 : 170;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompact) ...[
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _ScoreOwlMood(scoreMood: scoreMood, size: owlSize),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _ScoreOwlMood(scoreMood: scoreMood, size: owlSize),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  'Puntaje: ${data.totalScore.toStringAsFixed(1)} / ${data.maxScore.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: percentage),
                const SizedBox(height: 16),
                Text(
                  'Detalle por palabra',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...data.entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${entry.expectedWord} -> ${entry.userAnswer}'),
                    subtitle: Text(entry.feedback),
                    trailing: Text(entry.score.toStringAsFixed(1)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScoreOwlMood extends StatelessWidget {
  final ScoreMood scoreMood;
  final double size;

  const _ScoreOwlMood({required this.scoreMood, required this.size});

  @override
  Widget build(BuildContext context) {
    final bool isPassing = scoreMood == ScoreMood.celebrating;
    final String label = isPassing
        ? 'El buho esta celebrando'
        : 'El buho esta triste';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

CatalogItem buildScoreDisplay({
  required ScoreProvider scoreProvider,
  required ScorePayloadProvider scorePayloadProvider,
}) {
  return CatalogItem(
    name: 'ScoreDisplay',
    dataSchema: scoreDisplaySchema,
    widgetBuilder: (itemContext) {
      final Map<String, Object?> json =
          itemContext.data as Map<String, Object?>;
      final ScoreDisplayPayloadModel data = scorePayloadProvider.parse(
        json: json,
      );

      return _ScoreDisplay(data: data, scoreProvider: scoreProvider);
    },
  );
}
