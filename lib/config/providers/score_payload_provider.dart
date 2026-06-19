import 'package:flutter/foundation.dart';
import 'package:intro_to_genui/domain/models/score/gateway/score_payload_gateway.dart';
import 'package:intro_to_genui/domain/models/score/score_display_payload_model.dart';
import 'package:intro_to_genui/domain/usecase/parse_score_payload_usecase.dart';

class ScorePayloadProvider extends ChangeNotifier {
  final ScorePayloadGateway gateway;
  final ParseScorePayloadUseCase parseUseCase;

  ScorePayloadProvider({required this.gateway})
    : parseUseCase = ParseScorePayloadUseCase(gateway: gateway);

  ScoreDisplayPayloadModel parse({required Map<String, Object?> json}) {
    return parseUseCase.execute(json: json);
  }
}
