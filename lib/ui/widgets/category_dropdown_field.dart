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
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

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
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _showOverlay() {
    _removeOverlay();

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

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width - 32, // adjust if needed
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 55), // TextField height
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        ...filtered.map((cat) => ListTile(
                              dense: true,
                              title: Text(cat),
                              onTap: () {
                                _controller.text = cat;
                                _selectedCategory = cat;
                                widget.onSelected(cat);
                                _removeOverlay();
                                FocusScope.of(context).unfocus();
                              },
                            )),
                        if (showAddNew)
                          ListTile(
                            leading: const Icon(Icons.add),
                            title: Text(
                                'Add "${_controller.text.trim()}" as new category'),
                            onTap: () async {
                              final newCat = _controller.text.trim();
                              await CategoryManager.addCategory(
                                  widget.type, newCat);
                              _controller.text = newCat;
                              _selectedCategory = newCat;
                              widget.onSelected(newCat);
                              _removeOverlay();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        onTap: _showOverlay,
        onChanged: (_) => _showOverlay(),
      ),
    );
  }
}