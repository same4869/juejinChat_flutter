import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:juejin_chat_demo/models/message.dart';
import 'package:juejin_chat_demo/states/chat_ui_state.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import '../states/message_state.dart';
import '../injection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: const [
            Expanded(child: ChatMessageList()),
            UserInputWidget()
          ],
        ),
      ),
    );
  }
}

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

  _requestChatGPT(WidgetRef ref, String content) async {
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        content,
        (text) {
          final message = Message(
              id: id, content: text, isUser: false, timestamp: DateTime.now());
          ref.read(messageProvider.notifier).upsertMessage(message);
        },
      );
    } catch (err) {
      logger.e("requestChatGPT error: $err", err);
    } finally {
      ref.read(chatUiProvider.notifier).setRequestLoading(false);
    }
  }

  _sendMessage(WidgetRef ref, TextEditingController controller) {
    final content = controller.text;
    final message = Message(
        id: uuid.v4(),
        content: content,
        isUser: true,
        timestamp: DateTime.now());
    ref.read(messageProvider.notifier).addMessage(message);
    controller.clear();
    _requestChatGPT(ref, content);
  }
}

class ChatMessageList extends HookConsumerWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageProvider);
    final listController = useScrollController();
    ref.listen(messageProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 50), () {
        listController.jumpTo(listController.position.maxScrollExtent);
      });
    });
    return ListView.separated(
        controller: listController,
        itemBuilder: (context, index) {
          return MessageItem(message: messages[index]);
        },
        separatorBuilder: ((context, index) => const Divider(
              height: 16,
            )),
        itemCount: messages.length);
  }
}

class MessageItem extends StatelessWidget {
  final Message message;

  const MessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          foregroundColor: Colors.white,
          backgroundColor: message.isUser ? Colors.blue : Colors.grey,
          child: Text(
            message.isUser ? 'A' : 'GPT',
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
            child: Container(
          margin: const EdgeInsets.only(right: 48),
          child: MessageContentWidget(message: message),
        )),
      ],
    );
  }
}

class MessageContentWidget extends StatelessWidget {
  const MessageContentWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: MarkdownGenerator().buildWidgets(message.content),
    );
  }
}
