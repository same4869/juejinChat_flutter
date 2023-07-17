import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:juejin_chat_demo/markdown/latex.dart';
import 'package:juejin_chat_demo/models/message.dart';
import 'package:juejin_chat_demo/states/chat_ui_state.dart';
import 'package:juejin_chat_demo/states/session_state.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/session.dart';
import '../states/message_state.dart';
import '../injection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'chat_input.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
              onPressed: () {
                GoRouter.of(context).push('/history');
              },
              icon: const Icon(Icons.history)),
          IconButton(
            onPressed: () {
              ref
                  .read(sessionStateNotifierProvider.notifier)
                  .setActiveSession(null);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: const [
            Expanded(child: ChatMessageList()),
            ChatInputWidget()
          ],
        ),
      ),
    );
  }
}

class ChatMessageList extends HookConsumerWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(activeSessionMessagesProvider);
    final listController = useScrollController();
    ref.listen(activeSessionMessagesProvider, (previous, next) {
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
      children: MarkdownGenerator(
        generators: [
          latexGenerator,
        ],
        inlineSyntaxes: [
          LatexSyntax(),
        ],
      ).buildWidgets(message.content),
    );
  }
}
