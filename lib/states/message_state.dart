import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../injection.dart';
import '../models/message.dart';

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
