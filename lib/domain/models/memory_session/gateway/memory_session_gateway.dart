abstract class MemorySessionGateway {
  int getMemorySessionDurationSeconds({
    required int wordCount,
    int? requestedDurationSeconds,
  });

  bool getHideWordsOnTimeout({bool? requestedValue});
}
