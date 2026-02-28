import 'package:flutter/material.dart';
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
// disposing text editing controller
//for making cmd comfort
//but it didnt worked
 @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  // ───────── Source Labels ─────────
  final Map<TransactionType, String> _sourceLabels = {
    TransactionType.expense: 'Expense Source / Reason',
    TransactionType.income: 'Income Source',
    TransactionType.debtBorrow: 'Lend / Borrow From',
    TransactionType.debtRepay: 'Debt / Receive To',
    TransactionType.lendGive: 'Lend / Borrow From',
    TransactionType.lendReceive: 'Debt / Receive To',
    TransactionType.creditBuy: 'Credit Purchase From',
    TransactionType.creditPay: 'Credit Payment To',
    TransactionType.savingsAdd: 'Savings Source / Destination',
    TransactionType.savingsWithdraw: 'Savings Source / Destination',
  };

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    // ───────── Create transaction ─────────
    final tx = TransactionData(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      date: DateTime.now(),
      category: 'Others',
      monthKey: generateMonthKey(DateTime.now()),
    );

    await AppState.addTransaction(tx);

    //check if widget active
    if (!mounted) return;
    // ───────── Clear fields ─────────
    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction saved')));
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
    final List<TransactionType> chipOrder = [
      TransactionType.income, // Income Money
      TransactionType.debtBorrow, // Debt To Pay
      TransactionType.creditBuy, // Credit Buy
      TransactionType.savingsAdd, // Savings
      TransactionType.lendGive, // Lend Money
      TransactionType.expense, // Expense Money
      TransactionType.debtRepay, // Repaid Debt
      TransactionType.creditPay, // Credit Paid
      TransactionType.savingsWithdraw, // Withdraw Savings
      TransactionType.lendReceive, // Repaid Lend
    ];

    final Map<TransactionType, String> shortLabels = {
      TransactionType.income: 'Income Money',
      TransactionType.expense: 'Expense Money',
      TransactionType.debtBorrow: 'Debt To Pay',
      TransactionType.debtRepay: 'Repaid Debt',
      TransactionType.creditBuy: 'Credit Buy',
      TransactionType.creditPay: 'Credit Paid',
      TransactionType.savingsAdd: 'Savings',
      TransactionType.savingsWithdraw: 'Withdraw Savings',
      TransactionType.lendGive: 'Lend Money',
      TransactionType.lendReceive: 'Repaid Lend',
    };

    final screenWidth = MediaQuery.of(context).size.width;
    final chipWidth =
        (screenWidth - 32 - 4 * 8) /
        5; // 16 padding + 8 spacing*4, 5 chips max per row

    return Wrap(
      spacing: 4, // chip spacing horizontal
      runSpacing: 4, // chip spacing vertical
      children: chipOrder.map((type) {
        final isSelected = _selectedType == type;
        return SizedBox(
          width: chipWidth,
          child: ChoiceChip(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            label: Text(
              shortLabels[type]!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedType = type);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _sourceField() {
    return TextField(
      controller: _sourceController,
      decoration: InputDecoration(
        labelText: _sourceLabels[_selectedType] ?? 'Source',
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
