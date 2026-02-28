import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/helpers.dart';
import '../../../models/transaction_type.dart';
import '../../../data/local/app_state.dart';
import '../../../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // ───────── Controllers ─────────
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;

  // ───────── Save Logic ─────────
  Future<void> _onSave() async {
    final amountText = _amountController.text.trim();
    final sourceInput = _sourceController.text.trim();
    final note = _noteController.text.trim();

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

    /// Create transaction
    final tx = TransactionData(
      id: const Uuid().v4(),                     // Unique ID
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      date: DateTime.now(),
      category: 'Others',
      monthKey: generateMonthKey(DateTime.now()),
    );

    /// Save to Hive via AppState
    await AppState.addTransaction(tx);

    // Clear inputs
    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );
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
            _transactionTypeSelector(),
            const SizedBox(height: 16),
            _sourceField(),
            const SizedBox(height: 16),
            _amountField(),
            const SizedBox(height: 16),
            _noteField(),
            const SizedBox(height: 24),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ───────── Widgets ─────────
  Widget _transactionTypeSelector() {
    return Row(
      children: TransactionType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(transactionTypeLabel(type)), // helper.dart
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedType = type);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sourceField() {
    String label;
    switch (_selectedType) {
      case TransactionType.expense:
        label = 'Expense Source / Reason';
        break;
      case TransactionType.income:
        label = 'Income Source';
        break;
      case TransactionType.debtBorrow:
      case TransactionType.lendGive:
        label = 'Lend / Borrow From';
        break;
      case TransactionType.debtRepay:
      case TransactionType.lendReceive:
        label = 'Debt / Receive To';
        break;
      case TransactionType.creditBuy:
        label = 'Credit Purchase From';
        break;
      case TransactionType.creditPay:
        label = 'Credit Payment To';
        break;
      case TransactionType.savingsAdd:
      case TransactionType.savingsWithdraw:
        label = 'Savings Source / Destination';
        break;
    }

    return TextField(
      controller: _sourceController,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _amountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '৳ ',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _noteField() {
    return TextField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Note (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: _onSave, child: const Text('Save')),
    );
  }
}