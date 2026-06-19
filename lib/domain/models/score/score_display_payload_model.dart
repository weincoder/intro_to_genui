class ScoreDisplayEntryModel {
  final String expectedWord;
  final String userAnswer;
  final double score;
  final String feedback;

  const ScoreDisplayEntryModel({
    required this.expectedWord,
    required this.userAnswer,
    required this.score,
    required this.feedback,
  });
}

class ScoreDisplayPayloadModel {
  final String title;
  final double totalScore;
  final double maxScore;
  final List<ScoreDisplayEntryModel> entries;

  const ScoreDisplayPayloadModel({
    required this.title,
    required this.totalScore,
    required this.maxScore,
    required this.entries,
  });
}
