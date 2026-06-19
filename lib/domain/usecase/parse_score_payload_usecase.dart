import 'package:intro_to_genui/domain/models/score/gateway/score_payload_gateway.dart';
import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';

class ParseScorePayloadUseCase {
  final ScorePayloadGateway gateway;

  ParseScorePayloadUseCase({required this.gateway});

  ScoreDisplayPayloadModel execute({required Map<String, Object?> json}) {
    return gateway.parseScorePayload(json: json);
  }
}
