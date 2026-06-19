enum ScoreMood { celebrating, sad }

abstract class ScoreGateway {
  double getScorePercentage({
    required double totalScore,
    required double maxScore,
  });

  ScoreMood getScoreMood({required double percentage});
}
