import 'package:flutter/material.dart';
import 'package:juejin_chat_demo/models/message.dart';

class ChatScreen extends StatelessWidget {
  final List<Message> messages = [
    Message(content: "hello", isUser: true, timestamp: DateTime.now()),
    Message(content: "How are you?", isUser: false, timestamp: DateTime.now()),
    Message(
        content: "Fine, Thank you, and you?",
        isUser: true,
        timestamp: DateTime.now()),
    Message(
        content: "I am fine too, thank you",
        isUser: false,
        timestamp: DateTime.now()),
  ];

  final _textController = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return MessageItem(message: messages[index]);
                    },
                    separatorBuilder: ((context, index) => const Divider(
                          height: 16,
                        )),
                    itemCount: messages.length)),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  hintText: 'Type a messgae',
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        _sendMessage(_textController.text);
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  _sendMessage(String content) {
    final message =
        Message(content: content, isUser: true, timestamp: DateTime.now());
    messages.add(message);
    _textController.clear();
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
        Text(message.content),
      ],
    );
  }
}
