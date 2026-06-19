import 'package:intro_to_genui/domain/models/memory_session/gateway/memory_session_gateway.dart';

class MemorySessionVisibilityUseCase {
  final MemorySessionGateway gateway;

  MemorySessionVisibilityUseCase({required this.gateway});

  bool execute({bool? requestedValue}) {
    return gateway.getHideWordsOnTimeout(requestedValue: requestedValue);
  }
}
