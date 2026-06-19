import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'package:intro_to_genui/config/agent/agent_config.dart';
import 'package:intro_to_genui/config/providers/memory_session_provider.dart';
import 'package:intro_to_genui/config/providers/score_payload_provider.dart';
import 'package:intro_to_genui/config/providers/score_provider.dart';
import 'package:intro_to_genui/ui/painters/orb_painter.dart';
import 'package:intro_to_genui/ui/painters/owl_painter.dart';
import 'package:intro_to_genui/ui/painters/retro_grid_painter.dart';
import 'package:intro_to_genui/ui/widgets/memory_session_display.dart';
import 'package:intro_to_genui/ui/widgets/message_bubble.dart';
import 'package:intro_to_genui/ui/widgets/score_display.dart';

class MemoryTrainerPage extends StatefulWidget {
  final MemorySessionProvider memorySessionProvider;
  final ScoreProvider scoreProvider;
  final ScorePayloadProvider scorePayloadProvider;

  const MemoryTrainerPage({
    super.key,
    required this.memorySessionProvider,
    required this.scoreProvider,
    required this.scorePayloadProvider,
  });

  @override
  State<MemoryTrainerPage> createState() => _MemoryTrainerPageState();
}

sealed class ConversationItem {}

class TextItem extends ConversationItem {
  final String text;
  final bool isUser;

  TextItem({required this.text, this.isUser = false});
}

class SurfaceItem extends ConversationItem {
  final String surfaceId;
  final int instanceVersion;

  SurfaceItem({required this.surfaceId, required this.instanceVersion});
}

class _MemoryTrainerPageState extends State<MemoryTrainerPage> {
  final List<ConversationItem> _items = [];
  int _nextSurfaceInstanceVersion = 0;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatSession _chatSession;
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final Catalog _catalog;

  @override
  void initState() {
    super.initState();

    final GenerativeModel model = FirebaseAI.vertexAI().generativeModel(
      model: memoryTrainerModelName,
    );
    _chatSession = model.startChat();

    _catalog = BasicCatalogItems.asCatalog().copyWith(
      newItems: [
        buildMemorySessionDisplay(
          memorySessionProvider: widget.memorySessionProvider,
        ),
        buildScoreDisplay(
          scoreProvider: widget.scoreProvider,
          scorePayloadProvider: widget.scorePayloadProvider,
        ),
      ],
    );

    _controller = SurfaceController(catalogs: [_catalog]);
    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    _conversation.events.listen((event) {
      setState(() {
        switch (event) {
          case ConversationSurfaceAdded added:
            _items.removeWhere(
              (item) =>
                  item is SurfaceItem && item.surfaceId == added.surfaceId,
            );
            _items.add(
              SurfaceItem(
                surfaceId: added.surfaceId,
                instanceVersion: ++_nextSurfaceInstanceVersion,
              ),
            );
            _scrollToBottom();
          case ConversationSurfaceRemoved removed:
            _items.removeWhere(
              (item) =>
                  item is SurfaceItem && item.surfaceId == removed.surfaceId,
            );
          case ConversationContentReceived content:
            _items.add(TextItem(text: content.text, isUser: false));
            _scrollToBottom();
          case ConversationError error:
            debugPrint('GenUI Error: ${error.error}');
          default:
        }
      });
    });

    final PromptBuilder promptBuilder = PromptBuilder.chat(
      catalog: _catalog,
      systemPromptFragments: [memoryTrainerSystemInstruction],
    );

    _conversation.sendRequest(
      ChatMessage.system(promptBuilder.systemPromptJoined()),
    );

    _items.add(TextItem(text: initialAgentGreeting));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addMessage() async {
    final String text = _textController.text;
    if (text.trim().isEmpty) {
      return;
    }

    _textController.clear();
    setState(() {
      _items.add(TextItem(text: text, isUser: true));
    });

    _scrollToBottom();
    await _conversation.sendRequest(ChatMessage.user(text));
  }

  Future<void> _sendAndReceive(ChatMessage msg) async {
    final StringBuffer buffer = StringBuffer();

    for (final part in msg.parts) {
      if (part.isUiInteractionPart) {
        buffer.write(part.asUiInteractionPart!.interaction);
      } else if (part is genui.TextPart) {
        buffer.write(part.text);
      }
    }

    if (buffer.isEmpty) {
      return;
    }

    final String text = buffer.toString();
    final GenerateContentResponse response = await _chatSession.sendMessage(
      Content.text(text),
    );

    if (response.text?.isNotEmpty ?? false) {
      _transport.addChunk(response.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(
              painter: const OwlPainter(scenario: OwlScenario.greeting),
            ),
          ),
        ),
        title: const Text('Entrenador de Memoria'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const RetroGridPainter(opacity: 0.08, gridSpacing: 28),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: const OrbPainter(animValue: 0.5)),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final item in _items)
                      switch (item) {
                        TextItem() => MessageBubble(
                          text: item.text,
                          isUser: item.isUser,
                        ),
                        SurfaceItem() => Surface(
                          key: ValueKey(
                            '${item.surfaceId}_${item.instanceVersion}',
                          ),
                          surfaceContext: _controller.contextFor(
                            item.surfaceId,
                          ),
                        ),
                      },
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ValueListenableBuilder<ConversationState>(
                    valueListenable: _conversation.state,
                    builder: (context, state, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onSubmitted: state.isWaiting
                                  ? null
                                  : (_) => _addMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Ejemplo: tema animales y 8 palabras',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: state.isWaiting ? null : _addMessage,
                            child: const Text('Enviar'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<ConversationState>(
            valueListenable: _conversation.state,
            builder: (context, state, child) {
              if (state.isWaiting) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
