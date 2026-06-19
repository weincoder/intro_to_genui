import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:intro_to_genui/config/providers/memory_session_provider.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final memorySessionDisplaySchema = S.object(
  properties: {
    'component': S.string(enumValues: ['MemorySessionDisplay']),
    'title': S.string(description: 'Titulo del bloque de memorizacion.'),
    'topic': S.string(description: 'Tema elegido por el usuario.'),
    'words': S.list(
      description: 'Lista de palabras que se deben memorizar.',
      items: S.string(),
    ),
    'durationSeconds': S.integer(
      description: 'Duracion total del temporizador en segundos.',
    ),
    'hideWordsOnTimeout': S.boolean(
      description: 'Indica si se deben ocultar las palabras al finalizar.',
    ),
    'timeoutAction': A2uiSchemas.action(
      description: 'Accion que se dispara cuando el temporizador termina.',
    ),
  },
  required: [
    'title',
    'topic',
    'words',
    'durationSeconds',
    'hideWordsOnTimeout',
  ],
);

class _TimeoutActionData {
  final String actionName;
  final JsonMap actionContext;

  const _TimeoutActionData({
    required this.actionName,
    required this.actionContext,
  });

  static const _TimeoutActionData empty = _TimeoutActionData(
    actionName: '',
    actionContext: <String, Object?>{},
  );

  factory _TimeoutActionData.fromJson(JsonMap? json) {
    if (json == null) {
      return _TimeoutActionData.empty;
    }

    final Object? eventRaw = json['event'];
    if (eventRaw is! JsonMap) {
      return _TimeoutActionData.empty;
    }

    final Object? actionNameRaw = eventRaw['name'];
    final Object? actionContextRaw = eventRaw['context'];

    return _TimeoutActionData(
      actionName: actionNameRaw is String ? actionNameRaw : '',
      actionContext: actionContextRaw is JsonMap
          ? actionContextRaw
          : <String, Object?>{},
    );
  }
}

class _MemorySessionData {
  final String title;
  final String topic;
  final List<String> words;
  final int durationSeconds;
  final bool hideWordsOnTimeout;
  final _TimeoutActionData timeoutAction;

  const _MemorySessionData({
    required this.title,
    required this.topic,
    required this.words,
    required this.durationSeconds,
    required this.hideWordsOnTimeout,
    required this.timeoutAction,
  });

  factory _MemorySessionData.fromJson({
    required Map<String, Object?> json,
    required MemorySessionProvider memorySessionProvider,
  }) {
    try {
      final Object? wordsRaw = json['words'];
      final List<String> words = wordsRaw is List<Object?>
          ? wordsRaw.whereType<String>().toList()
          : <String>[];

      final Object? durationRaw = json['durationSeconds'];
      final int? requestedDurationSeconds = durationRaw is int
          ? durationRaw
          : durationRaw is num
          ? durationRaw.toInt()
          : null;

      return _MemorySessionData(
        title: (json['title'] as String?) ?? 'Sesion de memoria',
        topic: (json['topic'] as String?) ?? 'General',
        words: words,
        durationSeconds: memorySessionProvider.resolveDurationSeconds(
          wordCount: words.length,
          requestedDurationSeconds: requestedDurationSeconds,
        ),
        hideWordsOnTimeout: memorySessionProvider.resolveHideWordsOnTimeout(
          requestedValue: json['hideWordsOnTimeout'] as bool?,
        ),
        timeoutAction: _TimeoutActionData.fromJson(
          json['timeoutAction'] as JsonMap?,
        ),
      );
    } catch (e) {
      throw Exception('JSON invalido para _MemorySessionData: $e');
    }
  }
}

class _MemorySessionDisplay extends StatefulWidget {
  final _MemorySessionData data;
  final Future<void> Function(_TimeoutActionData) onTimeout;

  const _MemorySessionDisplay({required this.data, required this.onTimeout});

  @override
  State<_MemorySessionDisplay> createState() => _MemorySessionDisplayState();
}

class _MemorySessionDisplayState extends State<_MemorySessionDisplay> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _hasTriggeredTimeout = false;
  bool _isMemorizationFinished = false;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant _MemorySessionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool isDifferentSession =
        oldWidget.data.title != widget.data.title ||
        oldWidget.data.topic != widget.data.topic ||
        !listEquals(oldWidget.data.words, widget.data.words);

    final bool durationChanged =
        oldWidget.data.durationSeconds != widget.data.durationSeconds;

    if (isDifferentSession || (durationChanged && !_isMemorizationFinished)) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _remainingSeconds = widget.data.durationSeconds;
    _hasTriggeredTimeout = false;
    _isMemorizationFinished = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        setState(() {
          _remainingSeconds = 0;
          _isMemorizationFinished = true;
        });
        timer.cancel();
        _triggerTimeoutIfNeeded();
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  Future<void> _triggerTimeoutIfNeeded() async {
    if (_hasTriggeredTimeout) {
      return;
    }
    _hasTriggeredTimeout = true;
    await widget.onTimeout(widget.data.timeoutAction);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldHideWords =
        _isMemorizationFinished || _remainingSeconds == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.data.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tema: ${widget.data.topic}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 8),
                Text(
                  'Tiempo restante: ${_formatSeconds(_remainingSeconds)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (shouldHideWords)
              Text(
                'Tiempo terminado. Las palabras se han ocultado.',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.data.words
                    .map((word) => Chip(label: Text(word)))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String minutesText = minutes.toString().padLeft(2, '0');
    final String secondsText = seconds.toString().padLeft(2, '0');
    return '$minutesText:$secondsText';
  }
}

CatalogItem buildMemorySessionDisplay({
  required MemorySessionProvider memorySessionProvider,
}) {
  return CatalogItem(
    name: 'MemorySessionDisplay',
    dataSchema: memorySessionDisplaySchema,
    widgetBuilder: (itemContext) {
      final Map<String, Object?> json =
          itemContext.data as Map<String, Object?>;
      final _MemorySessionData data = _MemorySessionData.fromJson(
        json: json,
        memorySessionProvider: memorySessionProvider,
      );

      return _MemorySessionDisplay(
        data: data,
        onTimeout: (timeoutAction) async {
          if (timeoutAction.actionName.isEmpty) {
            return;
          }

          final JsonMap resolvedContext = await resolveContext(
            itemContext.dataContext,
            timeoutAction.actionContext,
          );

          itemContext.dispatchEvent(
            UserActionEvent(
              name: timeoutAction.actionName,
              sourceComponentId: itemContext.id,
              context: resolvedContext,
            ),
          );
        },
      );
    },
  );
}
