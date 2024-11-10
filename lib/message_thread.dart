import 'package:flutter/material.dart';
import 'models/message.dart';

class MessageThread extends StatefulWidget {
  final String sender;

  MessageThread(this.sender);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final List<Message> messages = [
    Message(
      sender: 'You', 
      content: 'SOS ALERT', 
      timestamp: DateTime.now(),
    ),
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        messages.add(
          Message(
            sender: 'You', 
            content: text, 
            timestamp: DateTime.now(),
          ),
        );
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.sender}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - index - 1];
                final isMine = message.sender == 'You';
                return ListTile(
                  title: Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: isMine ? Colors.green[100] : Colors.grey[200],
                      child: Text(
                        message.content,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: message.content == 'SOS ALERT' ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      '${message.timestamp.hour}:${message.timestamp.minute}',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

