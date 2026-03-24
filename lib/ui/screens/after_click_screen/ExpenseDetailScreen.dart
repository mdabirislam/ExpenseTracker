import 'package:flutter/material.dart';
import '../../placeholders/fake_data.dart';

class ExpenseDetailScreen extends StatefulWidget {
  const ExpenseDetailScreen({super.key});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {

  DateTime? fromDate;
  DateTime? toDate;

  // 📅 Date Picker
  Future<void> _selectDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  // 📅 Format
  String formatDate(DateTime? date) {
    if (date == null) return 'DD/MM/YY';
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        centerTitle: true,
        backgroundColor: Colors.green,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // From
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(true),
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white24,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'From -\n${formatDate(fromDate)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // To
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(false),
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white24,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'To -\n${formatDate(toDate)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Buttons
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 36,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              print("From: $fromDate");
                              print("To: $toDate");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Filter', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                fromDate = null;
                                toDate = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('All Time', style: TextStyle(fontSize: 12), textAlign: TextAlign.center,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Top summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Total Income : 000000',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Show Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.grey[300],
            child: Row(
              children: const [
                Expanded(flex: 5, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Count', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Amount', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: ListView.separated(
              itemCount: dummyExpense.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = dummyExpense[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(item['category'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: Text(item['count'].toString())),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('৳ ${(item['amount'] as num).toStringAsFixed(2)}'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}