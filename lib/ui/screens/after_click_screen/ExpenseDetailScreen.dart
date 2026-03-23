import 'package:flutter/material.dart';
import '../../placeholders/fake_data.dart'; // path adjust করে নিতে হবে

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white24,
                      ),
                      child: const Text('From: YYYY-MM-DD', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white24,
                      ),
                      child: const Text('To: YYYY-MM-DD', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                  ),
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: const [
                Expanded(flex: 5, child: Text('Total Income : 000000', style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                Expanded(flex: 5, child: Text('Show Details',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
, textAlign: TextAlign.right)),
              ],
            ),
          ),
          //    const Text(
          //     'Show Details',
          //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          //     textAlign: TextAlign.right,
          //   ),
          // ),
          //   const Text(
          //     'Show Details',
          //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          //     textAlign: TextAlign.right,
          //   ),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.grey[300],
            child: Row(
              children: const [
                Expanded(flex: 5, child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Count', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black26),
          Expanded(
            child: ListView.separated(
              itemCount: dummyExpense.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                final item = dummyExpense[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: Text(item['category'], maxLines: 2, overflow: TextOverflow.ellipsis)),
                      Expanded(flex: 2, child: Center(child: Text(item['count'].toString()))),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('৳ ${item['amount'].toStringAsFixed(2)}'),
                          ),
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