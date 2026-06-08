import 'chat_message.dart';

enum ChatStatus {
  idle,
  processing,
  error,
  success,
}

class ChatState {

  final List<ChatMessage> messages;
  final ChatStatus status;

  ChatState({
    required this.messages,
    required this.status,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }
}