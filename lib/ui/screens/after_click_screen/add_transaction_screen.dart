import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final TextEditingController _categoryController = TextEditingController();

  final FocusNode _categoryFocus = FocusNode();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;

  late Box _categoryBox;

  bool _showDropdown = false;

  Map<TransactionType, List<String>> _typeCategories = {};

  // ───────── Demo Categories ─────────
  final Map<String, List<String>> _demoByGroup = {
    'income': ['Income Demo 1', 'Income Demo 2', 'Other'],
    'expense': ['Expense Demo 1', 'Expense Demo 2', 'Other'],
    'debt': ['Debt Demo 1', 'Debt Demo 2', 'Other'],
    'lend': ['Lend Demo 1', 'Lend Demo 2', 'Other'],
  };

  // ───────── Dispose ─────────
  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    _categoryFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initCategorySystem();

    _categoryFocus.addListener(() {
      if (_categoryFocus.hasFocus) {
        setState(() => _showDropdown = true);
      } else {
        setState(() => _showDropdown = false);
      }
    });
  }

  // ───────── Group detect ─────────
  String _groupOf(TransactionType type) {
    if (type == TransactionType.income) return 'income';
    if (type == TransactionType.expense) return 'expense';

    if (type == TransactionType.debtBorrow ||
        type == TransactionType.debtRepay ||
        type == TransactionType.creditBuy ||
        type == TransactionType.creditPay) {
      return 'debt';
    }

    if (type == TransactionType.lendGive ||
        type == TransactionType.lendReceive) {
      return 'lend';
    }

    return 'expense';
  }

  // ───────── Init Hive ─────────
  Future<void> _initCategorySystem() async {
    _categoryBox = await Hive.openBox('transaction_categories');

    for (var type in TransactionType.values) {
      final key = type.toString();
      final group = _groupOf(type);

      final saved = _categoryBox.get(key);

      if (saved == null) {
        _typeCategories[type] = [..._demoByGroup[group]!];
        await _categoryBox.put(key, _typeCategories[type]);
      } else {
        _typeCategories[type] = List<String>.from(saved);
      }
    }

    if (mounted) setState(() {});
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
    final typedCategory = _categoryController.text.trim();

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

    String finalCategory;

    if (_selectedCategory != null) {
      finalCategory = _selectedCategory!;
    } else if (typedCategory.isEmpty) {
      final result = await _confirmDialog(
        'Save as "Other" category?',
      );
      if (!result) return;
      finalCategory = 'Other';
    } else {
      final result = await _confirmDialog(
        'Create new category "$typedCategory"?',
      );
      if (!result) return;

      finalCategory = typedCategory;

      final list = _typeCategories[_selectedType]!;
      if (!list.contains(finalCategory)) {
        list.add(finalCategory);
        await _categoryBox.put(
            _selectedType.toString(), list);
      }
    }

    final tx = TransactionData(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      date: DateTime.now(),
      category: finalCategory,
      monthKey: generateMonthKey(DateTime.now()),
    );

    await AppState.addTransaction(tx);

    if (!mounted) return;

    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();
    _categoryController.clear();
    _selectedCategory = null;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Transaction saved')));
  }

  Future<bool> _confirmDialog(String text) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final current = _typeCategories[_selectedType] ?? [];

    final filtered = _categoryController.text.isEmpty
        ? current
        : current
            .where((c) => c
                .toLowerCase()
                .contains(_categoryController.text.toLowerCase()))
            .toList();

    final showAdd = _categoryController.text.isNotEmpty &&
        !current.any((c) =>
            c.toLowerCase() ==
            _categoryController.text.toLowerCase());

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
            _categoryField(filtered, showAdd),
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

  // ───────── Category UI ─────────
  Widget _categoryField(List<String> filtered, bool showAdd) {
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
          onChanged: (_) {
            setState(() {
              _selectedCategory = null;
            });
          },
        ),
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: Column(
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
                if (showAdd)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text('Add "${_categoryController.text}"'),
                    onTap: () {
                      final newCat = _categoryController.text.trim();
                      setState(() {
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

  // ───────── Existing Widgets (unchanged) ─────────

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