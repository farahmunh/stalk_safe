import 'package:flutter/material.dart';
import 'message_thread.dart';
import 'models/message.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          'Inbox',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF7DAF52), // Green color for AppBar background
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(child: Text(conversation.sender[0])),
            title: Text(
              conversation.sender,
              style: GoogleFonts.inter(),
            ),
            subtitle: Text(
              conversation.content,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: conversation.content == 'SOS ALERT'
                    ? Colors.red
                    : Colors.black,
              ),
            ),
            trailing: Text(
              '${conversation.timestamp.hour}:${conversation.timestamp.minute}',
              style: GoogleFonts.inter(),
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
