import 'package:intro_to_genui/domain/models/memory_session/gateway/memory_session_gateway.dart';

class MemorySessionDefaultsAdapter implements MemorySessionGateway {
  @override
  int getMemorySessionDurationSeconds({
    required int wordCount,
    int? requestedDurationSeconds,
  }) {
    if (wordCount > 0) {
      // UX rule: 6 seconds per word (10 words = 60s).
      return wordCount * 6;
    }

    if (requestedDurationSeconds != null && requestedDurationSeconds > 0) {
      return requestedDurationSeconds;
    }

    return 30;
  }

  @override
  bool getHideWordsOnTimeout({bool? requestedValue}) {
    // Security rule: always hide words when memorization time ends.
    return true;
  }
}
