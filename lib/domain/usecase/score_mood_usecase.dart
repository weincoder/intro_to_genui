import 'package:intro_to_genui/domain/models/score/gateway/score_gateway.dart';

class ScoreMoodUseCase {
  final ScoreGateway gateway;

  ScoreMoodUseCase({required this.gateway});

  ScoreMood execute({required double percentage}) {
    return gateway.getScoreMood(percentage: percentage);
  }
}
