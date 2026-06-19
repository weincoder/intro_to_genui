import 'package:intro_to_genui/domain/models/score/gateway/score_gateway.dart';

class ScorePercentageUseCase {
  final ScoreGateway gateway;

  ScorePercentageUseCase({required this.gateway});

  double execute({required double totalScore, required double maxScore}) {
    return gateway.getScorePercentage(
      totalScore: totalScore,
      maxScore: maxScore,
    );
  }
}
