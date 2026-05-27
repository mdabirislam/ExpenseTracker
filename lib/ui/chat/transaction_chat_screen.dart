import 'package:flutter/material.dart';
import '../../services/chat_parser/transaction_chat_service.dart';
import '../../services/chat_parser/chat_response_generator.dart';
import '../../services/chat_parser/parser_result.dart';
class TransactionChatScreen extends StatefulWidget {
  const TransactionChatScreen({super.key});

  @override
  State<TransactionChatScreen> createState() =>
      _TransactionChatScreenState();
}

class _TransactionChatScreenState extends State<TransactionChatScreen> {

  final TextEditingController controller = TextEditingController();
  String response = "";

ParserResult? parserResult;

void send() {

  final result =
      TransactionChatService.process(
    controller.text,
  );

  final output =
      ChatResponseGenerator.generate(
    result,
  );

  setState(() {

    response = output;

    parserResult = result;
  });
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Chat")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

Expanded(
  child: SingleChildScrollView(

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(response),

        const SizedBox(height: 20),

        if (parserResult != null)

          ...parserResult!.transactions.map(

            (tx) => Card(

              margin: const EdgeInsets.only(
                bottom: 12,
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Source: ${tx.source}",
                    ),

                    Text(
                      "Amount: ${tx.amount}",
                    ),

                    Text(
                      "Category: ${tx.category}",
                    ),

                    Text(
                      "Type: ${tx.type.name}",
                    ),
                    if (tx.unknownType != null)

  Padding(

    padding:
        const EdgeInsets.only(
      top: 4,
    ),

    child: Text(

      'Unknown Type: ${tx.unknownType}',

      style: const TextStyle(
        color: Colors.orange,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

                    Text(
                      "Date: ${tx.date}",
                    ),

                    if (tx.note != null)

                      Text(
                        "Note: ${tx.note}",
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  ),
),

            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter transaction message...",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: send,
              child: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}