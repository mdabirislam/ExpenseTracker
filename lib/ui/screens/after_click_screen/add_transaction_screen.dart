import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';
import '../../../data/local/app_state.dart';
import '../../../data/local/category_manager.dart';
import '../../widgets/transaction_type_selector.dart';
import '../../widgets/category_dropdown_field.dart';
import '../../../utils/helpers.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    CategoryManager.init();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();
    setState(() {
      _selectedCategory = null; // triggers dropdown rebuild
    });
  }

  Future<void> _onSave() async {
    final amountText = _amountController.text.trim();
    final sourceInput = _sourceController.text.trim();
    final note = _noteController.text.trim();

    // Validation checks
    if (amountText.isEmpty || sourceInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount and Source are required')),
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

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category')),
      );
      return;
    }

    // Create Transaction
    final tx = TransactionData(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      category: _selectedCategory!,
      date: DateTime.now(),
      monthKey: generateMonthKey(DateTime.now()),
    );

    await AppState.addTransaction(tx);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
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
                  _selectedCategory = null; // reset category on type change
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
              key: ValueKey(_selectedCategory), // force rebuild
              type: _selectedType,
              initialValue: _selectedCategory,
              onSelected: (cat) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}