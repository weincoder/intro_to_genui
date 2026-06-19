import 'package:intro_to_genui/domain/models/score/gateway/score_gateway.dart';

class ScoreRulesAdapter implements ScoreGateway {
  @override
  double getScorePercentage({
    required double totalScore,
    required double maxScore,
  }) {
    if (maxScore <= 0) {
      return 0;
    }

    final double percentage = totalScore / maxScore;
    if (percentage < 0) {
      return 0;
    }
    if (percentage > 1) {
      return 1;
    }
    return percentage;
  }

  @override
  ScoreMood getScoreMood({required double percentage}) {
    return percentage >= 0.6 ? ScoreMood.celebrating : ScoreMood.sad;
  }
}
