import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:juejin_chat_demo/markdown/latex.dart';
import 'package:juejin_chat_demo/models/message.dart';
import 'package:juejin_chat_demo/states/session_state.dart';
import 'package:juejin_chat_demo/widgets/typing_cursor.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../markdown/code_wrapper.dart';
import '../states/chat_ui_state.dart';
import '../states/message_state.dart';
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
          ),
          IconButton(
              onPressed: () {
                GoRouter.of(context).push('/settings');
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Container(
        color: const Color(0xFFF1F1F1),
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
    final uiState = ref.watch(chatUiProvider);
    ref.listen(activeSessionMessagesProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 50), () {
        listController.jumpTo(listController.position.maxScrollExtent);
      });
    });
    return ListView.separated(
        controller: listController,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return msg.isUser
              ? SentMessageItem(
                  message: msg,
                  backgroundColor: const Color(0xFF8FE869),
                )
              : ReceivedMessageItem(
                  message: msg,
                  typing:
                      index == messages.length - 1 && uiState.requestLoading,
                );
        },
        separatorBuilder: ((context, index) => const Divider(
              height: 16,
              color: Colors.transparent,
            )),
        itemCount: messages.length);
  }
}

class ReceivedMessageItem extends StatelessWidget {
  final Message message;
  final Color backgroundColor;
  final double radius;
  final bool typing;

  const ReceivedMessageItem({
    super.key,
    required this.message,
    this.backgroundColor = Colors.white,
    this.radius = 8,
    this.typing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 230, 230, 230),
          child: Container(
            color: Colors.transparent,
            child: Image.asset('assets/images/chatgpt.png'),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        CustomPaint(
          painter: Triangle(backgroundColor),
        ),
        Flexible(
            child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.only(right: 48),
          child: MessageContentWidget(
            message: message,
            typing: typing,
          ),
        )),
      ],
    );
  }
}

class SentMessageItem extends StatelessWidget {
  final Message message;
  final Color backgroundColor;
  final double radius;

  const SentMessageItem({
    super.key,
    required this.message,
    this.backgroundColor = Colors.white,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
            child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.only(left: 48),
          child: MessageContentWidget(message: message),
        )),
        CustomPaint(
          painter: Triangle(backgroundColor),
        ),
        const SizedBox(
          width: 8,
        ),
        const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class MessageContentWidget extends StatelessWidget {
  final bool typing;

  const MessageContentWidget({
    super.key,
    required this.message,
    this.typing = false,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    codeWrapper(child, text) => CodeWrapperWidget(child: child, text: text);
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...MarkdownGenerator(
            config: MarkdownConfig().copy(configs: [
              const PreConfig().copy(wrapper: codeWrapper),
            ]),
            generators: [
              latexGenerator,
            ],
            inlineSyntaxes: [
              LatexSyntax(),
            ],
          ).buildWidgets(message.content),
          if (typing) const TypingCursor(),
        ],
      ),
    );
  }
}

class Triangle extends CustomPainter {
  final Color bgColor;

  Triangle(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
