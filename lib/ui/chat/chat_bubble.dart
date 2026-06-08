import 'package:flutter/material.dart';

import '../../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {

  final ChatMessageModel message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {

    Color color;

    switch (message.type) {

      case ChatMessageType.user:
        color = Colors.blue;
        break;

      case ChatMessageType.error:
        color = Colors.red;
        break;

      case ChatMessageType.preview:
        color = Colors.green;
        break;

      default:
        color = Colors.grey;
    }

    return Align(

      alignment:
          message.type ==
                  ChatMessageType.user
              ? Alignment.centerRight
              : Alignment.centerLeft,

      child: Container(

        margin:
            const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 12,
        ),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          color: color.withOpacity(0.15),

          borderRadius:
              BorderRadius.circular(16),
        ),

        child: Text(message.message),
      ),
    );
  }
}