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

  DateTime _selectedDate = DateTime.now();

  // per-field locks
  bool _categoryLocked = false;
  bool _dateLocked = false;

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
      _selectedCategory = null;
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;

        // user manually changed -> auto unlock date lock
        if (_dateLocked) {
          _dateLocked = false;
        }
      });
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

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category')),
      );
      return;
    }

    final now = DateTime.now();

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    final tx = TransactionData(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      source: sourceInput,
      note: note.isEmpty ? null : note,
      category: _selectedCategory!,
      date: finalDateTime,
      monthKey: generateMonthKey(finalDateTime),
    );

    await AppState.addTransaction(tx);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );

    // always clear text fields
    _amountController.clear();
    _sourceController.clear();
    _noteController.clear();

    // lock-aware reset
    setState(() {

      if (!_categoryLocked) {
        _selectedCategory = null;
      }

      if (!_dateLocked) {
        _selectedDate = DateTime.now();
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
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

                  // type change => category invalid হতে পারে
                  _selectedCategory = null;

                  // category lock release
                  _categoryLocked = false;
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
  key: ValueKey(_selectedCategory),
  type: _selectedType,
  initialValue: _selectedCategory,

  decoration: InputDecoration(
    labelText: _categoryLocked
        ? 'Category (Locked)'
        : 'Category',

    border: const OutlineInputBorder(),

    suffixIcon: IconButton(
      tooltip: _categoryLocked
          ? 'Unlock Category'
          : 'Lock Category',

      icon: Icon(
        _categoryLocked
            ? Icons.lock
            : Icons.lock_open,
      ),

      onPressed: () {
        setState(() {
          _categoryLocked = !_categoryLocked;
        });
      },
    ),
  ),

  onSelected: (cat) {
    setState(() {
      _selectedCategory = cat;

      if (_categoryLocked) {
        _categoryLocked = false;
      }
    });
  },
),
            const SizedBox(height: 16),

            // DATE FIELD + LOCK ICON INSIDE FIELD
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _dateLocked
                      ? 'Date (Locked)'
                      : 'Date',

                  border: const OutlineInputBorder(),

                  prefixIcon: const Icon(
                    Icons.calendar_today,
                  ),

                  suffixIcon: IconButton(
                    tooltip: _dateLocked
                        ? 'Unlock Date'
                        : 'Lock Date',

                    icon: Icon(
                      _dateLocked
                          ? Icons.lock
                          : Icons.lock_open,
                    ),

                    onPressed: () {
                      setState(() {
                        _dateLocked = !_dateLocked;
                      });
                    },
                  ),
                ),

                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                ),
              ),
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