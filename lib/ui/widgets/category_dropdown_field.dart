import 'package:flutter/material.dart';
import '../../models/transaction_type.dart';
import '../../data/local/category_manager.dart';

class CategoryDropdownField extends StatefulWidget {
  final TransactionType type;
  final String? initialValue;
  final Function(String) onSelected;

  const CategoryDropdownField({
    super.key,
    required this.type,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<CategoryDropdownField> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends State<CategoryDropdownField> {
  late TextEditingController _controller;
  String? _selectedCategory;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _selectedCategory = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CategoryDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
      _selectedCategory = widget.initialValue;
      _showDropdown = false; // close dropdown on parent reset
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryManager.getCategories(widget.type);
    final filtered = _controller.text.isEmpty
        ? categories
        : categories
            .where((c) =>
                c.toLowerCase().contains(_controller.text.toLowerCase()))
            .toList();

    final showAddNew = _controller.text.isNotEmpty &&
        !categories.any((c) =>
            c.toLowerCase() == _controller.text.trim().toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          onTap: () => setState(() => _showDropdown = true),
          onChanged: (_) {
            setState(() {
              _selectedCategory ??= _controller.text;
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
                ...filtered.map((cat) => ListTile(
                      dense: true,
                      title: Text(cat),
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                          _controller.text = cat;
                          _showDropdown = false;
                        });
                        widget.onSelected(cat);
                        FocusScope.of(context).unfocus();
                      },
                    )),
                if (showAddNew)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text('Add "${_controller.text.trim()}" as new category'),
                    onTap: () async {
                      final newCat = _controller.text.trim();
                      await CategoryManager.addCategory(widget.type, newCat);

                      setState(() {
                        _selectedCategory = newCat;
                        _controller.text = newCat;
                        _showDropdown = false;
                      });

                      widget.onSelected(newCat);
                      FocusScope.of(context).unfocus();
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}