import 'package:flutter/foundation.dart';
import 'package:intro_to_genui/domain/models/memory_session/gateway/memory_session_gateway.dart';
import 'package:intro_to_genui/domain/usecase/memory_session_duration_usecase.dart';
import 'package:intro_to_genui/domain/usecase/memory_session_visibility_usecase.dart';

class MemorySessionProvider extends ChangeNotifier {
  final MemorySessionGateway gateway;
  final MemorySessionDurationUseCase durationUseCase;
  final MemorySessionVisibilityUseCase visibilityUseCase;

  MemorySessionProvider({required this.gateway})
    : durationUseCase = MemorySessionDurationUseCase(gateway: gateway),
      visibilityUseCase = MemorySessionVisibilityUseCase(gateway: gateway);

  int resolveDurationSeconds({
    required int wordCount,
    int? requestedDurationSeconds,
  }) {
    return durationUseCase.execute(
      wordCount: wordCount,
      requestedDurationSeconds: requestedDurationSeconds,
    );
  }

  bool resolveHideWordsOnTimeout({bool? requestedValue}) {
    return visibilityUseCase.execute(requestedValue: requestedValue);
  }
}
