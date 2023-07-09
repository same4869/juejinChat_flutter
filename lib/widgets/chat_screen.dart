import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
                      return Row(
                        children: [
                          const CircleAvatar(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            child: Text('A'),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text("Message $index"),
                        ],
                      );
                    },
                    separatorBuilder: ((context, index) => const Divider(
                          height: 16,
                        )),
                    itemCount: 10)),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Type a messgae',
                  suffixIcon: IconButton(
                    onPressed: () {},
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
}
