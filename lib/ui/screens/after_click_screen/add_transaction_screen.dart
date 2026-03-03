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
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final FocusNode _categoryFocus = FocusNode();

  TransactionType _selectedType = TransactionType.expense;

  String? _selectedCategory;
  bool _showDropdown = false;

  // Demo categories
  final Map<TransactionType, List<String>> _typeCategories = {
    TransactionType.income: ['Salary', 'Business', 'Bonus', 'Other'],
    TransactionType.expense: ['Food', 'Transport', 'Shopping', 'Other'],
    TransactionType.debtBorrow: ['Borrow', 'Loan', 'Other'],
    TransactionType.debtRepay: ['Debt Repay', 'Other'],
    TransactionType.creditBuy: ['Market', 'Medicine', 'Other'],
    TransactionType.creditPay: ['Credit Payment', 'Other'],
    TransactionType.lendGive: ['Lend', 'Other'],
    TransactionType.lendReceive: ['Receive Back', 'Other'],
    TransactionType.savingsAdd: ['Savings', 'Other'],
    TransactionType.savingsWithdraw: ['Withdraw', 'Other'],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    _categoryFocus.dispose();
    super.dispose();
  }

  // Source labels
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

  Future<void> _onSave() async {
    final amountText = _amountController.text.trim();
    final sourceInput = _sourceController.text.trim();
    final note = _noteController.text.trim();
    final categoryInput = _categoryController.text.trim();

    if (amountText.isEmpty || sourceInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount and Source are required')),
      );
      return;
    }

    if (categoryInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category')),
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

    final tx = TransactionData(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      date: DateTime.now(),
      category: _selectedCategory ?? categoryInput,
      monthKey: generateMonthKey(DateTime.now()),
    );

    await AppState.addTransaction(tx);

    if (!mounted) return;

    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();
    _categoryController.clear();
    _selectedCategory = null;

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
            _categoryField(),
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
    final List<TransactionType> chipOrder = [
      TransactionType.income,
      TransactionType.debtBorrow,
      TransactionType.creditBuy,
      TransactionType.savingsAdd,
      TransactionType.lendGive,
      TransactionType.expense,
      TransactionType.debtRepay,
      TransactionType.creditPay,
      TransactionType.savingsWithdraw,
      TransactionType.lendReceive,
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
    final chipWidth = (screenWidth - 32 - 4 * 8) / 5;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
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
              setState(() {
                _selectedType = type;
                _categoryController.clear();
                _selectedCategory = null;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _categoryField() {
    final categories = _typeCategories[_selectedType] ?? [];

    final filtered = _categoryController.text.isEmpty
        ? categories
        : categories
            .where((c) => c
                .toLowerCase()
                .contains(_categoryController.text.toLowerCase()))
            .toList();

    final showAddNew =
        _categoryController.text.isNotEmpty &&
        !categories.contains(_categoryController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _categoryController,
          focusNode: _categoryFocus,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          onTap: () {
            setState(() {
              _showDropdown = true;
            });
          },
          onChanged: (_) {
            setState(() {
              _showDropdown = true;
            });
          },
        ),
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...filtered.map(
                  (cat) => ListTile(
                    title: Text(cat),
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                        _categoryController.text = cat;
                        _showDropdown = false;
                      });
                    },
                  ),
                ),
                if (showAddNew)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text('Add "${_categoryController.text}"'),
                    onTap: () {
                      final newCat = _categoryController.text.trim();

                      setState(() {
                        _typeCategories[_selectedType]?.add(newCat);
                        _selectedCategory = newCat;
                        _showDropdown = false;
                      });
                    },
                  ),
              ],
            ),
          ),
      ],
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
      child: ElevatedButton(
        onPressed: _onSave,
        child: const Text('Save'),
      ),
    );
  }
}