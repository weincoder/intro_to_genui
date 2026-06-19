import 'package:flutter/foundation.dart';
import 'package:intro_to_genui/domain/models/score/gateway/score_gateway.dart';
import 'package:intro_to_genui/domain/usecase/score_mood_usecase.dart';
import 'package:intro_to_genui/domain/usecase/score_percentage_usecase.dart';

class ScoreProvider extends ChangeNotifier {
  final ScoreGateway gateway;
  final ScorePercentageUseCase percentageUseCase;
  final ScoreMoodUseCase moodUseCase;

  ScoreProvider({required this.gateway})
    : percentageUseCase = ScorePercentageUseCase(gateway: gateway),
      moodUseCase = ScoreMoodUseCase(gateway: gateway);

  double resolveScorePercentage({
    required double totalScore,
    required double maxScore,
  }) {
    return percentageUseCase.execute(
      totalScore: totalScore,
      maxScore: maxScore,
    );
  }

  ScoreMood resolveScoreMood({required double percentage}) {
    return moodUseCase.execute(percentage: percentage);
  }
}
