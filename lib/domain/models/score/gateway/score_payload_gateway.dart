import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';

abstract class ScorePayloadGateway {
  ScoreDisplayPayloadModel parseScorePayload({
    required Map<String, Object?> json,
  });
}
