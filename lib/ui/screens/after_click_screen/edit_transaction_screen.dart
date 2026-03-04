import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';

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
  late TextEditingController _categoryController;

  final FocusNode _categoryFocus = FocusNode();

  String? _selectedCategory;
  bool _showDropdown = false;

  late Box<List<dynamic>> _categoryBox;
  final Map<TransactionType, List<String>> _typeCategories = {};

  final Map<String, List<String>> _demoByGroup = {
    'income': ['Income Demo 1', 'Income Demo 2', 'Other'],
    'expense': ['Expense Demo 1', 'Expense Demo 2', 'Other'],
    'debt': ['Debt Demo 1', 'Debt Demo 2', 'Other'],
    'lend': ['Lend Demo 1', 'Lend Demo 2', 'Other'],
  };

  @override
  void initState() {
    super.initState();

    _selectedType = widget.tx.type;
    _sourceController = TextEditingController(text: widget.tx.source);
    _amountController =
        TextEditingController(text: widget.tx.amount.toString());
    _noteController = TextEditingController(text: widget.tx.note ?? '');
    _categoryController = TextEditingController(text: widget.tx.category);

    _selectedCategory = widget.tx.category;

    _initCategorySystem();
  }

  Future<void> _initCategorySystem() async {
    _categoryBox = await Hive.openBox<List<dynamic>>('transaction_categories');

    for (var type in TransactionType.values) {
      final key = type.toString();
      final group = _groupOf(type);
      final saved = _categoryBox.get(key);

      if (saved == null) {
        _typeCategories[type] = [..._demoByGroup[group]!];
        await _categoryBox.put(key, _typeCategories[type]!);
      } else {
        _typeCategories[type] = List<String>.from(saved);
      }
    }

    if (!mounted) return;
    setState(() {});
  }

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

  Future<void> _onSave() async {
    final sourceInput = _sourceController.text.trim();
    final note = _noteController.text.trim();
    final amountText = _amountController.text.trim();
    final typedCategory = _categoryController.text.trim();

    if (sourceInput.isEmpty || amountText.isEmpty) {
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
    final categories = _typeCategories[_selectedType] ?? ['Other'];

    if (_selectedCategory != null) {
      finalCategory = _selectedCategory!;
    } else if (typedCategory.isEmpty) {
      final result = await _confirmDialog('Save as "Other" category?');
      if (!result) return;
      finalCategory = 'Other';
    } else {
      final result =
          await _confirmDialog('Create new category "$typedCategory"?');
      if (!result) return;

      finalCategory = typedCategory;

      if (!categories.any(
          (c) => c.toLowerCase() == finalCategory.toLowerCase())) {
        categories.add(finalCategory);
        await _categoryBox.put(_selectedType.toString(), categories);
      }
    }

    final updatedTx = TransactionData(
      id: widget.tx.id,
      type: _selectedType,
      source: sourceInput,
      amount: amount,
      note: note.isEmpty ? null : note,
      category: finalCategory,
      date: widget.tx.date,
      monthKey: widget.tx.monthKey,
    );

    await Hive.box<TransactionData>('transactions')
        .put(widget.tx.key, updatedTx);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    _categoryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _showDropdown = false);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeSelector(),
              const SizedBox(height: 16),
              _sourceField(),
              const SizedBox(height: 16),
              _categoryField(),
              const SizedBox(height: 16),
              _amountField(),
              const SizedBox(height: 16),
              _noteField(),
              const SizedBox(height: 24),
              _actionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeSelector() {
    final List<TransactionType> typesOrder = [
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
      children: typesOrder.map((type) {
        final isSelected = _selectedType == type;

        return SizedBox(
          width: chipWidth,
          child: ChoiceChip(
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
                _showDropdown = false;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _sourceField() => TextField(
        controller: _sourceController,
        decoration: const InputDecoration(
          labelText: 'Source',
          border: OutlineInputBorder(),
        ),
      );

  Widget _amountField() => TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: '৳ ',
          border: OutlineInputBorder(),
        ),
      );

  Widget _noteField() => TextField(
        controller: _noteController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Note (optional)',
          border: OutlineInputBorder(),
        ),
      );

  Widget _categoryField() {
    final categories = _typeCategories[_selectedType] ?? [];

    final filtered = _categoryController.text.isEmpty
        ? categories
        : categories
            .where((c) => c
                .toLowerCase()
                .contains(_categoryController.text.toLowerCase()))
            .toList();

    final showAddNew = _categoryController.text.isNotEmpty &&
        !categories.any((c) =>
            c.toLowerCase() ==
            _categoryController.text.trim().toLowerCase());

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
          onTap: () => setState(() => _showDropdown = true),
          onChanged: (_) {
            setState(() {
              _selectedCategory = null;
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
              color: Colors.white,
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                ...filtered.map(
                  (cat) => ListTile(
                    dense: true,
                    title: Text(cat),
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                        _categoryController.text = cat;
                        _showDropdown = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                if (showAddNew)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(
                        'Add "${_categoryController.text.trim()}" as new category'),
                    onTap: () async {
                      final newCat = _categoryController.text.trim();

                      setState(() {
                        _selectedCategory = newCat;
                        _typeCategories[_selectedType]!.add(newCat);
                        _showDropdown = false;
                      });

                      await _categoryBox.put(
                        _selectedType.toString(),
                        _typeCategories[_selectedType]!,
                      );

                      FocusScope.of(context).unfocus();
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
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
    );
  }
}