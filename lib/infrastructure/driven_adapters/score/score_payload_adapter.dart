import 'package:intro_to_genui/domain/models/score/gateway/score_payload_gateway.dart';
import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';
import 'package:intro_to_genui/infrastructure/helpers/mappers/score_payload_mapper.dart';

class ScorePayloadAdapter implements ScorePayloadGateway {
  @override
  ScoreDisplayPayloadModel parseScorePayload({
    required Map<String, Object?> json,
  }) {
    try {
      return scorePayloadToModel(json: json);
    } catch (e) {
      throw Exception('JSON invalido para ScoreDisplayPayload: $e');
    }
  }
}
