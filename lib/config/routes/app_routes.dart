import 'package:flutter/material.dart';
import 'package:intro_to_genui/config/providers/memory_session_provider.dart';
import 'package:intro_to_genui/config/providers/score_payload_provider.dart';
import 'package:intro_to_genui/config/providers/score_provider.dart';
import 'package:intro_to_genui/ui/pages/memory_trainer_page.dart';

class AppRoutes {
  static const String home = '/';

  static Route<dynamic> onGenerateRoute({
    required RouteSettings settings,
    required MemorySessionProvider memorySessionProvider,
    required ScoreProvider scoreProvider,
    required ScorePayloadProvider scorePayloadProvider,
  }) {
    switch (settings.name) {
      case home:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MemoryTrainerPage(
            memorySessionProvider: memorySessionProvider,
            scoreProvider: scoreProvider,
            scorePayloadProvider: scorePayloadProvider,
          ),
        );
    }
  }
}
