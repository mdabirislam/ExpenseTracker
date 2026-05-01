import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/debt_data_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';
import '../../../data/local/app_state.dart';

class DebtDetailScreen extends StatefulWidget {
  const DebtDetailScreen({super.key});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {

  late Box<DebtData> debtBox;

  @override
  void initState() {
    super.initState();
    debtBox = Hive.box<DebtData>('debts');
  }

  String generateId() {
    return "${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}";
  }

  List<DebtData> get debts => debtBox.values.toList();

  // ================= PAY DIALOG =================
  void showPayDialog(DebtData debt) {
    final controller = TextEditingController(
      text: debt.remaining.toStringAsFixed(2),
    );

    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text("Pay ${debt.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} "
                          "${selectedDate.hour}:${selectedDate.minute}",
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
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
                      )
                    ],
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () async {
                    final pay = double.tryParse(controller.text) ?? 0;
                    Navigator.pop(context);

                    if (pay <= 0) return;

                    await handlePayment(debt, pay, selectedDate);
                  },
                  child: const Text("OK"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ================= PAYMENT LOGIC =================
  Future<void> handlePayment(
    DebtData debt,
    double pay,
    DateTime date,
  ) async {

    final remaining = debt.remaining;

    // 🔥 ADD EXPENSE
    await AppState.addTransaction(TransactionData(
      id: generateId(),
      type: TransactionType.expense,
      amount: pay,
      category: "Debt Paid",
      source: debt.name,
      note: "Debt payment",
      date: date,
    ));

    // ================= LESS =================
    if (pay < remaining) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Partial Payment"),
          content: Text("Remaining: ${remaining - pay}\nKeep or Forgive?"),
          actions: [

            // KEEP
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                debt.totalPaid += pay;
                await debt.save();

                setState(() {});
              },
              child: const Text("Keep"),
            ),

            // FORGIVE
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                debt.totalPaid = debt.totalDebt;
                debt.note = (debt.note ?? "") +
                    "\nForgiven ${remaining - pay}";

                await debt.save();

                setState(() {});
              },
              child: const Text("Forgive"),
            ),
          ],
        ),
      );
      return;
    }

    // ================= FULL / EXTRA =================
    else {
      debt.totalPaid = debt.totalDebt;

      if (pay > remaining) {
        final extra = pay - remaining;
        debt.note = (debt.note ?? "") +
            "\nExtra Paid: $extra";
      }

      await debt.save();
    }

    setState(() {});
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {

    final unpaid = debts.where((d) => !d.isPaid).toList();
    final paid = debts.where((d) => d.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Debt Details"),
        backgroundColor: Colors.red,
      ),

      body: ListView(
        children: [

          // 🔴 UNPAID
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Unpaid / Remaining",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          ...unpaid.map((d) => ListTile(
                title: Text(d.name),
                subtitle: Text("Remaining: ৳ ${d.remaining.toStringAsFixed(2)}"),
                trailing: ElevatedButton(
                  onPressed: () => showPayDialog(d),
                  child: const Text("Pay"),
                ),
              )),

          const Divider(),

          // 🟢 PAID
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Paid",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          ...paid.map((d) => ListTile(
                title: Text(d.name),
                subtitle: const Text("Paid"),
              )),
        ],
      ),
    );
  }
}