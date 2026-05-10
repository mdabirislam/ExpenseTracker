import 'package:flutter/material.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';
import '../../../data/local/app_state.dart';

class DebtDetailScreen extends StatefulWidget {
  const DebtDetailScreen({super.key});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {

  String generateId() {
    return "${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}";
  }

  // ================= PAY DIALOG =================

  void showPayDialog(TransactionData debtTx) {

    final controller = TextEditingController(
      text: debtTx.amount.toStringAsFixed(2),
    );

    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocalState) {

            return AlertDialog(
              title: Text("Pay ${debtTx.source}"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Amount
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Date Picker
                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                          " ${selectedDate.hour}:${selectedDate.minute}",
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.calendar_today),

                        onPressed: () async {

                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );

                          if (date == null) return;

                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );

                          if (time == null) return;

                          setLocalState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    final pay =
                        double.tryParse(controller.text.trim()) ?? 0;

                    if (pay <= 0) return;

                    // ================= CREATE REPAY TRANSACTION =================

                    final repayType =
                        debtTx.type == TransactionType.creditBuy
                            ? TransactionType.creditPay
                            : TransactionType.debtRepay;

                    final repayTx = TransactionData(
                      id: generateId(),

                      type: repayType,

                      amount: pay,

                      category: debtTx.category,

                      source: debtTx.source,

                      note:
                          "Paid for: ${debtTx.id}",

                      date: selectedDate,
                    );

                    await AppState.addTransaction(repayTx);

                    if (!mounted) return;

                    Navigator.pop(context);

                    setState(() {});
                  },
                  child: const Text("Pay"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    final allTransactions = AppState.transactions;

    // 🔴 TO PAY
    final debtToPay = allTransactions.where((tx) {

      return tx.type == TransactionType.debtBorrow ||
          tx.type == TransactionType.creditBuy;

    }).toList();

    // 🟢 PAID
    final debtPaid = allTransactions.where((tx) {

      return tx.type == TransactionType.debtRepay ||
          tx.type == TransactionType.creditPay;

    }).toList();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Debt Details"),
        backgroundColor: Colors.red,
      ),

      body: ListView(
        children: [

          // ================= TO PAY =================

          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Debt To Pay",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          if (debtToPay.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("No debt found"),
            ),

          ...debtToPay.map((tx) {

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),

              child: ListTile(

                title: Text(tx.source),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "৳ ${tx.amount.toStringAsFixed(2)}",
                    ),

                    Text(
                      tx.type.label,
                      style: const TextStyle(fontSize: 12),
                    ),

                    if (tx.note != null &&
                        tx.note!.trim().isNotEmpty)
                      Text(
                        tx.note!,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),

                trailing: ElevatedButton(
                  onPressed: () => showPayDialog(tx),
                  child: const Text("Pay"),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // ================= PAID =================

          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Debt Paid",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          if (debtPaid.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("No payment history"),
            ),

          ...debtPaid.map((tx) {

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),

              child: ListTile(

                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),

                title: Text(tx.source),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "৳ ${tx.amount.toStringAsFixed(2)}",
                    ),

                    Text(
                      tx.type.label,
                      style: const TextStyle(fontSize: 12),
                    ),

                    if (tx.note != null &&
                        tx.note!.trim().isNotEmpty)
                      Text(
                        tx.note!,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}