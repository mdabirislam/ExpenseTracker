// import 'chat_state.dart';
// import 'chat_message.dart';
// import 'transaction_chat_service.dart';

// class ChatController {

//   ChatState state = ChatState(
//     messages: [],
//     status: ChatStatus.idle,
//   );

//   void sendMessage(String input) {

//     // 1. Add user message
//     state.messages.add(
//       ChatMessage(
//         text: input,
//         type: MessageType.user,
//       ),
//     );

//     // 2. Process
//     final result =
//         TransactionChatService.process(input);

//     // 3. Handle result
//     if (result.hasErrors) {

//       state.messages.add(
//         ChatMessage(
//           text: _formatErrors(result.errors),
//           type: MessageType.error,
//         ),
//       );

//       state = state.copyWith(
//         status: ChatStatus.error,
//       );

//     } else {

//       state.messages.add(
//         ChatMessage(
//           text:
//               "Parsed ${result.drafts.length} transactions successfully",
//           type: MessageType.success,
//         ),
//       );

//       state = state.copyWith(
//         status: ChatStatus.success,
//       );
//     }
//   }

//   String _formatErrors(List errors) {
//     return errors.map((e) => e.message).join("\n");
//   }
// }