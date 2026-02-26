import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../utils/helpers.dart';
import '../../../models/transaction_type.dart';
import '../../../data/local/app_state.dart';
import '../../../models/transaction_model.dart';
import 'package:uuid/uuid.dart'; // for unique id

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

  final uuid = const Uuid();

  // ───────── Source Label ─────────
  String getSourceLabel(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return 'Expense Source / Reason';
      case TransactionType.income:
        return 'Income Source';
      case TransactionType.debtBorrow:
      case TransactionType.debtRepay:
        return 'Debt From / To';
      case TransactionType.creditBuy:
      case TransactionType.creditPay:
        return 'Credit From / To';
      case TransactionType.savingsAdd:
      case TransactionType.savingsWithdraw:
        return 'Savings Source / Note';
      case TransactionType.lendGive:
      case TransactionType.lendReceive:
        return 'Lend / Receive';
      default:
        return 'Source';
    }
  }

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

    final box = Hive.box<TransactionData>('transactions');

    // Existing sources only for this type
    final existingSources = box.values
        .where((tx) => tx.type == _selectedType)
        .map((tx) => tx.source)
        .toList();

    String finalSource = sourceInput;

    if (existingSources.contains(sourceInput)) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Source already exists'),
          content: const Text(
            'This source already exists. Do you want to merge or create a new one?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'merge'),
              child: const Text('Merge'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'new'),
              child: const Text('Create New'),
            ),
          ],
        ),
      );

      if (result == 'new') {
        finalSource = generateUniqueSource(sourceInput, existingSources);
      }
    }

    // Generate monthKey
    final monthKey = generateMonthKey(DateTime.now());

    // Create transaction with required `id`
    final tx = TransactionData(
      id: uuid.v4(),
      type: _selectedType,
      amount: amount,
      category: 'Others',
      source: finalSource,
      note: note.isEmpty ? null : note,
      date: DateTime.now(),
      monthKey: monthKey,
      priorityLevel: null,
      isArchived: false,
      isCleared: false,
      isPlanned: false,
    );

    await AppState.addTransaction(tx);

    // Clear inputs
    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();

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

  Widget _transactionTypeSelector() {
    return Row(
      children: TransactionType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(transactionTypeLabel(type)),
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
    return TextField(
      controller: _sourceController,
      decoration: InputDecoration(
        labelText: getSourceLabel(_selectedType),
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