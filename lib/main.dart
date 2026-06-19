import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intro_to_genui/config/agent/agent_config.dart';
import 'package:intro_to_genui/config/providers/memory_session_provider.dart';
import 'package:intro_to_genui/config/providers/score_payload_provider.dart';
import 'package:intro_to_genui/config/providers/score_provider.dart';
import 'package:intro_to_genui/config/routes/app_routes.dart';
import 'package:intro_to_genui/config/theme/app_theme.dart';
import 'package:intro_to_genui/config/firebase/firebase_options.dart';
import 'package:intro_to_genui/infrastructure/driven_adapters/memory_session/memory_session_defaults_adapter.dart';
import 'package:intro_to_genui/infrastructure/driven_adapters/score/score_payload_adapter.dart';
import 'package:intro_to_genui/infrastructure/driven_adapters/score/score_rules_adapter.dart';

const String systemInstruction = memoryTrainerSystemInstruction;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final MemorySessionProvider memorySessionProvider = MemorySessionProvider(
    gateway: MemorySessionDefaultsAdapter(),
  );
  final ScoreProvider scoreProvider = ScoreProvider(
    gateway: ScoreRulesAdapter(),
  );
  final ScorePayloadProvider scorePayloadProvider = ScorePayloadProvider(
    gateway: ScorePayloadAdapter(),
  );

  runApp(
    MyApp(
      memorySessionProvider: memorySessionProvider,
      scoreProvider: scoreProvider,
      scorePayloadProvider: scorePayloadProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final MemorySessionProvider memorySessionProvider;
  final ScoreProvider scoreProvider;
  final ScorePayloadProvider scorePayloadProvider;

  const MyApp({
    super.key,
    required this.memorySessionProvider,
    required this.scoreProvider,
    required this.scorePayloadProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entrenador de Memoria',
      theme: AppTheme.themeData,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings: settings,
        memorySessionProvider: memorySessionProvider,
        scoreProvider: scoreProvider,
        scorePayloadProvider: scorePayloadProvider,
      ),
    );
  }
}
