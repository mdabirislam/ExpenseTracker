import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';
import '../../../data/local/category_manager.dart';
import '../../widgets/transaction_type_selector.dart';
import '../../widgets/category_dropdown_field.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionData tx;

  const EditTransactionScreen({super.key, required this.tx});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TransactionType _selectedType;
  late TextEditingController _sourceController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.tx.type;
    _sourceController = TextEditingController(text: widget.tx.source);
    _amountController = TextEditingController(text: widget.tx.amount.toString());
    _noteController = TextEditingController(text: widget.tx.note ?? '');
    _selectedCategory = widget.tx.category;
    CategoryManager.init();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final sourceInput = _sourceController.text.trim();
    final note = _noteController.text.trim();
    final amountText = _amountController.text.trim();

    if (sourceInput.isEmpty || amountText.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    final updatedTx = TransactionData(
      id: widget.tx.id,
      type: _selectedType,
      source: sourceInput,
      amount: amount,
      note: note.isEmpty ? null : note,
      category: _selectedCategory!,
      date: widget.tx.date,
      monthKey: widget.tx.monthKey,
    );

    await Hive.box<TransactionData>('transactions').put(widget.tx.key, updatedTx);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionTypeSelector(
              selectedType: _selectedType,
              onSelected: (type) {
                setState(() {
                  _selectedType = type;
                  _selectedCategory = null;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CategoryDropdownField(
              type: _selectedType,
              initialValue: _selectedCategory,
              onSelected: (cat) => _selectedCategory = cat,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSave,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}