import 'package:flutter/material.dart';
import 'message_thread.dart';
import 'models/message.dart';

class Inbox extends StatelessWidget {
  final List<Message> conversations = [
    Message(sender: 'Kakak', content: 'SOS ALERT', timestamp: DateTime.now()),
    Message(sender: 'Abang', content: 'SOS ALERT', timestamp: DateTime.now()),
    Message(sender: 'Ibu', content: 'SOS ALERT', timestamp: DateTime.now()),
    Message(sender: 'Ayah', content: 'SOS ALERT', timestamp: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(child: Text(conversation.sender[0])),
            title: Text(conversation.sender),
            subtitle: Text(
              conversation.content,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: conversation.content == 'SOS ALERT' ? Colors.red : Colors.black,
              ),
            ),
            trailing: Text(
              '${conversation.timestamp.hour}:${conversation.timestamp.minute}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageThread(conversation.sender),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
