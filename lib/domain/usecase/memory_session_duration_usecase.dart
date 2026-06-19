import 'package:intro_to_genui/domain/models/memory_session/gateway/memory_session_gateway.dart';

class MemorySessionDurationUseCase {
  final MemorySessionGateway gateway;

  MemorySessionDurationUseCase({required this.gateway});

  int execute({required int wordCount, int? requestedDurationSeconds}) {
    return gateway.getMemorySessionDurationSeconds(
      wordCount: wordCount,
      requestedDurationSeconds: requestedDurationSeconds,
    );
  }
}
