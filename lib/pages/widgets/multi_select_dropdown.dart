// lib/widgets/multi_select_dropdown.dart

import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;
  final bool disabled;
  final bool required;

  const MultiSelectDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.disabled = false,
    this.required = false,
  }) : super(key: key);

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    // Format display text
    String displayText = widget.selectedItems.isEmpty
        ? (widget.required ? "Select options (required)" : "Select options")
        : widget.selectedItems.join(", ");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          errorText: widget.required && widget.selectedItems.isEmpty
              ? 'Please select at least one option'
              : null,
          suffixIcon: widget.disabled
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: () => _showMultiSelectDialog(),
                  tooltip: 'Edit selections',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        ),
        child: InkWell(
          onTap: widget.disabled ? null : _showMultiSelectDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              displayText,
              style: TextStyle(
                color: widget.selectedItems.isEmpty ? Colors.grey.shade600 : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: widget.label,
          items: widget.items,
          selectedItems: widget.selectedItems,
          onConfirm: (selected) {
            widget.onChanged(selected);
            setState(() {});
          },
        );
      },
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onConfirm;

  const MultiSelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late Set<String> _selectedItems;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedItems.toSet();
  }

  List<String> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Select All / Clear All buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedItems = Set.from(widget.items);
                      });
                    },
                    child: const Text('Select All'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedItems.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ),
              ],
            ),
            const Divider(),
            // Selected count
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${_selectedItems.length} selected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Options list
            Expanded(
              child: ListView(
                children: _filteredItems.map((item) {
                  return CheckboxListTile(
                    title: Text(item),
                    value: _selectedItems.contains(item),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                    dense: true,
                    activeColor: Colors.blue,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_selectedItems.toList());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}