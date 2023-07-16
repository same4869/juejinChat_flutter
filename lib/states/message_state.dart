import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:juejin_chat_demo/states/session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../injection.dart';
import '../models/message.dart';

part 'message_state.g.dart';

class MessageList extends StateNotifier<List<Message>> {
  MessageList() : super([]) {
    init();
  }

  Future<void> init() async {
    state = await db.messageDao.findAllMessages(); //获取所有历史消息
  }

  void addMessage(Message message) {
    state = [...state, message];
  }

  void upsertMessage(Message partialMessage) {
    final index =
        state.indexWhere((element) => element.id == partialMessage.id);

    var message = partialMessage;

    if (index >= 0) {
      final msg = state[index];
      message = partialMessage.copyWith(
          content: msg.content + partialMessage.content);
    }
    logger.d("message id ${message.toString()}");
    //update db
    db.messageDao.upsertMessage(message);

    if (index == -1) {
      state = [...state, partialMessage];
    } else {
      state = [...state]..[index] = message;
    }
  }
}

final messageProvider = StateNotifierProvider<MessageList, List<Message>>(
  (ref) => MessageList(),
);

@riverpod
List<Message> activeSessionMessages(ActiveSessionMessagesRef ref) {
  final active =
      ref.watch(sessionStateNotifierProvider).valueOrNull?.activeSession;
  final messages = ref.watch(messageProvider.select((value) =>
      value.where((element) => element.sessionId == active?.id).toList()));
  return messages;
}
