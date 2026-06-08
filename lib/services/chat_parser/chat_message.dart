enum MessageType {
  user,
  system,
  error,
  preview,
  success,
}

class ChatMessage {

  final String text;
  final MessageType type;

  ChatMessage({
    required this.text,
    required this.type,
  });
}