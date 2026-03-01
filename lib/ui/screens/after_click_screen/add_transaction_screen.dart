import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';
import '../../../utils/helpers.dart';
import '../../../data/local/app_state.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;
  late Box _categoryBox;

  Map<TransactionType, List<String>> _typeCategories = {};

  final List<String> _demoSuggestions = [
    'Food',
    'Transport',
    'Other',
  ];

  final FocusNode _categoryFocus = FocusNode();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _openCategoryBox();

    _categoryFocus.addListener(() {
      setState(() {
        _showDropdown = _categoryFocus.hasFocus;
      });
    });
  }

  Future<void> _openCategoryBox() async {
    _categoryBox = await Hive.openBox('transaction_categories');

    for (var type in TransactionType.values) {
      final saved = _categoryBox.get(type.toString(), defaultValue: <String>[]);

      if (saved.isEmpty) {
        _typeCategories[type] = [..._demoSuggestions];
      } else {
        _typeCategories[type] = List<String>.from(saved);
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveCategory(TransactionType type, String category) async {
    if (!_typeCategories[type]!.contains(category)) {
      _typeCategories[type]!.add(category);
      await _categoryBox.put(type.toString(), _typeCategories[type]);
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

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
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

    await _saveCategory(_selectedType, _selectedCategory!);

    final tx = TransactionData(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      date: DateTime.now(),
      category: _selectedCategory!,
      monthKey: generateMonthKey(DateTime.now()),
    );

    await AppState.addTransaction(tx);

    if (!mounted) return;

    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();
    _categoryController.clear();

    setState(() => _selectedCategory = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );
  }

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
  Widget build(BuildContext context) {
    final currentCategories = _typeCategories[_selectedType] ?? _demoSuggestions;

    final filtered = _categoryController.text.isEmpty
        ? currentCategories
        : currentCategories
            .where((c) =>
                c.toLowerCase().contains(_categoryController.text.toLowerCase()))
            .toList();

    final showAddNew = _categoryController.text.isNotEmpty &&
        !filtered.any(
          (c) => c.toLowerCase() == _categoryController.text.toLowerCase(),
        );

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
            _categoryField(filtered, showAddNew),
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
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: TransactionType.values.map((type) {
        final isSelected = _selectedType == type;

        return ChoiceChip(
          label: Text(
            type.name,
            style: const TextStyle(fontSize: 13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedType = type;
              _selectedCategory = null;
              _categoryController.clear();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _sourceField() {
    return TextField(
      controller: _sourceController,
      decoration: const InputDecoration(
        labelText: 'Source / Reason',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _categoryField(List<String> filtered, bool showAddNew) {
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
          onChanged: (_) => setState(() {}),
        ),
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        _categoryFocus.unfocus();
                      });
                    },
                  ),
                ),
                if (showAddNew)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.add),
                    title: Text('Add "${_categoryController.text}"'),
                    onTap: () async {
                      final newCat = _categoryController.text.trim();

                      await _saveCategory(_selectedType, newCat);

                      setState(() {
                        _selectedCategory = newCat;
                        _showDropdown = false;
                        _categoryFocus.unfocus();
                      });
                    },
                  ),
              ],
            ),
          ),
      ],
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