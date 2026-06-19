import 'package:flutter_test/flutter_test.dart';
import 'package:intro_to_genui/config/agent/agent_config.dart';
import 'package:intro_to_genui/main.dart';

void main() {
  group('Configuracion de agente', () {
    test('expone ids y modelo requeridos', () {
      expect(memorySessionSurfaceId, isNotEmpty);
      expect(scoreDisplaySurfaceId, isNotEmpty);
      expect(memoryTrainerModelName, isNotEmpty);
    });

    test('mantiene compatibilidad de systemInstruction en main', () {
      expect(systemInstruction, equals(memoryTrainerSystemInstruction));
      expect(systemInstruction, contains('ScoreDisplay'));
    });
  });
}
