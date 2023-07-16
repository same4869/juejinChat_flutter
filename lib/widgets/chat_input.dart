import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
import '../states/session_state.dart';

class UserInputWidget extends HookConsumerWidget {
  const UserInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUIState = ref.watch(chatUiProvider);
    final controller = useTextEditingController();
    return TextField(
      controller: controller,
      enabled: !chatUIState.requestLoading,
      decoration: InputDecoration(
          hintText: 'Type a messgae',
          suffixIcon: IconButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _sendMessage(ref, controller);
              }
            },
            icon: const Icon(
              Icons.send,
            ),
          )),
    );
  }

  _requestChatGPT(WidgetRef ref, String content, {int? sessionId}) async {
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        content,
        (text) {
          final message =
              _createMessage(text, id: id, isUser: false, sessionId: sessionId);
          ref.read(messageProvider.notifier).upsertMessage(message);
          logger.d("message -> $message");
        },
      );
    } catch (err) {
      logger.e("requestChatGPT error: $err", err);
    } finally {
      ref.read(chatUiProvider.notifier).setRequestLoading(false);
    }
  }

  _sendMessage(WidgetRef ref, TextEditingController controller) async {
    final content = controller.text;
    Message message = _createMessage(content);
    var active = ref.watch(activeSessionProvider);
    var sessionId = active?.id ?? 0;
    if (sessionId <= 0) {
      active = Session(title: content);
      active = await ref
          .read(sessionStateNotifierProvider.notifier)
          .upsertSession(active);
      sessionId = active.id!;
      ref
          .read(sessionStateNotifierProvider.notifier)
          .setActiveSession(active.copyWith(id: sessionId));
    }

    ref
        .read(messageProvider.notifier)
        .upsertMessage(message.copyWith(sessionId: sessionId));
    controller.clear();
    _requestChatGPT(ref, content, sessionId: sessionId);
  }
}

Message _createMessage(
  String content, {
  String? id,
  bool isUser = true,
  int? sessionId,
}) {
  final message = Message(
    id: id ?? uuid.v4(),
    content: content,
    isUser: isUser,
    timestamp: DateTime.now(),
    sessionId: sessionId ?? 0,
  );
  return message;
}
