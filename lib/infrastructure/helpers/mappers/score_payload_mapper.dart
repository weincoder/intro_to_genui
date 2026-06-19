import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';

ScoreDisplayPayloadModel scorePayloadToModel({
  required Map<String, Object?> json,
}) {
  final Object? entriesRaw = json['entries'];
  final List<Object?> entriesList = entriesRaw is List<Object?>
      ? entriesRaw
      : <Object?>[];

  final List<ScoreDisplayEntryModel> entries = entriesList
      .whereType<Map<String, Object?>>()
      .map(_entryFromJson)
      .toList();

  final Object? totalScoreRaw = json['totalScore'];
  final Object? maxScoreRaw = json['maxScore'];

  return ScoreDisplayPayloadModel(
    title: (json['title'] as String?) ?? 'Resultados',
    totalScore: totalScoreRaw is num ? totalScoreRaw.toDouble() : 0,
    maxScore: maxScoreRaw is num ? maxScoreRaw.toDouble() : 0,
    entries: entries,
  );
}

ScoreDisplayEntryModel _entryFromJson(Map<String, Object?> json) {
  final Object? scoreRaw = json['score'];

  return ScoreDisplayEntryModel(
    expectedWord: (json['expectedWord'] as String?) ?? '',
    userAnswer: (json['userAnswer'] as String?) ?? '',
    score: scoreRaw is num ? scoreRaw.toDouble() : 0,
    feedback: (json['feedback'] as String?) ?? '',
  );
}
