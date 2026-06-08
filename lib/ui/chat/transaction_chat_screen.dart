import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../services/chat_parser/transaction_chat_service.dart';
import '../../services/chat_parser/chat_response_generator.dart';

import '../../models/parsed_transaction.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';

import '../../data/local/app_state.dart';
import '../../utils/helpers.dart';

class TransactionChatScreen extends StatefulWidget {
  const TransactionChatScreen({super.key});

  @override
  State<TransactionChatScreen> createState() =>
      _TransactionChatScreenState();
}

class _TransactionChatScreenState extends State<TransactionChatScreen> {

  final TextEditingController controller = TextEditingController();

  String response = "";

  List<ParsedTransaction> transactions = [];

  bool isSaving = false;
  bool isSaved = false;

  // ================= SEND =================
  void send() {

    final result =
        TransactionChatService.process(controller.text);

    final output =
        ChatResponseGenerator.generate(result);

    setState(() {

      response = output;

      transactions = result.transactions;

      isSaved = false;
    });
  }

  // ================= UPDATE TYPE =================
  void updateType(int index, TransactionType type) {
    setState(() {
      transactions[index] =
          transactions[index].copyWith(type: type);
    });
  }

  // ================= SAVE ALL =================
  Future<void> saveAll() async {

    if (transactions.isEmpty || isSaving) return;

    setState(() {
      isSaving = true;
    });

    final valid = transactions.where((tx) =>
        tx.source.trim().isNotEmpty &&
        tx.amount > 0
    ).toList();

    for (final tx in valid) {

      await AppState.addTransaction(
        TransactionData(
          id: const Uuid().v4(),
          type: tx.type,
          amount: tx.amount,
          source: tx.source,
          note: tx.note,
          category: tx.category,
          date: tx.date,
          monthKey: generateMonthKey(tx.date),
        ),
      );
    }

    setState(() {

      isSaving = false;

      isSaved = true;

      transactions.clear();

      controller.clear();

      response = "";
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Chat"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= OUTPUT =================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(response),

                    const SizedBox(height: 16),

                    ...transactions.asMap().entries.map((entry) {

                      final index = entry.key;
                      final tx = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text("Source: ${tx.source}"),
                              Text("Amount: ${tx.amount}"),
                              Text("Category: ${tx.category}"),
                              Text("Type: ${tx.type.name}"),
                              Text("Date: ${tx.date}"),

                              // ================= UNKNOWN TYPE =================
                              if (tx.unknownType != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: const [
                                          Icon(Icons.warning,
                                              color: Colors.orange,
                                              size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            "Unknown Type Detected",
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        "User input: ${tx.unknownType}",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Wrap(
                                        spacing: 8,
                                        children: [

                                          ActionChip(
                                            label: const Text("Expense"),
                                            onPressed: () =>
                                                updateType(index, TransactionType.expense),
                                          ),

                                          ActionChip(
                                            label: const Text("Income"),
                                            onPressed: () =>
                                                updateType(index, TransactionType.income),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // ================= PREVIEW BUTTON =================
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  child: const Text("Preview"),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Preview"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Text("Source: ${tx.source}"),
                                            Text("Amount: ${tx.amount}"),
                                            Text("Category: ${tx.category}"),
                                            Text("Type: ${tx.type.name}"),
                                            Text("Date: ${tx.date}"),

                                            if (tx.note != null)
                                              Text("Note: ${tx.note}"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Close"),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ================= INPUT =================
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter transaction message...",
              ),
            ),

            const SizedBox(height: 10),

            // ================= BUTTONS =================
            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: send,
                    child: const Text("Send"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveAll,
                    child: Text(
                      isSaving
                          ? "Saving..."
                          : isSaved
                              ? "Saved"
                              : "Save All",
                    ),
                  ),
                ),
              ],
            ),

            if (isSaved)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "✔ All transactions saved",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}